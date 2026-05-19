$file = 'lib\features\customer\profile\presentation\pages\account_page.dart'
$lines = Get-Content $file

# Fix specific line numbers (1-indexed)
$lines[405] = $lines[405] -replace '_Design\.surfaceVariant,', '_Design.surfaceVariant(_isDark),'
$lines[584] = $lines[584] -replace '_Design\.textMuted\b', '_Design.textMuted(_isDark)'
$lines[667] = $lines[667] -replace '_Design\.textSecondary,', '_Design.textSecondary(_isDark),'
$lines[737] = $lines[737] -replace '_Design\.border\.withOpacity', '_Design.border(_isDark).withOpacity'
$lines[830] = $lines[830] -replace '_Design\.textPrimary,', '_Design.textPrimary(_isDark),'
$lines[1059] = $lines[1059] -replace '_Design\.textSecondary,', '_Design.textSecondary(_isDark),'
$lines[1162] = $lines[1162] -replace '_Design\.textPrimary,', '_Design.textPrimary(_isDark),'
$lines[1246] = $lines[1246] -replace '_Design\.textPrimary,', '_Design.textPrimary(_isDark),'

Set-Content $file $lines -Encoding UTF8
Write-Host "Done"
