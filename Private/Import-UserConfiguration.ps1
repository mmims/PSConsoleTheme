function Import-UserConfiguration {
    param (
        [Parameter(Mandatory=$false)]
        [string] $Path = $env:USERPROFILE
    )

    $configFile = Join-Path $Path '.psconsoletheme'
    if (Test-Path $configFile) {
        $configJson = (Get-Content $configFile) -join "`n"
        Assert (Test-Json $configJson) ($user_config_msgs.error_invalid_json -f $configFile)

        try {
            $config = $configJson | ConvertFrom-Json
            if($config | Test-User) {
                Set-TokenColorConfiguration $Script:PSConsoleTheme.Themes[$config.Theme].tokens
                return $config
            }
        }
        catch {
            Write-Error (($user_config_msgs.error_invalid_config -f $configFile) + "`n" + $_)
            return $null
        }
    }
}

DATA user_config_msgs {
    ConvertFrom-StringData @'
        error_invalid_json = Invalid JSON data {0}. File not parsed.
        error_invalid_config = Failed to import user configuration '{0}'.
'@
}