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

    $defaultDisplaySet = 'Name', 'Description'
    $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
    $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)

    foreach ($path in $ThemePath) {
        $configFiles = Get-ChildItem $path "*.json"

        foreach ($config in $configFiles) {
            try
            {
                $theme = Import-ThemeConfiguration $config.FullName -ErrorAction Stop
                if ($theme) {
                    if ($themes.ContainsKey($theme.name)) {
                        Write-Warning ($theme_msgs.warning_ambiguous_theme -f $theme.name, $config.FullName)
                        break
                    }
                    $theme | Add-Member path $config.FullName
                    $theme | Add-Member MemberSet PSStandardMembers $PSStandardMembers
                    $theme.PSObject.TypeNames.Insert(0, 'PSConsoleTheme.Theme')
                    $themes.Add($theme.name, $theme)
                }
            } catch {
                Write-Warning $_
            }
        }
    }
    $Script:PSConsoleTheme.ThemesLoaded = $true

    $themes
}

DATA theme_msgs {
    ConvertFrom-StringData @'
        error_invalid_path = Could not find path {0}.
        warning_ambiguous_theme = Ambiguous theme name '{0}'. Ignoring {1}
'@
}