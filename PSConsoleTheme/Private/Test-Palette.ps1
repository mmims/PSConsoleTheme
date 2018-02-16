function Test-Palette {
    param(
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
        [ValidateNotNull()]
        $PaletteObject
    )
    Process {
        $valid = $true
        $missing = @()
        foreach ($color in ([System.ConsoleColor]).GetEnumNames()) {
            if (!(Get-Member $color -InputObject $PaletteObject -MemberType NoteProperty)) {
                $valid = $false
                $missing += $color
            } else {
                if (!($PaletteObject.($color) -imatch "^(?:0x|#)?[\da-f]{6}$")) {
                    throw ($palette_msgs.error_invalid_palette_value -f $color,$PaletteObject.($color))
                }
            }
        }
        if(!$valid) {
            throw ($palette_msgs.error_incomplete_palette -f ($missing -join ", "))
        }
        $valid
    }
}

DATA palette_msgs {
    ConvertFrom-StringData @'
        error_incomplete_palette = Incomplete palette. Missing: {0}.
        error_invalid_palette_value = "{0}" color value {1} is invalid.
'@
}