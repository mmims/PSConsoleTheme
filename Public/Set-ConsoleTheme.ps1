function Set-ConsoleTheme {
    [CmdletBinding(DefaultParameterSetName='ByName')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    Param (
        [Parameter(Mandatory=$false)]
        [switch] $Restart
    )
    DynamicParam {
        if ($PSConsoleTheme.Themes.Count -gt 0) {
            $parameterName = "Name"

            $attributes = New-Object System.Management.Automation.ParameterAttribute
            $attributes.Mandatory = $true
            $attributes.ParameterSetName = 'ByName'
            $attributes.Position = 0

            $attributeColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeColl.Add($attributes)
            $attributeColl.Add((New-Object System.Management.Automation.ValidateSetAttribute($PSConsoleTheme.Themes.Keys)))

            $dynParam = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $attributeColl)
            $paramDict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDict.Add($ParameterName, $dynParam)

            $paramDict
        }
    }
    Process {
        switch ($PSCmdlet.ParameterSetName) {
            Default {
                $Name = $PSBoundParameters['Name']
                Write-Debug "Name = '$Name'"

                if ($Name) {
                    $Script:PSConsoleTheme.User.Theme = $Name
                    $theme = $PSConsoleTheme.Themes[$Name]
                    Set-ColorPalette $theme
                    Set-TokenColorConfiguration $theme.tokens
                    Export-UserConfiguration

                    if ($Restart) {
                        Start-Process ((Get-Process -Id $PID).Path)
                        Exit
                    }
                }
            }
        }
    }
}