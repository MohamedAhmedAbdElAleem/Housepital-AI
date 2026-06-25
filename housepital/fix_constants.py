import re

def fix_constants():
    file_path = 'lib/features/customer/home/presentation/pages/all_nursing_services_page.dart'
    with open(file_path, 'r', encoding='utf-8') as f:
        c = f.read()

    # line 465: const BoxDecoration
    c = c.replace('const BoxDecoration(\n              color: isDark', 'BoxDecoration(\n              color: isDark')
    
    # line 489: const Text('Filter Services'
    c = c.replace("const Text(\n                      'Filter Services',\n                      style: TextStyle(", 
                  "Text(\n                      'Filter Services',\n                      style: TextStyle(")
    
    # line 333: const Icon(Icons.close_rounded, color: textMuted
    c = c.replace('const Icon(Icons.close_rounded, color: textMuted', 'Icon(Icons.close_rounded, color: textMuted')
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(c)

    file_path = 'lib/features/customer/home/presentation/widgets/nursing_service_card.dart'
    with open(file_path, 'r', encoding='utf-8') as f:
        c = f.read()

    # line 163: const Icon(Icons.schedule_rounded, size: 14, color: textMuted)
    c = c.replace('const Icon(Icons.schedule_rounded, size: 14, color: textMuted)', 'Icon(Icons.schedule_rounded, size: 14, color: textMuted)')
    
    # line 207: const TextStyle( ... color: isDark ? ... )
    c = re.sub(r'const\s+(TextStyle\([^)]*?isDark[^)]*?\))', r'\1', c, flags=re.DOTALL)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(c)

    file_path = 'lib/features/customer/settings/presentation/pages/settings_page.dart'
    with open(file_path, 'r', encoding='utf-8') as f:
        c = f.read()

    # line 1019: const BorderSide(color: _SettingsDesign.divider(_isDark))
    c = c.replace('const BorderSide(color: _SettingsDesign.divider(_isDark))', 'BorderSide(color: _SettingsDesign.divider(_isDark))')

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(c)
        
    print("Fixed constants")

fix_constants()
