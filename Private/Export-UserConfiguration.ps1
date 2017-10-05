function Export-UserConfiguration {
    param (
        [Parameter(Mandatory=$false)]
        [string] $Path = $env:USERPROFILE
    )

    $configFile = Join-Path $Path '.psconsoletheme'
    ConvertTo-Json $Script:PSConsoleTheme.User | Out-File $configFile -Force
}