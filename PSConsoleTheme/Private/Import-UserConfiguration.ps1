function Import-UserConfiguration {
    param (
        [Parameter(Mandatory=$false)]
        [string] $Path = $Script:PSConsoleTheme.ProfilePath
    )

    $configFile = Join-Path $Path 'config.json'
    if (Test-Path $configFile) {
        $configJson = Get-Content $configFile -Raw
        if (!(Test-Json $configJson)) {
            return @{}
        }

        try {
            $config = $configJson | Remove-JsonComments | ConvertFrom-Json
            if ($config | Test-User) {
                if ($config.Path) {
                    try {
                        $theme = Import-ThemeConfiguration $config.Path -ErrorAction Stop
                        $theme | Add-Member path $config.Path
                        $Script:PSConsoleTheme.Themes.Add($theme.name, $theme)
                        Set-TokenColorConfiguration $theme
                    } catch {
                        Write-Warning $_
                    }
                } else {
                    $config | Add-Member Path $null -Force
                    if ($config.Theme) {
                        if (!$Script:PSConsoleTheme.ThemesLoaded) {
                            $Script:PSConsoleTheme.Themes = Get-Theme
                        }
                        if ($Script:PSConsoleTheme.Themes.Contains($config.Theme)) {
                            Set-TokenColorConfiguration $Script:PSConsoleTheme.Themes[$config.Theme]
                        }
                    }
                }

                return $config
            }
        }
        catch {
            Write-Error (($user_config_msgs.error_invalid_config -f $configFile) + "`n" + $_)
            return @{}
        }
    }

    return @{}
}

DATA user_config_msgs {
    ConvertFrom-StringData @'
        error_invalid_json = Invalid JSON data {0}. File not parsed.
        error_invalid_config = Failed to import user configuration '{0}'.
'@
}