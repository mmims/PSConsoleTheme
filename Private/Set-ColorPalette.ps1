function Set-ColorPalette {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [System.Object] $Theme
    )
    $colorTable = @{
        'Black'       = 'ColorTable00'
        'DarkBlue'    = 'ColorTable01'
        'DarkGreen'   = 'ColorTable02'
        'DarkCyan'    = 'ColorTable03'
        'DarkRed'     = 'ColorTable04'
        'DarkMagenta' = 'ColorTable05'
        'DarkYellow'  = 'ColorTable06'
        'Gray'        = 'ColorTable07'
        'DarkGray'    = 'ColorTable08'
        'Blue'        = 'ColorTable09'
        'Green'       = 'ColorTable10'
        'Cyan'        = 'ColorTable11'
        'Red'         = 'ColorTable12'
        'Magenta'     = 'ColorTable13'
        'Yellow'      = 'ColorTable14'
        'White'       = 'ColorTable15'
    }
    $key = 'HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe'
    $palette = $Theme.palette
    $format = 'RGB'
    if (Get-Member paletteFormat -InputObject $Theme -MemberType NoteProperty) {
        $format = $Theme.paletteFormat
    }

    if (!(Test-Path $key -PathType Container)) {
        $null = New-Item $key
    }

    foreach ($color in ([System.ConsoleColor]).GetEnumNames()) {
        if ($colorTable.ContainsKey($color) -and (Get-Member $color -InputObject $palette -MemberType NoteProperty)) {
            $bgrValue = Get-BGRValue $palette.($color) $format
            Set-ItemProperty -Path $key -Name $colorTable[$color] -Value $bgrValue -Force
        }
    }
}