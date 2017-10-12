function Get-ConsoleTheme {
    [CmdletBinding(DefaultParameterSetName='ByName')]
    Param (
        [Parameter(Mandatory=$false,ParameterSetName='All')]
        [switch] $All,

        [Parameter(Mandatory=$false,ParameterSetName='Refresh')]
        [switch]$Refresh
    )
    DynamicParam {
        if ($PSConsoleTheme.Themes.Count -gt 0) {
            $parameterName = "Name"

            $attributes = New-Object System.Management.Automation.ParameterAttribute
            $attributes.Mandatory = $false
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
            'All' {
                $PSConsoleTheme.Themes.GetEnumerator() | Sort-Object -Property Name
            }
            'Refresh' {
                $PSConsoleTheme.Themes = Get-Theme
            }
            Default {
                $Name = $PSBoundParameters['Name']
                Write-Debug "Name = '$Name'"

                if ($Name) {
                    $PSConsoleTheme.Themes[$Name]
                } else {
                    $currentTheme = $PSConsoleTheme.User.Theme
                    if ($currentTheme -and ($PSConsoleTheme.Themes.ContainsKey($currentTheme))) {
                        $PSConsoleTheme.Themes[$currentTheme]
                    } else {
                        'No console theme set.'
                    }
                }
            }
        }
    }
}