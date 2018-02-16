function Import-ThemeConfiguration {
    param(
        [Parameter(Mandatory=1)][string]$configFile
    )
    Assert (Test-Path $configFile -PathType Leaf) ($theme_config_msgs.error_invalid_path -f $configFile)

    try {
        $configJson = Get-Content $configFile -Raw
        $configJson | ConvertFrom-Json
    } catch [System.ArgumentException] {
        $configJson | Remove-JsonComments | ConvertFrom-Json
    } catch {
        Write-Error (($theme_config_msgs.error_invalid_config -f $configFile) + "`n" + $_)
        return $null
    }
}

DATA theme_config_msgs {
    ConvertFrom-StringData @'
        error_invalid_json = Invalid JSON data {0}. File not parsed.
        error_invalid_path = Could not find path {0}.
        error_invalid_config = Failed to import theme configuration '{0}'.
'@
}