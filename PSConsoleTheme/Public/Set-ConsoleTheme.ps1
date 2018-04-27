#.ExternalHelp PSConsoleTheme-help.xml
function Set-ConsoleTheme {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    Param (
        [Parameter(Mandatory = $false, ParameterSetName = 'Reset')]
        [switch] $Reset,

        [Parameter(Mandatory = $false)]
        [switch] $Session
    )

    DynamicParam {
        if (!$PSConsoleTheme.ThemesLoaded) {
            $PSConsoleTheme.Themes = Get-Theme
        }

        if ($PSConsoleTheme.Themes.Count -gt 0) {
            $parameterName = 'Name'

            $attributes = New-Object System.Management.Automation.ParameterAttribute
            $attributes.Mandatory = $false
            $attributes.ParameterSetName = 'ByName'
            $attributes.Position = 0
            $attributes.HelpMessage = 'Specifies the name of the theme to set the console colors.'

            $attributeColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeColl.Add($attributes)
            $attributeColl.Add((New-Object System.Management.Automation.ValidateSetAttribute($PSConsoleTheme.Themes.Keys | Sort-Object)))

            $dynParam = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $attributeColl)
            $paramDict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDict.Add($ParameterName, $dynParam)

            $paramDict
        }
    }

    Process {
        switch ($PSCmdlet.ParameterSetName) {
            'Reset' {
                if ($Reset.IsPresent) {
                    Set-ColorPalette -Reset -Session:$Session
                    Set-TokenColorConfiguration -Reset

                    if (!$Session) {
                        Export-UserConfiguration -Reset
                    }
                }
            } Default {
                $Name = $PSBoundParameters['Name']

                if ($Name) {
                    $theme = $PSConsoleTheme.Themes[$Name]
                    $Script:PSConsoleTheme.User.Theme = $Name
                    $Script:PSConsoleTheme.User.Path = $theme.path

                    try {
                        if (($theme | Test-Theme) -and ($theme.palette | Test-Palette)) {
                            Set-ColorPalette $theme -Session:$Session
                            Set-TokenColorConfiguration $theme
                        }
                    }
                    catch {
                        Write-Error (("Invalid theme configuration for '{0}'." -f $theme.Name) + "`n" + $_)
                        return
                    }

                    if (!$Session) {
                        Export-UserConfiguration
                    }
                }
            }
        }
    }
}