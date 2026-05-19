import re
import sys

def fix_settings():
    file_path = 'lib/features/customer/settings/presentation/pages/settings_page.dart'
    with open(file_path, 'r', encoding='utf-8') as f:
        c = f.read()

    # 1. Update _SettingsDesign
    design_str = """class _SettingsDesign {
  // Colors
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color secondaryGreen = Color(0xFF27AE60);
  
  static Color surface(bool isDark) => isDark ? const Color(0xFF0D0C11) : const Color(0xFFF8FAFC);
  static Color cardBg(bool isDark) => isDark ? const Color(0xFF16151A) : Colors.white;
  static Color textPrimary(bool isDark) => isDark ? const Color(0xFFF2F2F5) : const Color(0xFF1E293B);
  static Color textSecondary(bool isDark) => isDark ? const Color(0xFFA19EAB) : const Color(0xFF64748B);
  static Color textMuted(bool isDark) => isDark ? const Color(0xFF5F5C68) : const Color(0xFF94A3B8);
  static Color divider(bool isDark) => isDark ? const Color(0xFF2A2831) : const Color(0xFFE2E8F0);
  static const Color danger = Color(0xFFEF4444);"""
    
    c = re.sub(r'class _SettingsDesign \{.*?\n  static const Color danger = Color\(0xFFEF4444\);', design_str, c, flags=re.DOTALL)

    # 2. Update cardShadow
    shadow_str = """  static List<BoxShadow> cardShadow(bool isDark) => [
    BoxShadow(
      color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];"""
    c = re.sub(r'  static List<BoxShadow> cardShadow = \[.*?\];', shadow_str, c, flags=re.DOTALL)

    # 3. Add _isDark getter to _SettingsPageState
    c = re.sub(
        r'class _SettingsPageState extends State<SettingsPage> \{',
        'class _SettingsPageState extends State<SettingsPage> {\n  bool get _isDark => Theme.of(context).brightness == Brightness.dark;',
        c
    )

    # 4. Replace _SettingsDesign variables with method calls using _isDark
    c = c.replace('_SettingsDesign.surface', '_SettingsDesign.surface(_isDark)')
    c = c.replace('_SettingsDesign.cardBg', '_SettingsDesign.cardBg(_isDark)')
    c = c.replace('_SettingsDesign.textPrimary', '_SettingsDesign.textPrimary(_isDark)')
    c = c.replace('_SettingsDesign.textSecondary', '_SettingsDesign.textSecondary(_isDark)')
    c = c.replace('_SettingsDesign.textMuted', '_SettingsDesign.textMuted(_isDark)')
    c = c.replace('_SettingsDesign.divider', '_SettingsDesign.divider(_isDark)')
    c = c.replace('_SettingsDesign.cardShadow', '_SettingsDesign.cardShadow(_isDark)')

    # 5. Remove `const ` from widgets that now contain method calls
    # We will just find 'const ' and check if it's before a widget constructor that contains _SettingsDesign...
    # The safest way is to remove const from TextStyle, Text, and BoxDecoration globally where _SettingsDesign is present.
    c = re.sub(r'const\s+(TextStyle\([^)]*?_SettingsDesign\.[^)]*?\))', r'\1', c, flags=re.DOTALL)
    c = re.sub(r'const\s+(Text\([^)]*?_SettingsDesign\.[^)]*?\))', r'\1', c, flags=re.DOTALL)
    c = re.sub(r'const\s+(BoxDecoration\([^)]*?_SettingsDesign\.[^)]*?\))', r'\1', c, flags=re.DOTALL)
    c = re.sub(r'const\s+(Icon\([^)]*?_SettingsDesign\.[^)]*?\))', r'\1', c, flags=re.DOTALL)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(c)
    print(f"Updated {file_path}")

fix_settings()
