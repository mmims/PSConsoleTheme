function Get-BGRValue {
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [string] $Value,

        [Parameter(Mandatory=$false,Position=1)]
        [ValidateSet('BGR','RGB')]
        [string] $Format='RGB'
    )

    switch ($Format) {
        'RGB' {
            $replace = '0x$3$2$1'
            break
        }
        Default {
            $replace = '0x$1$2$3'
            break
        }
    }

    $hexString = [regex]::Replace($Value, "^(?:0x|#)?([\da-f]{2})([\da-f]{2})([\da-f]{2})$", $replace, 'IgnoreCase')
    [System.Convert]::ToInt32($hexString, 16)
}