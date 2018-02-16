function Set-ColorPalette {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [System.Object] $Theme,

        [Parameter(Mandatory=$false)]
        [switch] $Reset
    )

    # $key = 'HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe'
    $key = 'HKCU:\Console'
    if ($Reset.IsPresent) {
        Remove-ItemProperty -Path $key -Name ColorTable* -Force -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $key -Name ScreenColors -Force -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $key -Name PopupColors -Force -ErrorAction SilentlyContinue
        return
    }

    $palette = $Theme.palette
    $format = 'RGB'
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

    if (Get-Member paletteFormat -InputObject $Theme -MemberType NoteProperty) {
        $format = $Theme.paletteFormat
    }

    if (!(Test-Path $key -PathType Container)) {
        $null = New-Item $key
    }

    # Set color table
    foreach ($color in ([System.ConsoleColor]).GetEnumNames()) {
        if ($colorTable.ContainsKey($color) -and (Get-Member $color -InputObject $palette -MemberType NoteProperty)) {
            $r, $g, $b = Get-RGBValues $palette.($color) $format
            $bgrValue = [System.Convert]::ToInt32('0x'+ $b + $g + $r, 16)
            Set-ItemProperty -Path $key -Name $colorTable[$color] -Value $bgrValue -Force
            [PSConsoleTheme.ColorChanger]::MapColor($color, '0x' + $r, '0x' + $g, '0x' + $b)
        }
    }

    # Set background/foreground
    $bgfgValue = Get-BFValue $Theme.background $Theme.foreground
    Set-ItemProperty -Path $key -Name 'ScreenColors' -Value $bgfgValue -Force
    $Host.UI.RawUI.ForegroundColor = $Theme.foreground
    $Host.UI.RawUI.BackgroundColor = $Theme.background
    if ((Get-Member popupBackground -InputObject $Theme -MemberType NoteProperty) -and (Get-Member popupForeground -InputObject $Theme -MemberType NoteProperty)) {
        $bgfgValue = Get-BFValue $Theme.popupBackground $Theme.popupForeground
        Set-ItemProperty -Path $key -Name 'PopupColors' -Value $bgfgValue -Force
    }
}