$file = 'lib\features\customer\profile\presentation\pages\account_page.dart'
$c = Get-Content $file -Raw

# Fix the broken calls from previous scripts (wrong method names -> correct new method names)
$c = $c -replace '_Design\.background\(_isDark\)', '_Design.bgColor(_isDark)'
$c = $c -replace '_Design\.surface\(_isDark\)', '_Design.surfaceColor(_isDark)'
$c = $c -replace '_Design\.surfaceVariant\(_isDark\)', '_Design.surfaceVariantColor(_isDark)'
$c = $c -replace '_Design\.border\(_isDark\)', '_Design.borderColor(_isDark)'
$c = $c -replace '_Design\.textPrimary\(_isDark\)', '_Design.titleColor(_isDark)'
$c = $c -replace '_Design\.textSecondary\(_isDark\)', '_Design.subtitleColor(_isDark)'
$c = $c -replace '_Design\.textMuted\(_isDark\)', '_Design.mutedColor(_isDark)'
$c = $c -replace '_Design\.softShadow\(_isDark\)', '_Design.shadowFor(_isDark)'

# Fix scaffold background
$c = $c -replace 'backgroundColor: _Design\.bgColor\(_isDark\)', 'backgroundColor: _Design.bgColor(_isDark)'

Set-Content $file $c -Encoding UTF8
Write-Host "Done"
