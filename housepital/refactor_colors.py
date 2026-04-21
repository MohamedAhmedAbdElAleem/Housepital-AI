import re

file_path = r'F:\Housepital-AI\Housepital-AI\housepital\lib\features\customer\booking\presentation\pages\booking_tracking_page.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add AppColors import
if 'app_colors.dart' not in content:
    content = content.replace(
        "import '../../../../../core/network/api_service.dart';",
        "import '../../../../../core/network/api_service.dart';\nimport '../../../../core/constants/app_colors.dart';"
    )

# Replace Map TileLayer
old_tile = """TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
          userAgentPackageName: 'com.housepital.app',
          maxZoom: 19,
        ),"""
new_tile = """TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.housepital.customer',
          maxZoom: 19,
        ),"""
content = content.replace(old_tile, new_tile)

# Colors replacements mapping
color_map = {
    r'const Color\(0xFF10B981\)': 'AppColors.primary500',
    r'const Color\(0xFF6366F1\)': 'AppColors.secondary500',
    r'const Color\(0xFF0EA5E9\)': 'AppColors.info400',
    r'const Color\(0xFFF59E0B\)': 'AppColors.warning500',
    r'const Color\(0xFF3B82F6\)': 'AppColors.info500',
    r'const Color\(0xFFF1F5F9\)': 'AppColors.light200',
    r'const Color\(0xFF0F172A\)': 'AppColors.dark700',
    r'const Color\(0xFF475569\)': 'AppColors.dark300',
    r'const Color\(0xFFE2E8F0\)': 'AppColors.light400',
    r'const Color\(0xFF64748B\)': 'AppColors.dark200',
    r'const Color\(0xFFF8FAFC\)': 'AppColors.light100',
    r'const Color\(0xFF1E293B\)': 'AppColors.dark600',
    r'const Color\(0xFFECFDF5\)': 'AppColors.success50',
    r'const Color\(0xFFD1FAE5\)': 'AppColors.success100',
    r'const Color\(0xFF065F46\)': 'AppColors.success800',
    r'const Color\(0xFF047857\)': 'AppColors.success700',
    r'const Color\(0xFFCBD5E1\)': 'AppColors.light600',
}

for old, new in color_map.items():
    content = re.sub(old, new, content)

# Write back
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
