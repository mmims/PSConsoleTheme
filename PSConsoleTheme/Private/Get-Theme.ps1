function Get-Theme {
    param(
        [string[]] $ThemePath = $null
    )

    if ($ThemePath -eq $null) {
        $ThemePath = @(
            Resolve-Path "$HOME\.psconsoletheme\themes" -ErrorAction Ignore
            Resolve-Path "$env:ALLUSERSPROFILE\.psconsoletheme\themes" -ErrorAction Ignore
            Resolve-Path "$PSScriptRoot\..\themes"
        )
    }

    $themes = @{}
    foreach ($path in $ThemePath) {
        $configFiles = Get-ChildItem $path "*.json"
    
        $processed = 0
        foreach ($config in $configFiles) {
            try
            {
                $theme = Import-ThemeConfiguration $config.FullName -ErrorAction Stop
                if ($theme) {
                    if ($themes.ContainsKey($theme.name)) {
                        Write-Warning ($theme_msgs.warning_ambiguous_theme -f $theme.name, $config.FullName)
                        break
                    }
                    $themes.Add($theme.name, $theme)
                    $processed++
                }
            } catch {
                Write-Warning $_
            }
        }
    }

    $themes
}

DATA theme_msgs {
    ConvertFrom-StringData @'
        error_invalid_path = Could not find path {0}.
        warning_ambiguous_theme = Ambiguous theme name '{0}'. Ignoring {1}
'@
}