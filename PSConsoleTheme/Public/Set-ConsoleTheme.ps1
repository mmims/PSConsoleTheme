function Set-ConsoleTheme {
    [CmdletBinding(DefaultParameterSetName='ByName')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    Param (
        [Parameter(Mandatory=$false,ParameterSetName='Clear',HelpMessage='Clears the current theme colors and reverts o the default system colors.')]
        [switch] $Clear,

        [Parameter(Mandatory=$false,HelpMessage='Restarts the console immediately after changing the color theme.')]
        [switch] $Restart
    )
    DynamicParam {
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
            'Clear' {
                if ($Clear.IsPresent) {
                    Set-ColorPalette -Reset
                    # Set-TokenColorConfiguration -Reset
                    Export-UserConfiguration -Reset
                }
            } Default {
                $Name = $PSBoundParameters['Name']
                Write-Debug "Name = '$Name'"

                if ($Name) {
                    $Script:PSConsoleTheme.User.Theme = $Name
                    $theme = $PSConsoleTheme.Themes[$Name]
                    try {
                        if(($theme | Test-Theme) -and ($theme.palette | Test-Palette)) {
                            Set-ColorPalette $theme
                            Set-TokenColorConfiguration $theme.tokens
                            Export-UserConfiguration
                        }
                    } catch {
                        Write-Error (("Invalid theme configuration for '{0}'." -f $theme.Name) + "`n" + $_)
                    }
                }
            }
        }

        if ($Restart.IsPresent) {
            Start-Process ((Get-Process -Id $PID).Path) -ArgumentList -NoLogo
            Exit
        }
    }
}