function Export-UserConfiguration {
    param (
        [Parameter(Mandatory=$false)]
        [string] $Path = $env:USERPROFILE,

        [Parameter(Mandatory=$false)]
        [switch] $Reset
    )

    if ($Reset.IsPresent -and $Script:PSConsoleTheme.User.Theme) {
        $Script:PSConsoleTheme.User.Theme = $null
    }

    $configFile = Join-Path $Path '.psconsoletheme'
    ConvertTo-Json $Script:PSConsoleTheme.User | Out-File $configFile -Force
}