import re

def fix_settings():
    file_path = 'lib/features/customer/settings/presentation/pages/settings_page.dart'
    with open(file_path, 'r', encoding='utf-8') as f:
        c = f.read()

    # Find the class definition and add the getter inside
    c = re.sub(
        r'(class _SettingsPageState extends State<SettingsPage>\s+with TickerProviderStateMixin\s*\{)',
        r'\1\n  bool get _isDark => Theme.of(context).brightness == Brightness.dark;',
        c
    )

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(c)
    print(f"Updated {file_path}")

fix_settings()
