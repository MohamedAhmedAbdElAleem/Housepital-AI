$file1 = 'lib\features\customer\home\presentation\pages\all_nursing_services_page.dart'
$c1 = Get-Content $file1 -Raw

$c1 = $c1 -replace '  Widget build\(BuildContext context\) \{', '  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A202C);
    final textMuted = isDark ? const Color(0xFFA19EAB) : const Color(0xFF718096);
    final surfaceColor = isDark ? const Color(0xFF0D0C11) : const Color(0xFFF0F4F8);
    final cardBg = isDark ? const Color(0xFF16151A) : Colors.white;
    final searchBorder = isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(10);'

$c1 = $c1 -replace '    const surfaceColor = Color\(0xFFF0F4F8\);', ''

$c1 = $c1 -replace 'decoration: BoxDecoration\(\s*color: Colors\.white,\s*borderRadius: BorderRadius\.circular\(16\),\s*border: Border\.all\(color: Colors\.black\.withAlpha\(10\)\),\s*\)', 'decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: searchBorder),
                                  )'

$c1 = $c1 -replace 'style: const TextStyle\(color: Color\(0xFF1A202C\),', 'style: TextStyle(color: textPrimary,'
$c1 = $c1 -replace 'hintStyle: const TextStyle\(color: Color\(0xFF718096\),', 'hintStyle: TextStyle(color: textMuted,'

$c1 = $c1 -replace 'color: const Color\(0xFF1A202C\)', 'color: textPrimary'
$c1 = $c1 -replace 'color: Color\(0xFF1A202C\)', 'color: textPrimary'

$c1 = $c1 -replace 'color: const Color\(0xFF718096\)', 'color: textMuted'
$c1 = $c1 -replace 'color: Color\(0xFF718096\)', 'color: textMuted'

$c1 = $c1 -replace 'const Color\(0xFFF0F4F8\)', 'surfaceColor'

$c1 = $c1 -replace 'void _showFilterBottomSheet\(\) \{', 'void _showFilterBottomSheet(bool isDark) {'
$c1 = $c1 -replace '_showFilterBottomSheet\(\);', '_showFilterBottomSheet(isDark);'

$c1 = $c1 -replace 'color: Colors\.white,\s*borderRadius: BorderRadius\.vertical\(top: Radius\.circular\(32\)\),', 'color: isDark ? const Color(0xFF16151A) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),'

$c1 = $c1 -replace 'color: Colors\.grey\.shade300,', 'color: isDark ? const Color(0xFF2A2831) : Colors.grey.shade300,'

$c1 = $c1 -replace 'style: TextStyle\(fontFamily: ''Poppins'', fontSize: 20, fontWeight: FontWeight\.bold\)', 'style: TextStyle(fontFamily: ''Poppins'', fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)'

$c1 = $c1 -replace 'const Text\(''Sort By'', style: TextStyle\(fontFamily: ''Inter'', fontSize: 16, fontWeight: FontWeight\.w600\)\)', 'Text(''Sort By'', style: TextStyle(fontFamily: ''Inter'', fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black))'

$c1 = $c1 -replace '_buildFilterChip\((.*?), (.*?), \(\) \{', '_buildFilterChip($1, $2, isDark, () {'
$c1 = $c1 -replace 'Widget _buildFilterChip\(String label, bool isSelected, VoidCallback onTap\) \{', 'Widget _buildFilterChip(String label, bool isSelected, bool isDark, VoidCallback onTap) {'

$c1 = $c1 -replace 'color: isSelected \? const Color\(0xFF2ECC71\)\.withAlpha\(20\) : Colors\.white,', 'color: isSelected ? const Color(0xFF2ECC71).withAlpha(20) : (isDark ? const Color(0xFF1E1C24) : Colors.white),'
$c1 = $c1 -replace 'color: isSelected \? const Color\(0xFF2ECC71\) : Colors\.grey\.shade300,', 'color: isSelected ? const Color(0xFF2ECC71) : (isDark ? const Color(0xFF2A2831) : Colors.grey.shade300),'
$c1 = $c1 -replace 'color: isSelected \? const Color\(0xFF2ECC71\) : Colors\.black87,', 'color: isSelected ? const Color(0xFF2ECC71) : (isDark ? Colors.white : Colors.black87),'

$c1 = $c1 -replace 'class _StickyCategoryDelegate', 'class _StickyCategoryDelegate extends SliverPersistentHeaderDelegate {
  final bool isDark;'

$c1 = $c1 -replace '_StickyCategoryDelegate\(\{\s*required this\.categories,', '_StickyCategoryDelegate({
    required this.isDark,
    required this.categories,'

$c1 = $c1 -replace 'delegate: _StickyCategoryDelegate\(', 'delegate: _StickyCategoryDelegate(
              isDark: isDark,'

$c1 = $c1 -replace 'color: isScrolled \? surfaceColor\.withAlpha\(240\) : surfaceColor,', 'color: isScrolled ? (isDark ? const Color(0xFF0D0C11).withAlpha(240) : const Color(0xFFF0F4F8).withAlpha(240)) : (isDark ? const Color(0xFF0D0C11) : const Color(0xFFF0F4F8)),'

$c1 = $c1 -replace 'color: isSelected \? const Color\(0xFF1A202C\) : Colors\.white,', 'color: isSelected ? (isDark ? Colors.white : const Color(0xFF1A202C)) : (isDark ? const Color(0xFF1E1C24) : Colors.white),'
$c1 = $c1 -replace 'color: isSelected \? Colors\.white : textMuted,', 'color: isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? const Color(0xFFA19EAB) : const Color(0xFF718096)),'

# Also remove const from const Text for things that use textPrimary or textMuted
$c1 = [regex]::Replace($c1, 'const (Text\((?:[^)]|\r\n)*?textPrimary(?:[^)]|\r\n)*?\),)', '$1', [System.Text.RegularExpressions.RegexOptions]::Singleline)
$c1 = [regex]::Replace($c1, 'const (Text\((?:[^)]|\r\n)*?textMuted(?:[^)]|\r\n)*?\),)', '$1', [System.Text.RegularExpressions.RegexOptions]::Singleline)

Set-Content $file1 $c1 -Encoding UTF8


$file2 = 'lib\features\customer\home\presentation\widgets\nursing_service_card.dart'
$c2 = Get-Content $file2 -Raw

$c2 = $c2 -replace '    const textPrimary = Color\(0xFF1A202C\);', '    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A202C);'
$c2 = $c2 -replace '    const textMuted = Color\(0xFFA0AEC0\);', '    final textMuted = isDark ? const Color(0xFFA19EAB) : const Color(0xFFA0AEC0);
    final cardBg = isDark ? const Color(0xFF16151A) : Colors.white;'

$c2 = $c2 -replace 'color: Colors\.white,', 'color: cardBg,'

$c2 = [regex]::Replace($c2, 'const (TextStyle\((?:[^)]|\r\n)*?(?:textPrimary|textMuted)(?:[^)]|\r\n)*?\))', '$1', [System.Text.RegularExpressions.RegexOptions]::Singleline)

# For price label background (textPrimary) and text inside it
$c2 = $c2 -replace 'color: textPrimary,', 'color: isDark ? Colors.white : textPrimary,'
$c2 = $c2 -replace 'color: Colors\.white,', 'color: isDark ? const Color(0xFF1A202C) : Colors.white,'
$c2 = $c2 -replace 'color: Colors\.white\.withAlpha\(200\),', 'color: (isDark ? const Color(0xFF1A202C) : Colors.white).withAlpha(200),'


Set-Content $file2 $c2 -Encoding UTF8

Write-Host "Done"
