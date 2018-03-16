function Export-UserConfiguration {
    param (
        [Parameter(Mandatory=$false)]
        [string] $Path = $Script:PSConsoleTheme.ProfilePath,

        [Parameter(Mandatory=$false)]
        [switch] $Reset
    )

    if ($Reset.IsPresent -and $Script:PSConsoleTheme.User.Theme) {
        $Script:PSConsoleTheme.User.Theme = $null
    }

    $configFile = Join-Path $Path 'config.json'
    if (!(Test-Path $Path -PathType Container)) {
        New-Item $Path -ItemType Directory
    }

    ConvertTo-Json $Script:PSConsoleTheme.User | Out-File $configFile -Force
}