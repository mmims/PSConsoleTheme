function Get-RGBValues {
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [string] $Value,

        [Parameter(Mandatory=$false,Position=1)]
        [ValidateSet('BGR','RGB')]
        [string] $Format='RGB'
    )

    $result = @(0, 0, 0)
    $match = [regex]::Match($Value, "^(?:0x|#)?([\da-f]{2})([\da-f]{2})([\da-f]{2})$", 'IgnoreCase')
    if ($match.Success -and ($match.Groups.Count -eq 4)) {
        switch ($Format) {
            'RGB' {
                $result = @($match.Groups[1].Value, $match.Groups[2].Value, $match.Groups[3].Value)
                break
            }
            Default {
                $result = @($match.Groups[3].Value, $match.Groups[2].Value, $match.Groups[1].Value)
                break
            }
        }
    }

    $result
}