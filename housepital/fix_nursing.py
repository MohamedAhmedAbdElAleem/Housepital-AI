import re

def fix_nursing():
    file_path = 'lib/features/customer/home/presentation/pages/all_nursing_services_page.dart'
    with open(file_path, 'r', encoding='utf-8') as f:
        c = f.read()

    c = c.replace('Widget build(BuildContext context) {',
                  'Widget build(BuildContext context) {\n    final isDark = Theme.of(context).brightness == Brightness.dark;\n    final textPrimary = isDark ? Colors.white : const Color(0xFF1A202C);\n    final textMuted = isDark ? const Color(0xFFA19EAB) : const Color(0xFF718096);\n    final surfaceColor = isDark ? const Color(0xFF0D0C11) : const Color(0xFFF0F4F8);\n    final cardBg = isDark ? const Color(0xFF16151A) : Colors.white;\n    final searchBorder = isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(10);')
    c = c.replace('const surfaceColor = Color(0xFFF0F4F8);', '')

    c = c.replace('color: Colors.white,\n                                    borderRadius: BorderRadius.circular(16),\n                                    border: Border.all(color: Colors.black.withAlpha(10)),',
                  'color: cardBg,\n                                    borderRadius: BorderRadius.circular(16),\n                                    border: Border.all(color: searchBorder),')

    c = c.replace('style: const TextStyle(color: Color(0xFF1A202C)', 'style: TextStyle(color: textPrimary')
    c = c.replace('hintStyle: const TextStyle(color: Color(0xFF718096)', 'hintStyle: TextStyle(color: textMuted')
    c = c.replace('color: const Color(0xFF1A202C)', 'color: textPrimary')
    c = c.replace('color: Color(0xFF1A202C)', 'color: textPrimary')
    c = c.replace('color: const Color(0xFF718096)', 'color: textMuted')
    c = c.replace('color: Color(0xFF718096)', 'color: textMuted')

    c = re.sub(r'const\s+(Text\([^)]*?textPrimary[^)]*?\))', r'\1', c, flags=re.DOTALL)
    c = re.sub(r'const\s+(Text\([^)]*?textMuted[^)]*?\))', r'\1', c, flags=re.DOTALL)
    c = re.sub(r'const\s+(TextStyle\([^)]*?textPrimary[^)]*?\))', r'\1', c, flags=re.DOTALL)
    c = re.sub(r'const\s+(TextStyle\([^)]*?textMuted[^)]*?\))', r'\1', c, flags=re.DOTALL)

    c = c.replace('void _showFilterBottomSheet() {', 'void _showFilterBottomSheet(bool isDark) {')
    c = c.replace('_showFilterBottomSheet();', '_showFilterBottomSheet(isDark);')

    c = c.replace('color: Colors.white,\n              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),',
                  'color: isDark ? const Color(0xFF16151A) : Colors.white,\n              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),')
    c = c.replace('color: Colors.grey.shade300,', 'color: isDark ? const Color(0xFF2A2831) : Colors.grey.shade300,')
    c = c.replace("style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold)",
                  "style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)")
    c = c.replace("const Text('Sort By', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600))",
                  "Text('Sort By', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black))")

    c = c.replace('_buildFilterChip(String label, bool isSelected, VoidCallback onTap)',
                  '_buildFilterChip(String label, bool isSelected, bool isDark, VoidCallback onTap)')
    c = c.replace("_buildFilterChip('Recommended', _selectedSort == 'Recommended', () {\n                      setModalState(() => _selectedSort = 'Recommended');\n                    }),",
                  "_buildFilterChip('Recommended', _selectedSort == 'Recommended', isDark, () {\n                      setModalState(() => _selectedSort = 'Recommended');\n                    }),")
    c = c.replace("_buildFilterChip('Price: Low to High', _selectedSort == 'Price: Low to High', () {\n                      setModalState(() => _selectedSort = 'Price: Low to High');\n                    }),",
                  "_buildFilterChip('Price: Low to High', _selectedSort == 'Price: Low to High', isDark, () {\n                      setModalState(() => _selectedSort = 'Price: Low to High');\n                    }),")
    c = c.replace("_buildFilterChip('Price: High to Low', _selectedSort == 'Price: High to Low', () {\n                      setModalState(() => _selectedSort = 'Price: High to Low');\n                    }),",
                  "_buildFilterChip('Price: High to Low', _selectedSort == 'Price: High to Low', isDark, () {\n                      setModalState(() => _selectedSort = 'Price: High to Low');\n                    }),")
    c = c.replace("_buildFilterChip('Highest Rated', _selectedSort == 'Highest Rated', () {\n                      setModalState(() => _selectedSort = 'Highest Rated');\n                    }),",
                  "_buildFilterChip('Highest Rated', _selectedSort == 'Highest Rated', isDark, () {\n                      setModalState(() => _selectedSort = 'Highest Rated');\n                    }),")

    c = c.replace('color: isSelected ? const Color(0xFF2ECC71).withAlpha(20) : Colors.white',
                  'color: isSelected ? const Color(0xFF2ECC71).withAlpha(20) : (isDark ? const Color(0xFF1E1C24) : Colors.white)')
    c = c.replace('color: isSelected ? const Color(0xFF2ECC71) : Colors.grey.shade300',
                  'color: isSelected ? const Color(0xFF2ECC71) : (isDark ? const Color(0xFF2A2831) : Colors.grey.shade300)')
    c = c.replace('color: isSelected ? const Color(0xFF2ECC71) : Colors.black87',
                  'color: isSelected ? const Color(0xFF2ECC71) : (isDark ? Colors.white : Colors.black87)')

    c = c.replace('class _StickyCategoryDelegate extends SliverPersistentHeaderDelegate {',
                  'class _StickyCategoryDelegate extends SliverPersistentHeaderDelegate {\n  final bool isDark;')
    c = c.replace('_StickyCategoryDelegate({\n    required this.categories,',
                  '_StickyCategoryDelegate({\n    required this.isDark,\n    required this.categories,')
    c = c.replace('delegate: _StickyCategoryDelegate(\n              categories:',
                  'delegate: _StickyCategoryDelegate(\n              isDark: isDark,\n              categories:')
    c = c.replace('color: isScrolled ? const Color(0xFFF0F4F8).withAlpha(240) : const Color(0xFFF0F4F8),',
                  'color: isScrolled ? (isDark ? const Color(0xFF0D0C11).withAlpha(240) : const Color(0xFFF0F4F8).withAlpha(240)) : (isDark ? const Color(0xFF0D0C11) : const Color(0xFFF0F4F8)),')
    c = c.replace('color: isSelected ? const Color(0xFF1A202C) : Colors.white,',
                  'color: isSelected ? (isDark ? Colors.white : const Color(0xFF1A202C)) : (isDark ? const Color(0xFF1E1C24) : Colors.white),')
    c = c.replace('color: isSelected ? Colors.white : const Color(0xFF718096),',
                  'color: isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? const Color(0xFFA19EAB) : const Color(0xFF718096)),')

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(c)
    print(f"Updated {file_path}")

