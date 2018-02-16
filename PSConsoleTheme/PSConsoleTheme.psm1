# Get public and private functions
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# dot source files
foreach ($import in @($Public + $Private)) {
    try {
        # Write-Host "dot sourcing '$($import.Fullname)'..." -NoNewline
        . $import.FullName
    }
    catch {
        # Write-Host "failed!"
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
    # Write-Host "success!"
}

$manifest = Test-ModuleManifest (Join-Path $PSScriptRoot 'PSConsoleTheme.psd1') -WarningAction SilentlyContinue

# Create PSConsoleTheme object
$Script:PSConsoleTheme = @{}
$PSConsoleTheme.Version = $manifest.Version
$PSConsoleTheme.Themes = Get-Theme "$PSScriptRoot\base16-themes-json"

# Import user configuration
$PSConsoleTheme.User = Import-UserConfiguration

# Export module functions
Export-ModuleMember -Function $Public.BaseName #-Variable 'PSConsoleTheme'