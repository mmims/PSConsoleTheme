#.ExternalHelp PSConsoleTheme-help.xml
function Get-ConsoleTheme {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    Param (
        [Parameter(Mandatory = $false, ParameterSetName = 'Available')]
        [switch] $ListAvailable,

        [Parameter(Mandatory = $false, ParameterSetName = 'Refresh')]
        [switch] $Refresh,

        [Parameter(Mandatory = $false, ParameterSetName = 'ByName')]
        [switch] $ShowColors
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
            'Available' {
                $PSConsoleTheme.Themes.GetEnumerator() | Sort-Object -Property Name | Foreach-Object { $_.Value }
            }
            'Refresh' {
                $PSConsoleTheme.Themes = Get-Theme
            }
            Default {
                $Name = $PSBoundParameters['Name']

                if ($Name) {
                    $PSConsoleTheme.Themes[$Name] | Select-Object *
                }
                else {
                    if ($ShowColors) {
                        Out-Colors
                        return
                    }

                    $currentTheme = $PSConsoleTheme.User.Theme
                    if ($currentTheme -and ($PSConsoleTheme.Themes.ContainsKey($currentTheme))) {
                        $PSConsoleTheme.Themes[$currentTheme]
                    }
                    else {
                        'No console theme set.'
                    }
                }
            }
        }
    }
}