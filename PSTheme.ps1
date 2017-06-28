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

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [System.ConsoleColor] $Background,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [System.ConsoleColor] $Foreground,

        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        $InputObject
    )
    foreach ($Object in $InputObject) {
        if($Object.palette) { $Object.palette | Confirm-PaletteObject -ErrorAction Stop }
    }
}

function Confirm-PaletteObject {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        $InputObject
    )
    $InputObject
    foreach ($Color in ([System.ConsoleColor]).GetEnumNames()) {
        if(!($InputObject.$Color -imatch "0x[0-9a-f]{6}")) {
            throw ("Palette color definition {0} is not valid for {1}." -f $InputObject.$Color,$Color)
        }
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
    $config | Confirm-ThemeObject -ErrorAction Stop
    $config
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
'@
}

$Script:PSTheme = @{}
$PSTheme.Version = [System.Version]::new("0.1.0")

LoadThemes