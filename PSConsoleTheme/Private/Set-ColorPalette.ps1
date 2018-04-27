function Set-ColorPalette {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [System.Object] $Theme,

        [Parameter(Mandatory=$false)]
        [switch] $Reset,

        [Parameter(Mandatory=$false)]
        [switch] $Session
    )

    $key = 'HKCU:\Console'
    $saveReg = !$Session

    if ($Reset.IsPresent) {
        Remove-ItemProperty -Path $key -Name ColorTable* -Force -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $key -Name ScreenColors -Force -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $key -Name PopupColors -Force -ErrorAction SilentlyContinue
        $Theme = $PSConsoleTheme.Themes['Redmond']
        $saveReg = $false
    }

    $palette = $Theme.palette
    $format = 'RGB'
    $colorMap = @{
        'Black'       = @{
            'Background' = 0
            'Foreground' = 0
            'Table'      = 'ColorTable00'
        }
        'DarkBlue'    = @{
            'Background' = 16
            'Foreground' = 1
            'Table'      = 'ColorTable01'
        }
        'DarkGreen'   = @{
            'Background' = 32
            'Foreground' = 2
            'Table'      = 'ColorTable02'
        }
        'DarkCyan'    = @{
            'Background' = 48
            'Foreground' = 3
            'Table'      = 'ColorTable03'
        }
        'DarkRed'     = @{
            'Background' = 64
            'Foreground' = 4
            'Table'      = 'ColorTable04'
        }
        'DarkMagenta' = @{
            'Background' = 80
            'Foreground' = 5
            'Table'      = 'ColorTable05'
        }
        'DarkYellow'  = @{
            'Background' = 96
            'Foreground' = 6
            'Table'      = 'ColorTable06'
        }
        'Gray'        = @{
            'Background' = 112
            'Foreground' = 7
            'Table'      = 'ColorTable07'
        }
        'DarkGray'    = @{
            'Background' = 128
            'Foreground' = 8
            'Table'      = 'ColorTable08'
        }
        'Blue'        = @{
            'Background' = 144
            'Foreground' = 9
            'Table'      = 'ColorTable09'
        }
        'Green'       = @{
            'Background' = 160
            'Foreground' = 10
            'Table'      = 'ColorTable10'
        }
        'Cyan'        = @{
            'Background' = 176
            'Foreground' = 11
            'Table'      = 'ColorTable11'
        }
        'Red'         = @{
            'Background' = 192
            'Foreground' = 12
            'Table'      = 'ColorTable12'
        }
        'Magenta'     = @{
            'Background' = 208
            'Foreground' = 13
            'Table'      = 'ColorTable13'
        }
        'Yellow'      = @{
            'Background' = 224
            'Foreground' = 14
            'Table'      = 'ColorTable14'
        }
        'White'       = @{
            'Background' = 240
            'Foreground' = 15
            'Table'      = 'ColorTable15'
        }
    }

    if (Get-Member paletteFormat -InputObject $Theme -MemberType NoteProperty) {
        $format = $Theme.paletteFormat
    }

    if (!(Test-Path $key -PathType Container)) {
        $null = New-Item $key
    }

    # Set color table
    foreach ($color in ([System.ConsoleColor]).GetEnumNames()) {
        if ($colorMap.ContainsKey($color) -and (Get-Member $color -InputObject $palette -MemberType NoteProperty)) {
            $r, $g, $b = Get-RGBValues $palette.($color) $format
            $bgrValue = [System.Convert]::ToInt32('0x'+ $b + $g + $r, 16)
            [PSConsoleTheme.ColorChanger]::MapColor($color, '0x' + $r, '0x' + $g, '0x' + $b)

            if ($saveReg) {
                Set-ItemProperty -Path $key -Name $colorMap.$color.Table -Value $bgrValue -Force
            }
        }
    }

    # Set background/foreground
    [PSConsoleTheme.ColorChanger]::SetAttributes($colorMap.($Theme.foreground).Foreground + $colorMap.($Theme.background).Background)

    if ($saveReg) {
        $bgfgValue = Get-BFValue $Theme.background $Theme.foreground
        Set-ItemProperty -Path $key -Name 'ScreenColors' -Value $bgfgValue -Force

        if ((Get-Member popupBackground -InputObject $Theme -MemberType NoteProperty) -and (Get-Member popupForeground -InputObject $Theme -MemberType NoteProperty)) {
            $bgfgValue = Get-BFValue $Theme.popupBackground $Theme.popupForeground
            Set-ItemProperty -Path $key -Name 'PopupColors' -Value $bgfgValue -Force
        }
    }
}

