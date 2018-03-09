#.ExternalHelp PSConsoleTheme-help.xml
function Get-ConsoleTheme {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    Param (
        [Parameter(Mandatory = $false, ParameterSetName = 'Available')]
        [switch] $ListAvailable,

        [Parameter(Mandatory = $false, ParameterSetName = 'Refresh')]
        [switch]$Refresh
    )
    DynamicParam {
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
    Begin {
        if ($PSConsoleTheme.Debug) {
            $oldVerbose = $DebugPreference
            $DebugPreference = 'Continue'
        }
    }
    Process {
        switch ($PSCmdlet.ParameterSetName) {
            'Available' {
                $PSConsoleTheme.Themes.GetEnumerator() | Sort-Object -Property Name | `
                    Format-Table Name, @{Label = "Description"; Expression = {$_.Value.description}}
            }
            'Refresh' {
                $PSConsoleTheme.Themes = Get-Theme
            }
            Default {
                $Name = $PSBoundParameters['Name']

                if ($Name) {
                    $PSConsoleTheme.Themes[$Name]
                }
                else {
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
    End {
        if ($PSConsoleTheme.Debug) {
            $DebugPreference = $oldVerbose
        }
    }
}