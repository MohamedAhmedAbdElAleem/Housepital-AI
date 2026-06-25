$file = 'lib\features\customer\profile\presentation\pages\account_page.dart'
$c = Get-Content $file -Raw

# Fix _buildTextField references (non-const static field refs)
$c = $c -replace 'color: readOnly \? _Design\.textMuted : _Design\.textPrimary,', 'color: readOnly ? _Design.textMuted(_isDark) : _Design.textPrimary(_isDark),'
$c = $c -replace 'color: _Design\.textMuted,\s*\n(\s*fontSize: 14,)', "color: _Design.textMuted(_isDark),`n`$1"
$c = $c -replace 'color: readOnly \? _Design\.textMuted : _Design\.primary,', 'color: readOnly ? _Design.textMuted(_isDark) : _Design.primary,'
$c = $c -replace 'fillColor: readOnly \? _Design\.surfaceVariant : _Design\.background,', 'fillColor: readOnly ? _Design.surfaceVariant(_isDark) : _Design.background(_isDark),'
$c = $c -replace 'BorderSide\(color: _Design\.border\.withOpacity\(0\.5\)\)', 'BorderSide(color: _Design.border(_isDark).withOpacity(0.5))'
$c = $c -replace 'color: _Design\.surfaceVariant,\s*\n(\s*borderRadius)', "color: _Design.surfaceVariant(_isDark),`n`$1"
$c = $c -replace 'border: Border\.all\(color: _Design\.border\.withOpacity\(0\.5\)\)', 'border: Border.all(color: _Design.border(_isDark).withOpacity(0.5))'

# Password field text & label colors
$c = $c -replace "style: const TextStyle\(fontSize: 15, color: _Design\.textPrimary\),", "style: TextStyle(fontSize: 15, color: _Design.textPrimary(_isDark)),"
$c = $c -replace "labelStyle: const TextStyle\(fontSize: 14, color: _Design\.textSecondary\),", "labelStyle: TextStyle(fontSize: 14, color: _Design.textSecondary(_isDark)),"
$c = $c -replace 'fillColor: _Design\.surface,', 'fillColor: _Design.surface(_isDark),'
$c = $c -replace 'color: _Design\.textMuted,\s*\n(\s*size: 20,)', "color: _Design.textMuted(_isDark),`n`$1"

# _buildSecurityItem title/subtitle
$c = $c -replace 'color: _Design\.textPrimary,\s*\n(\s*\},)', "color: _Design.textPrimary(_isDark),`n`$1"
$c = $c -replace 'color: _Design\.textSecondary,\s*\n(\s*letterSpacing: 2,)', "color: _Design.textSecondary(_isDark),`n`$1"

# Password change form bg
$c = $c -replace 'color: _Design\.surfaceVariant,\s*\n(\s*borderRadius: BorderRadius\.circular\(16\))', "color: _Design.surfaceVariant(_isDark),`n`$1"

# Password form title/subtitle
$c = $c -replace "const Text\(\s*\n(\s*)'Create a strong password',\s*\n(\s*)style: TextStyle\(\s*\n(\s*)fontSize: 14,\s*\n(\s*)fontWeight: FontWeight\.w600,\s*\n(\s*)color: _Design\.textPrimary,", "Text(`n`$1'Create a strong password',`n`$2style: TextStyle(`n`$3fontSize: 14,`n`$4fontWeight: FontWeight.w600,`n`$5color: _Design.textPrimary(_isDark),"
$c = $c -replace "const Text\(\s*\n(\s*)'At least 6 characters with letters and numbers',\s*\n(\s*)style: TextStyle\(fontSize: 12, color: _Design\.textSecondary\)", "Text(`n`$1'At least 6 characters with letters and numbers',`n`$2style: TextStyle(fontSize: 12, color: _Design.textSecondary(_isDark))"

# _buildInfoRow - label and value colors
$c = $c -replace 'color: _Design\.textSecondary,\s*\n(\s*\},)', "color: _Design.textSecondary(_isDark),`n`$1"
$c = $c -replace 'color: valueColor \?\? _Design\.textPrimary,', 'color: valueColor ?? _Design.textPrimary(_isDark),'
$c = $c -replace "fontFamily: 'monospace',\s*\n(\s*)fontSize: 13,\s*\n(\s*)color: _Design\.textSecondary,", "fontFamily: 'monospace',`n`$1fontSize: 13,`n`$2color: _Design.textSecondary(_isDark),"

# Bottom sheet (image picker)
$c = $c -replace 'color: Colors\.white,\s*\n(\s*)borderRadius: BorderRadius\.vertical\(top: Radius\.circular\(28\)\),', "color: _Design.surface(_isDark),`n`$1borderRadius: BorderRadius.vertical(top: Radius.circular(28)),"
$c = $c -replace 'color: Colors\.grey\[300\],\s*\n(\s*)borderRadius: BorderRadius\.circular\(2\)', "color: _isDark ? const Color(0xFF2A2831) : Colors.grey[300],`n`$1borderRadius: BorderRadius.circular(2)"
$c = $c -replace "color: _Design\.textPrimary,\s*\n(\s*\},\s*\n\s*\),\s*\n\s*const SizedBox\(height: 24\),\s*\n\s*\/\/ Options)", "color: _Design.textPrimary(_isDark),`n`$1},`n),`nconst SizedBox(height: 24),`n// Options"
$c = $c -replace "color: _Design\.textPrimary,\s*\n(\s*\},\s*\n\s*\),\s*\n\s*\],)", "color: _Design.textPrimary(_isDark),`n`$1},"

Set-Content $file $c -Encoding UTF8
Write-Host "Done"
