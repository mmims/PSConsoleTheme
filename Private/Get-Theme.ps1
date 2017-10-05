function Get-Theme {
    param(
        [string] $themeDir = "$PSScriptRoot\..\themes"
    )
    Assert (Test-Path $themeDir -PathType Container) ($theme_msgs.error_invalid_path -f $themeDir)
    $configFiles = Get-ChildItem $themeDir "*.json"

    $themes = @{}
    foreach ($config in $configFiles) {
        try
        {
            $theme = Import-ThemeConfiguration $config.FullName -ErrorAction Stop
            if ($theme) {
                if ($themes.ContainsKey($theme.name)) {
                    Write-Warning ($theme_msgs.warning_ambiguous_theme -f $theme.name, $config)
                    break
                }
                $themes.Add($theme.name, $theme)
            }
        } catch {
            Write-Warning $_
        }
    }

    $themes
}

DATA theme_msgs {
    ConvertFrom-StringData @'
        error_invalid_path = Could not find path {0}.
        warning_ambiguous_theme = Ambiguous theme name '{0}'. Ignoring theme configuration: {1}
'@
}