def fix_nursing_card():
    file_path = 'lib/features/customer/home/presentation/widgets/nursing_service_card.dart'
    with open(file_path, 'r', encoding='utf-8') as f:
        c = f.read()

    c = c.replace('const textPrimary = Color(0xFF1A202C);',
                  'final isDark = Theme.of(context).brightness == Brightness.dark;\n    final textPrimary = isDark ? Colors.white : const Color(0xFF1A202C);')
    c = c.replace('const textMuted = Color(0xFFA0AEC0);',
                  'final textMuted = isDark ? const Color(0xFFA19EAB) : const Color(0xFFA0AEC0);\n    final cardBg = isDark ? const Color(0xFF16151A) : Colors.white;')
    c = c.replace('color: Colors.white,\n          borderRadius: BorderRadius.circular(28),',
                  'color: cardBg,\n          borderRadius: BorderRadius.circular(28),')
    
    c = re.sub(r'const\s+(TextStyle\([^)]*?(?:textPrimary|textMuted)[^)]*?\))', r'\1', c, flags=re.DOTALL)
    
    c = c.replace('color: textPrimary,\n                                  borderRadius',
                  'color: isDark ? Colors.white : textPrimary,\n                                  borderRadius')
    c = c.replace('color: Colors.white,\n                                        height: 1.0,',
                  'color: isDark ? const Color(0xFF1A202C) : Colors.white,\n                                        height: 1.0,')
    c = c.replace('color: Colors.white.withAlpha(200),\n                                        height: 1.2,',
                  'color: (isDark ? const Color(0xFF1A202C) : Colors.white).withAlpha(200),\n                                        height: 1.2,')

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(c)
    print(f"Updated {file_path}")

fix_nursing()
fix_nursing_card()
