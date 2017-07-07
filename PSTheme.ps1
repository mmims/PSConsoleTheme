function Get-PSTheme {
    [CmdletBinding(DefaultParameterSetName='ByName')]
    Param (
        [Parameter(Mandatory=$false,ParameterSetName='Refresh')]
        [switch]$Refresh
    )
    DynamicParam {
        if ($PSTheme.Themes.Count -gt 0) {
            $parameterName = "Name"

            $attributes = New-Object System.Management.Automation.ParameterAttribute
            $attributes.Mandatory = $false
            $attributes.ParameterSetName = 'ByName'
            $attributes.Position = 0

            $attributeColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeColl.Add($attributes)
            $attributeColl.Add((New-Object System.Management.Automation.ValidateSetAttribute($PSTheme.Themes.Keys)))

            $dynParam = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $attributeColl)
            $paramDict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDict.Add($ParameterName, $dynParam)

            $paramDict
        }
    }
    Process {
        switch ($PSCmdlet.ParameterSetName) {
            'Refresh' {
                $PSTheme.Themes = Get-Theme
            }
            Default {
                $Name = $PSBoundParameters['Name']
                Write-Debug "Name = '$Name'"

                if ($Name) {
                    $PSTheme.Themes[$Name]
                } else {
                    $PSTheme.Themes
                }
            }
        }
    }
}

function Set-PSTheme {
    [CmdletBinding(DefaultParameterSetName='ByName')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    Param ()
    DynamicParam {
        if ($PSTheme.Themes.Count -gt 0) {
            $parameterName = "Name"

            $attributes = New-Object System.Management.Automation.ParameterAttribute
            $attributes.Mandatory = $true
            $attributes.ParameterSetName = 'ByName'
            $attributes.Position = 0

            $attributeColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeColl.Add($attributes)
            $attributeColl.Add((New-Object System.Management.Automation.ValidateSetAttribute($PSTheme.Themes.Keys)))

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
                    $theme = $PSTheme.Themes[$Name]
                    Set-ColorPalette $theme.palette
                    Set-TokenColorConfiguration $theme.tokens
                }
            }
        }
    }
}

#-- Private Module Functions --#
function Assert {
    param(
        [Parameter(Position=0, Mandatory=1)]$conditionToCheck,
        [Parameter(Position=1, Mandatory=1)]$failureMessage
    )
    if (!$conditionToCheck) {
        throw("Assert: " + $failureMessage)
    }
}

function Test-Palette {
    param(
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
        [ValidateNotNull()]
        $PaletteObject
    )
    Process {
        $valid = $true
        $missing = @()
        foreach ($color in ([System.ConsoleColor]).GetEnumNames()) {
            if (!(Get-Member $color -InputObject $PaletteObject -MemberType NoteProperty)) {
                $valid = $false
                $missing += $color
            } else {
                if (!($PaletteObject.($color) -imatch "^(?:0x|#)?[\da-f]{6}$")) {
                    throw ($msgs.error_invalid_palette_value -f $color,$PaletteObject.($color))
                }
            }
        }
        if(!$valid) {
            throw ($msgs.error_incomplete_palette -f ($missing -join ", "))
        }
        $valid
    }
}

function Test-Theme {
    param(
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Description,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Repository,

        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [System.ConsoleColor] $Background,

        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [System.ConsoleColor] $Foreground,

        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
        [ValidateSet('RGB','BGR')]
        [string]$PaletteFormat,

        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [System.Object] $Palette,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [PSCustomObject] $Tokens
    )
    Process {
        $true
    }
}

function Import-ThemeConfiguration {
    param(
        [Parameter(Mandatory=1)][string]$configFile
    )
    Assert (Test-Path $configFile -PathType Leaf) ($msgs.error_invalid_path -f $configFile)

    $configJson = (Get-Content $configFile) -join "`n"
    Assert (Test-Json $configJson) ($msgs.error_invalid_json -f $configFile)

    try {
        $config = $configJson | ConvertFrom-Json
        if(($config | Test-Theme) -and ($config.palette | Test-Palette)) {
            return $config
        }
    }
    catch {
        Write-Error (($msgs.error_invalid_config -f $configFile) + "`n" + $_.Exception.Message)
        return $null
    }
}

