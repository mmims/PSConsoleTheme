function Get-BFValue {
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [string] $Background,

        [Parameter(Mandatory=$true,Position=1)]
        [string] $Foreground
    )

    $colorTable = @{
        'Black'       = '0'
        'DarkBlue'    = '1'
        'DarkGreen'   = '2'
        'DarkCyan'    = '3'
        'DarkRed'     = '4'
        'DarkMagenta' = '5'
        'DarkYellow'  = '6'
        'Gray'        = '7'
        'DarkGray'    = '8'
        'Blue'        = '9'
        'Green'       = 'a'
        'Cyan'        = 'b'
        'Red'         = 'c'
        'Magenta'     = 'd'
        'Yellow'      = 'e'
        'White'       = 'f'
    }

    [System.Convert]::ToInt32(($colorTable[$Background] + $colorTable[$Foreground]), 16)
}