$file = 'lib\features\customer\profile\presentation\pages\account_page.dart'
$content = Get-Content $file -Raw

# 1. Replace static Design class with dynamic version
$oldClass = @'
class _Design {
  // Primary Palette
  static const Color primary = Color(0xFF2ECC71);
  static const Color primaryLight = Color(0xFF58D68D);

  // Accent Colors
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);

  // Neutrals
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Gradient
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF2ECC71), Color(0xFF27AE60), Color(0xFF1E8449)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
'@

$newClass = @'
class _Design {
  static const Color primary = Color(0xFF2ECC71);
  static const Color primaryLight = Color(0xFF58D68D);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF2ECC71), Color(0xFF27AE60), Color(0xFF1E8449)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static List<BoxShadow> softShadow(bool isDark) => [
    BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.04), blurRadius: 12, offset: const Offset(0, 4)),
  ];
  static Color background(bool isDark) => isDark ? const Color(0xFF0D0C11) : const Color(0xFFF8FAFC);
  static Color surface(bool isDark) => isDark ? const Color(0xFF16151A) : Colors.white;
  static Color surfaceVariant(bool isDark) => isDark ? const Color(0xFF1E1C24) : const Color(0xFFF1F5F9);
  static Color border(bool isDark) => isDark ? const Color(0xFF2A2831) : const Color(0xFFE2E8F0);
  static Color textPrimary(bool isDark) => isDark ? const Color(0xFFF2F2F5) : const Color(0xFF0F172A);
  static Color textSecondary(bool isDark) => isDark ? const Color(0xFFA19EAB) : const Color(0xFF475569);
  static Color textMuted(bool isDark) => isDark ? const Color(0xFF5F5C68) : const Color(0xFF94A3B8);
}
'@

$content = $content.Replace($oldClass, $newClass)

# 2. Fix scaffold background
$content = $content.Replace('backgroundColor: _Design.background,', 'backgroundColor: _Design.background(Theme.of(context).brightness == Brightness.dark),')

# 3. Fix loading text color
$content = $content.Replace("style: TextStyle(color: _Design.textSecondary, fontSize: 15),", "style: TextStyle(color: _Design.textSecondary(Theme.of(context).brightness == Brightness.dark), fontSize: 15),")

Set-Content $file $content -Encoding UTF8
Write-Host "Done"
