function Test-Json {
    param(
        [string]$data
    )
    try {
        ConvertFrom-Json $data -ErrorAction Stop
        $valid = $true
    }
    catch {
        $valid = $false
    }
    $valid
}