<#
  Adapted from Colorful.Console by Tom Akita (https://github.com/tomakita/Colorful.Console)

  The MIT License (MIT)
  Copyright (c) 2015 Tom Akita
  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
  associated documentation files (the "Software"), to deal in the Software without restriction,
  including without limitation the rights to use, copy, modify, merge, publish, distribute,
  sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all copies or
  substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
  NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>

$ColorChangerSource = @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;

namespace PSConsoleTheme
{
    public static class ColorChanger
    {
        [StructLayout(LayoutKind.Sequential)]
        private struct COORD
        {
            internal short X;
            internal short Y;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct SMALL_RECT
        {
            internal short Left;
            internal short Top;
            internal short Right;
            internal short Bottom;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct COLORREF
        {
            private uint dwColor;

            internal COLORREF(uint r, uint g, uint b)
            {
                dwColor = r + (g << 8) + (b << 16);
            }

            public override string ToString()
            {
                return dwColor.ToString();
            }
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct CONSOLE_SCREEN_BUFFER_INFO_EX
        {
            internal int cbSize;
            internal COORD dwSize;
            internal COORD dwCursorPosition;
            internal ushort wAttributes;
            internal SMALL_RECT srWindow;
            internal COORD dwMaximumWindowSize;
            internal ushort wPopupAttributes;
            internal bool bFullscreenSupported;
            internal COLORREF black;
            internal COLORREF darkBlue;
            internal COLORREF darkGreen;
            internal COLORREF darkCyan;
            internal COLORREF darkRed;
            internal COLORREF darkMagenta;
            internal COLORREF darkYellow;
            internal COLORREF gray;
            internal COLORREF darkGray;
            internal COLORREF blue;
            internal COLORREF green;
            internal COLORREF cyan;
            internal COLORREF red;
            internal COLORREF magenta;
            internal COLORREF yellow;
            internal COLORREF white;
        }

        private const int STD_OUTPUT_HANDLE = -11;
        private static readonly IntPtr INVALID_HANDLE_VALUE = new IntPtr(-1);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern IntPtr GetStdHandle(int nStdHandle);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool GetConsoleScreenBufferInfoEx(IntPtr hConsoleOutput, ref CONSOLE_SCREEN_BUFFER_INFO_EX csbe);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool SetConsoleScreenBufferInfoEx(IntPtr hConsoleOutput, ref CONSOLE_SCREEN_BUFFER_INFO_EX csbe);

        private static CONSOLE_SCREEN_BUFFER_INFO_EX GetBufferInfo(IntPtr hConsoleOutput)
        {
            CONSOLE_SCREEN_BUFFER_INFO_EX csbe = new CONSOLE_SCREEN_BUFFER_INFO_EX();
            csbe.cbSize = (int)Marshal.SizeOf(csbe);

            if (hConsoleOutput == INVALID_HANDLE_VALUE)
            {
                throw CreateException(Marshal.GetLastWin32Error());
            }

            bool brc = GetConsoleScreenBufferInfoEx(hConsoleOutput, ref csbe);

            if (!brc)
            {
                throw CreateException(Marshal.GetLastWin32Error());
            }

            return csbe;
        }

        public static void MapColor(ConsoleColor color, uint r, uint g, uint b)
        {
            IntPtr hConsoleOutput = GetStdHandle(STD_OUTPUT_HANDLE);
            CONSOLE_SCREEN_BUFFER_INFO_EX csbe = GetBufferInfo(hConsoleOutput);

            switch (color)
            {
                case ConsoleColor.Black:
                    csbe.black = new COLORREF(r, g, b);
                    break;
                case ConsoleColor.DarkBlue:
                    csbe.darkBlue = new COLORREF(r, g, b);
                    break;
                case ConsoleColor.DarkGreen:
                    csbe.darkGreen = new COLORREF(r, g, b);
                    break;
                case ConsoleColor.DarkCyan:
                    csbe.darkCyan = new COLORREF(r, g, b);
                    break;
                case ConsoleColor.DarkRed:
                    csbe.darkRed = new COLORREF(r, g, b);
                    break;
                case ConsoleColor.DarkMagenta:
                    csbe.darkMagenta = new COLORREF(r, g, b);
                    break;
                case ConsoleColor.DarkYellow:
                    csbe.darkYellow = new COLORREF(r, g, b);
                    break;
                case ConsoleColor.Gray:
                    csbe.gray = new COLORREF(r, g, b);
                    break;
                case ConsoleColor.DarkGray:
                    csbe.darkGray = new COLORREF(r, g, b);
                    break;
                case ConsoleColor.Blue:
                    csbe.blue = new COLORREF(r, g, b);
                    break;
                case ConsoleColor.Green:
                    csbe.green = new COLORREF(r, g, b);
                    break;
                case ConsoleColor.Cyan:
                    csbe.cyan = new COLORREF(r, g, b);
                    break;
                case ConsoleColor.Red:
                    csbe.red = new COLORREF(r, g, b);
                    break;
                case ConsoleColor.Magenta:
                    csbe.magenta = new COLORREF(r, g, b);
                    break;
                case ConsoleColor.Yellow:
                    csbe.yellow = new COLORREF(r, g, b);
                    break;
                case ConsoleColor.White:
                    csbe.white = new COLORREF(r, g, b);
                    break;
            }

            SetBufferInfo(hConsoleOutput, csbe);
        }

        public static void SetAttributes(ushort attributes)
        {
            IntPtr hConsoleOutput = GetStdHandle(STD_OUTPUT_HANDLE);
            CONSOLE_SCREEN_BUFFER_INFO_EX csbe = GetBufferInfo(hConsoleOutput);
            csbe.wAttributes = attributes;
            SetBufferInfo(hConsoleOutput, csbe);
        }

        private static void SetBufferInfo(IntPtr hConsoleOutput, CONSOLE_SCREEN_BUFFER_INFO_EX csbe)
        {
            csbe.srWindow.Bottom++;
            csbe.srWindow.Right++;

            bool brc = SetConsoleScreenBufferInfoEx(hConsoleOutput, ref csbe);
            if (!brc)
            {
                throw CreateException(Marshal.GetLastWin32Error());
            }
        }

        private static Exception CreateException(int errorCode)
        {
            int ERROR_INVALID_HANDLE = 6;
            if (errorCode == ERROR_INVALID_HANDLE)
            {
                return new ConsoleAccessException();
            }
            else
            {
                return new ConsoleBufferException(errorCode);
            }
        }
    }

    public sealed class ConsoleAccessException : Exception
    {
        public ConsoleAccessException()
            : base(String.Format("Console handle not found."))
        {
        }
    }

    public sealed class ConsoleBufferException : Exception
    {
        public int ErrorCode { get; private set; }

        public ConsoleBufferException(int errorCode)
            : base(String.Format("Console buffer failed with error code {0}!", errorCode))
        {
            ErrorCode = errorCode;
        }
    }
}
'@

try {
    Add-Type -TypeDefinition $ColorChangerSource -Language CSharp -ErrorAction SilentlyContinue
}
catch {
    Write-Warning "Set-ConsoleTheme: $_"
}