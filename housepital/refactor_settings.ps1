$file = 'lib\features\customer\settings\presentation\pages\settings_page.dart'
$c = Get-Content $file -Raw

# 1. Update _SettingsDesign class
$c = $c -replace '(?s)class _SettingsDesign \{.*?\n  static const Color danger = Color\(0xFFEF4444\);', 'class _SettingsDesign {
  // Colors
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color secondaryGreen = Color(0xFF27AE60);
  
  static Color surface(bool isDark) => isDark ? const Color(0xFF0D0C11) : const Color(0xFFF8FAFC);
  static Color cardBg(bool isDark) => isDark ? const Color(0xFF16151A) : Colors.white;
  static Color textPrimary(bool isDark) => isDark ? const Color(0xFFF2F2F5) : const Color(0xFF1E293B);
  static Color textSecondary(bool isDark) => isDark ? const Color(0xFFA19EAB) : const Color(0xFF64748B);
  static Color textMuted(bool isDark) => isDark ? const Color(0xFF5F5C68) : const Color(0xFF94A3B8);
  static Color divider(bool isDark) => isDark ? const Color(0xFF2A2831) : const Color(0xFFE2E8F0);
  static const Color danger = Color(0xFFEF4444);'

# Update cardShadow
$c = $c -replace '(?s)static List<BoxShadow> cardShadow = \[.*?\];', 'static List<BoxShadow> cardShadow(bool isDark) => [
    BoxShadow(
      color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];'

# Add isDark to build
$c = $c -replace 'Widget build\(BuildContext context\) \{', 'Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;'

# Pass isDark to _buildLoadingState and _buildContent
$c = $c -replace 'body: _isLoading \? _buildLoadingState\(\) : _buildContent\(\),', 'body: _isLoading ? _buildLoadingState(isDark) : _buildContent(isDark),'

# Update method signatures to receive isDark
$c = $c -replace 'Widget _buildLoadingState\(\) \{', 'Widget _buildLoadingState(bool isDark) {'
$c = $c -replace 'Widget _buildContent\(\) \{', 'Widget _buildContent(bool isDark) {'
$c = $c -replace 'Widget _buildProfileCard\(\) \{', 'Widget _buildProfileCard(bool isDark) {'
$c = $c -replace 'Widget _buildSectionTitle\(String title, IconData icon, Color color\) \{', 'Widget _buildSectionTitle(String title, IconData icon, Color color, bool isDark) {'
$c = $c -replace 'Widget _buildSettingsCard\(List<Widget> children\) \{', 'Widget _buildSettingsCard(List<Widget> children, bool isDark) {'
$c = $c -replace 'Widget _buildSettingsTile\(\{', 'Widget _buildSettingsTile({
    required bool isDark,'
$c = $c -replace 'Widget _buildToggleTile\(\{', 'Widget _buildToggleTile({
    required bool isDark,'
$c = $c -replace 'Widget _buildSignOutButton\(\) \{', 'Widget _buildSignOutButton(bool isDark) {'

# Fix method calls in _buildContent
$c = $c -replace '_buildProfileCard\(\)', '_buildProfileCard(isDark)'
$c = $c -replace '_buildSectionTitle\((.*?), (.*?), (.*?)\)', '_buildSectionTitle($1, $2, $3, isDark)'
$c = $c -replace '_buildSettingsCard\(\[', '_buildSettingsCard(['
$c = $c -replace '_buildSettingsCard\((.*?)\]\)', '_buildSettingsCard($1], isDark)'
$c = $c -replace '_buildSettingsTile\(', '_buildSettingsTile(isDark: isDark, '
$c = $c -replace '_buildToggleTile\(', '_buildToggleTile(isDark: isDark, '
$c = $c -replace '_buildSignOutButton\(\)', '_buildSignOutButton(isDark)'

# Replace _SettingsDesign references with function calls
$c = $c -replace '_SettingsDesign\.surface', '_SettingsDesign.surface(isDark)'
$c = $c -replace '_SettingsDesign\.cardBg', '_SettingsDesign.cardBg(isDark)'
$c = $c -replace '_SettingsDesign\.textPrimary', '_SettingsDesign.textPrimary(isDark)'
$c = $c -replace '_SettingsDesign\.textSecondary', '_SettingsDesign.textSecondary(isDark)'
$c = $c -replace '_SettingsDesign\.textMuted', '_SettingsDesign.textMuted(isDark)'
$c = $c -replace '_SettingsDesign\.divider', '_SettingsDesign.divider(isDark)'
$c = $c -replace '_SettingsDesign\.cardShadow', '_SettingsDesign.cardShadow(isDark)'

# Fix the const issues that will arise
$c = [regex]::Replace($c, 'const (TextStyle\((?:[^)]|\r\n)*?_SettingsDesign\.(?:textPrimary|textSecondary|textMuted)\(isDark\)(?:[^)]|\r\n)*?\))', '$1', [System.Text.RegularExpressions.RegexOptions]::Singleline)
$c = [regex]::Replace($c, 'const (Text\((?:[^)]|\r\n)*?_SettingsDesign\.(?:textPrimary|textSecondary|textMuted)\(isDark\)(?:[^)]|\r\n)*?\),)', '$1', [System.Text.RegularExpressions.RegexOptions]::Singleline)

Set-Content $file $c -Encoding UTF8
Write-Host "Done"
