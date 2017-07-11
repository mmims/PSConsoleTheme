function Import-ThemeConfiguration {
    param(
        [Parameter(Mandatory=1)][string]$configFile
    )
    Assert (Test-Path $configFile -PathType Leaf) ($import_msgs.error_invalid_path -f $configFile)

    $configJson = (Get-Content $configFile) -join "`n"
    Assert (Test-Json $configJson) ($import_msgs.error_invalid_json -f $configFile)

    try {
        $config = $configJson | ConvertFrom-Json
        if(($config | Test-Theme) -and ($config.palette | Test-Palette)) {
            return $config
        }
    }
    catch {
        Write-Error (($import_msgs.error_invalid_config -f $configFile) + "`n" + $_)
        return $null
    }
}

DATA import_msgs {
    ConvertFrom-StringData @'
        error_invalid_json = Invalid JSON data {0}. File not parsed.
        error_invalid_path = Could not find path {0}.
        error_invalid_config = Failed to import theme configuration '{0}'.
'@
}