function Get-BGRValue {
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Value,

        [Parameter(Mandatory=$false,Position=1)]
        [ValidateSet('BGR','RGB')]
        [string]$Format='RGB'
    )

    switch ($Format) {
        'RGB' {
            $replace = '0x$3$2$1'
            break
        }
        Default {
            $replace = '0x$1$2$3'
            break
        }
    }

    $hexString = [regex]::Replace($Value, "^(?:0x|#)?([\da-f]{2})([\da-f]{2})([\da-f]{2})$", $replace, 'IgnoreCase')
    [System.Convert]::ToInt32($hexString, 16)
}

function Get-Theme {
    param(
        [string]$themeDir = "$PSScriptRoot\themes"
    )
    Assert (Test-Path $themeDir -PathType Container) ($msgs.error_invalid_path -f $themeDir)
    $configFiles = Get-ChildItem $themeDir "*.json"

    $themes = @{}
    foreach ($config in $configFiles) {
        $theme = Import-ThemeConfiguration $config.FullName
        if ($theme) {
            if ($themes.ContainsKey($theme.name)) {
                Write-Warning ($msgs.warning_ambiguous_theme -f $theme.name, $config)
                break
            }
            $themes.Add($theme.name, $theme)
        }
    }

    $themes
}

function Set-TokenColorConfiguration {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [Parameter(Mandatory=$true)]
        $TokenColors
    )
    foreach ($token in @("Comment","Keyword","String","Operator","Variable","Command","Parameter","Type","Number","Member")) {
        if (Get-Member $token -InputObject $TokenColors) {
            Set-PSReadlineOption $token -ForegroundColor $TokenColors.($token)
        }
    }
}

function Set-ColorPalette {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [System.Object]$Theme
    )
    $colorTable = @{
        'Black'       = 'ColorTable00'
        'DarkBlue'    = 'ColorTable01'
        'DarkGreen'   = 'ColorTable02'
        'DarkCyan'    = 'ColorTable03'
        'DarkRed'     = 'ColorTable04'
        'DarkMagenta' = 'ColorTable05'
        'DarkYellow'  = 'ColorTable06'
        'Gray'        = 'ColorTable07'
        'DarkGray'    = 'ColorTable08'
        'Blue'        = 'ColorTable09'
        'Green'       = 'ColorTable10'
        'Cyan'        = 'ColorTable11'
        'Red'         = 'ColorTable12'
        'Magenta'     = 'ColorTable13'
        'Yellow'      = 'ColorTable14'
        'White'       = 'ColorTable15'
    }
    $key = 'HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe'
    $palette = $Theme.palette
    $format = 'RGB'
    if (Get-Member paletteFormat -InputObject $Theme -MemberType NoteProperty) {
        $format = $Theme.paletteFormat
    }

    foreach ($color in ([System.ConsoleColor]).GetEnumNames()) {
        if ($colorTable.ContainsKey($color) -and (Get-Member $color -InputObject $palette -MemberType NoteProperty)) {
            $bgrValue = Get-BGRValue $palette.($color) $format
            # Write-Host ("{0} = 0x{1:x6} ({2})" -f $colorTable[$color],$bgrValue,$bgrValue)
            Set-ItemProperty -Path $key -Name $colorTable[$color] -Value $bgrValue -Force
        }
    }
}

function Test-Json {
    param(
        [string]$data
    )
    try {
        ConvertFrom-Json $data -ErrorAction Stop
        $valid = $true
    }
    catch {
        $valid = $false
    }
    $valid
}

DATA msgs {
    ConvertFrom-StringData @'
        error_invalid_json = Invalid JSON data {0}. File not parsed.
        error_invalid_path = Could not find path {0}.
        error_incomplete_palette = Incomplete palette. Missing: {0}.
        error_invalid_palette_value = "{0}" color value {1} is invalid.
        error_invalid_config = Failed to import theme configuration '{0}'.
        warning_ambiguous_theme = Ambiguous theme name '{0}'. Ignoring theme configuration: {1}
'@
}

$Script:PSTheme = @{}
$PSTheme.Version = [System.Version]::new("0.1.0")
$PSTheme.Themes = Get-Theme