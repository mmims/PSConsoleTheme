# Get public and private functions
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# dot source files
foreach ($import in @($Public + $Private)) {
    try {
        Write-Host "dot sourcing '$($import.Fullname)'..." -NoNewline
        . $import.FullName
    }
    catch {
        Write-Host "failed!"
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
    Write-Host "success!"
}

$manifest = Test-ModuleManifest (Join-Path $PSScriptRoot 'PSTheme.psd1') -WarningAction SilentlyContinue

# Create PSTheme object
$Script:PSTheme = @{}
$PSTheme.Version = $manifest.Version # [System.Version]::new("0.1.0")
$PSTheme.Themes = Get-Theme

# Export module functions
Export-ModuleMember -Function $Public.BaseName -Variable 'PSTheme'