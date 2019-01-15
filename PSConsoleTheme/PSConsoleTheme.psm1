# Get public and private functions
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# dot source files
foreach ($import in @($Public + $Private)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

$manifest = Test-ModuleManifest (Join-Path $PSScriptRoot 'PSConsoleTheme.psd1') -WarningAction SilentlyContinue

# Create PSConsoleTheme object
$Script:PSConsoleTheme = @{}
$PSConsoleTheme.ProfilePath = Join-Path $env:USERPROFILE '.psconsoletheme'
$PSConsoleTheme.Version = $manifest.Version
$PSConsoleTheme.Themes = @{}
$PSConsoleTheme.ThemesLoaded = $false

# Import user configuration
$PSConsoleTheme.User = Import-UserConfiguration

# Export module functions
Export-ModuleMember -Function $Public.BaseName

# Debugging session exports
if ($null -ne ($session = $Global:PSConsoleThemeDebugSessionPath) -and $PSScriptRoot -eq $session) {
    Write-Warning "Module loaded in debugging mode from $session"
    Export-ModuleMember -Variable 'PSConsoleTheme'
    Export-ModuleMember -Variable 'PSColorMap'
    Export-ModuleMember -Variable 'AnsiColorMap'
    Export-ModuleMember -Variable 'CmdColorMap'
    Export-ModuleMember -Function Out-Colors
    $DebugPreference = 'Continue'
}