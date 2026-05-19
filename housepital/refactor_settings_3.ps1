$file = 'lib\features\customer\settings\presentation\pages\settings_page.dart'
$c = Get-Content $file -Raw

# Remove any stray "isDark: " in settings_page.dart (the obsolete_colon_for_default_value error)
$c = $c -replace 'isDark: ,?', ''
$c = $c -replace 'isDark: _isDark,?', ''
$c = $c -replace 'isDark: ', ''

# Remove 'const' before any widget that contains _isDark or _SettingsDesign
$c = [regex]::Replace($c, 'const ([\w<>]+\((?:[^)]|\r\n)*?_SettingsDesign\.(?:textPrimary|textSecondary|textMuted|surface|cardBg|divider|cardShadow)\(_isDark\)(?:[^)]|\r\n)*?\))', '$1', [System.Text.RegularExpressions.RegexOptions]::Singleline)

# Let's just remove ALL `const ` before words that have `_SettingsDesign` inside their parentheses. This can be tricky with regex.
# A simpler way is to just do a global replace of "const " to "" on lines that contain _isDark or _SettingsDesign.
$lines = $c -split "`r`n"
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match '_SettingsDesign\.' -and $lines[$i] -match 'const ') {
        $lines[$i] = $lines[$i] -replace 'const ', ''
    }
    if ($lines[$i] -match '_isDark' -and $lines[$i] -match 'const ') {
        $lines[$i] = $lines[$i] -replace 'const ', ''
    }
}
$c = $lines -join "`r`n"

# But what if the const is on a previous line?
# For example: 
# const TextStyle(
#   color: _SettingsDesign.textPrimary(_isDark)
# )
# In this case, we can use a multi-line regex.
$c = [regex]::Replace($c, 'const (\w+\([^)]*?_SettingsDesign\.[^)]*?\))', '$1', [System.Text.RegularExpressions.RegexOptions]::Singleline)

Set-Content $file $c -Encoding UTF8
Write-Host "Done"
