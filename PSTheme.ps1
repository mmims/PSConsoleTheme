function Get-PSTheme {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string] $Name,

        [switch] $Full
    )
    if ([System.String]::IsNullOrEmpty($Name)) {
        $PSTheme.Themes
    } else {
        foreach ($theme in $PSTheme.Themes) {
            if ($theme.name -like $Name) {
                $theme
                break
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

function Confirm-PaletteObject {
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
                if (!($PaletteObject.($color) -imatch "[0x|#]?[\da-f]{6}")) {
                    throw ($msgs.error_invalid_palette_value -f $color,$PaletteObject.($color))
                }
            }
        }
        if(!$valid) {
            throw ($msgs.error_incomplete_palette -f ($missing -join ", "))
        }
    }
}

function Confirm-ThemeObject {
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

function LoadThemeConfiguration {
    param(
        [Parameter(Mandatory=1)][string]$configFile
    )
    Assert (Test-Path $configFile -PathType Leaf) ($msgs.error_invalid_path -f $configFile)

    $configJson = (Get-Content $configFile) -join "`n"
    Assert (Test-Json $configJson) ($msgs.error_invalid_json -f $configFile)

    $config = $configJson | ConvertFrom-Json
    if($config | Confirm-ThemeObject -ErrorAction Continue) {
        $PSTheme.Themes += $config
    }
}

function LoadThemes {
    param(
        [string]$themeDir = "$PSScriptRoot\themes"
    )
    Assert (Test-Path $themeDir -PathType Container) ($msgs.error_invalid_path -f $themeDir)
    $themeFiles = Get-ChildItem $themeDir "*.json"

    foreach ($theme in $themeFiles) {
        Write-Host $theme.Name
        LoadThemeConfiguration $theme.FullName
    }
}

function Set-TokenColors {
    param(
        $TokenColors
    )
    foreach ($token in @("Comment","Keyword","String","Operator","Variable","Command","Parameter","Type","Number","Member")) {
        if (Get-Member $token -InputObject $TokenColors) {
            Set-PSReadlineOption $token -ForegroundColor $TokenColors.($token)
        }
    }
}

function Set-PaletteColors {
    param(
        $PaletteColors
    )

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
'@
}

$Script:PSTheme = @{}
$PSTheme.Version = [System.Version]::new("0.1.0")
$PSTheme.Themes = @()

LoadThemes