function Test-Json {
    param(
        [string] $data
    )
    try {
        Remove-JsonComments $data | ConvertFrom-Json -ErrorAction Stop
        $valid = $true
    }
    catch {
        $valid = $false
    }
    $valid
}