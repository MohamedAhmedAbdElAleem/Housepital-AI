$file = 'lib\features\customer\settings\presentation\pages\settings_page.dart'
$c = Get-Content $file -Raw

# 1. Add `bool get _isDark => Theme.of(context).brightness == Brightness.dark;` to _SettingsPageState
$c = $c -replace '  final Set<String> _expandedSections = \{\};\r\n\r\n  @override', '  final Set<String> _expandedSections = {};
  
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override'

# 2. Revert the method signatures that take `bool isDark`
$c = $c -replace 'Widget _buildLoadingState\(bool isDark\) \{', 'Widget _buildLoadingState() {'
$c = $c -replace 'Widget _buildContent\(bool isDark\) \{', 'Widget _buildContent() {'
$c = $c -replace 'Widget _buildProfileCard\(bool isDark\) \{', 'Widget _buildProfileCard() {'
$c = $c -replace 'Widget _buildSectionTitle\(String title, IconData icon, Color color, bool isDark\) \{', 'Widget _buildSectionTitle(String title, IconData icon, Color color) {'
$c = $c -replace 'Widget _buildSettingsCard\(List<Widget> children, bool isDark\) \{', 'Widget _buildSettingsCard(List<Widget> children) {'
$c = $c -replace 'Widget _buildSignOutButton\(bool isDark\) \{', 'Widget _buildSignOutButton() {'
$c = $c -replace 'required bool isDark,', ''

# Fix _buildSettingsTile and _buildToggleTile signatures (removing the required bool isDark that we added)
$c = [regex]::Replace($c, 'Widget _buildSettingsTile\(\{(?:\s*required bool isDark,)?', 'Widget _buildSettingsTile({')
$c = [regex]::Replace($c, 'Widget _buildToggleTile\(\{(?:\s*required bool isDark,)?', 'Widget _buildToggleTile({')

# 3. Change all calls from `isDark` to `_isDark` inside _SettingsDesign methods
$c = $c -replace '\(isDark\)', '(_isDark)'
$c = $c -replace 'isDark\?', '_isDark?'
$c = $c -replace 'isDark \?', '_isDark ?'

# Fix the method calls that we broke
$c = $c -replace '_buildLoadingState\(_isDark\)', '_buildLoadingState()'
$c = $c -replace '_buildContent\(_isDark\)', '_buildContent()'
$c = $c -replace '_buildProfileCard\(_isDark\)', '_buildProfileCard()'
$c = $c -replace '_buildSectionTitle\((.*?), (.*?), (.*?), _isDark\)', '_buildSectionTitle($1, $2, $3)'
$c = $c -replace '_buildSettingsCard\((.*?), _isDark\)', '_buildSettingsCard($1)'
$c = $c -replace 'isDark: _isDark, ', ''
$c = $c -replace '_buildSignOutButton\(_isDark\)', '_buildSignOutButton()'

# Fix the remaining 'const TextStyle' issues where _isDark is used
$c = [regex]::Replace($c, 'const (TextStyle\((?:[^)]|\r\n)*?_SettingsDesign\.(?:textPrimary|textSecondary|textMuted)\(_isDark\)(?:[^)]|\r\n)*?\))', '$1', [System.Text.RegularExpressions.RegexOptions]::Singleline)
$c = [regex]::Replace($c, 'const (Text\((?:[^)]|\r\n)*?_SettingsDesign\.(?:textPrimary|textSecondary|textMuted)\(_isDark\)(?:[^)]|\r\n)*?\),)', '$1', [System.Text.RegularExpressions.RegexOptions]::Singleline)

# Remove the `final isDark = ...` in `build`
$c = $c -replace '    final isDark = Theme\.of\(context\)\.brightness == Brightness\.dark;\r\n', ''
$c = $c -replace '    final isDark = Theme\.of\(context\)\.brightness == Brightness\.dark;\n', ''

# Fix const BoxDecoration issues
$c = [regex]::Replace($c, 'const (BoxDecoration\((?:[^)]|\r\n)*?_SettingsDesign\.(?:surface|cardBg|divider)\(_isDark\)(?:[^)]|\r\n)*?\))', '$1', [System.Text.RegularExpressions.RegexOptions]::Singleline)

Set-Content $file $c -Encoding UTF8
Write-Host "Done"
