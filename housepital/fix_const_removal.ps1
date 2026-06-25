$file = 'lib\features\customer\profile\presentation\pages\account_page.dart'
$c = Get-Content $file -Raw

# Remove 'const' from Text() and TextStyle() that contain dynamic _Design method calls
# Pattern: const Text( ... _Design.xxxColor(_isDark)... ) -> Text(...)
# We need to remove 'const' before Text/TextStyle when _isDark methods are inside

# Fix: "const Text(\n  'Cannot change',\n  style: TextStyle(fontSize: 11, color: _Design.mutedColor(_isDark)),"
$c = $c -replace "const Text\(\r\n(\s*)'Cannot change',\r\n(\s*)style: TextStyle\(fontSize: 11, color: _Design\.mutedColor\(_isDark\)\)\r\n", "Text(`r`n`$1'Cannot change',`r`n`$2style: TextStyle(fontSize: 11, color: _Design.mutedColor(_isDark))`r`n"

# Fix: const TextStyle( ... color: _Design.subtitleColor(_isDark) ) -> remove const
$c = $c -replace 'const TextStyle\((\r\n\s*fontSize: 13,\r\n\s*fontWeight: FontWeight\.w6\d+,\r\n\s*color: _Design\.(subtitleColor|titleColor|mutedColor)\(_isDark\))', 'TextStyle($1'

# Fix: style: TextStyle(fontSize: 11, color: _Design.mutedColor(_isDark))
# (already a non-const call, should be fine)

# Fix all remaining: const TextStyle( ... color: _Design.xxxColor... )
$c = $c -replace 'const (TextStyle\([^)]*_Design\.(titleColor|subtitleColor|mutedColor|borderColor|surfaceColor|bgColor|surfaceVariantColor)\(_isDark\))', '$1'

# Also fix: "style: const TextStyle(\n fontSize:...\n color: _Design..."
$c = $c -replace 'style: const (TextStyle\()(\r\n)(\s+fontSize)', 'style: $1$2$3fontSize'
# That won't work well. Let's do it more carefully per occurrence.

# Simpler: replace all "const TextStyle" that have _isDark inside on any following lines
# We'll use -replace with multiline
$c = [regex]::Replace($c, 'const (TextStyle\((?:[^)]|\r\n)*?_Design\.\w+\(_isDark\)(?:[^)]|\r\n)*?\))', '$1', [System.Text.RegularExpressions.RegexOptions]::Singleline)

# Fix const Text with dynamic style
$c = [regex]::Replace($c, 'const (Text\((?:[^)]|\r\n)*?_Design\.\w+\(_isDark\)(?:[^)]|\r\n)*?\),)', '$1', [System.Text.RegularExpressions.RegexOptions]::Singleline)

Set-Content $file $c -Encoding UTF8
Write-Host "Done"
