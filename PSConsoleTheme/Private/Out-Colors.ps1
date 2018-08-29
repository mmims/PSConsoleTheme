function Out-Colors {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('Ansi', 'PowerShell', 'Cmd', 'Table')]
        [string] $Mode = 'PowerShell'
    )

    function CenterString ([string]$string, [int]$space) {
        "{0,-$space}" -f (("{0," + [System.Math]::Floor(($space + $string.Length) / 2) + "}") -f $string)
    }

    function CloneObject ([object] $deepCopyObject) {
        $memStream = New-Object IO.MemoryStream
        $formatter = New-Object Runtime.Serialization.Formatters.Binary.BinaryFormatter
        $formatter.Serialize($memStream, $deepCopyObject)
        $memStream.Position = 0
        $formatter.Deserialize($memStream)
    }

    if ($PSReadline = Get-Module PSReadLine) {
        $colorMap = CloneObject $Script:PSColorMap
        $options = Get-PSReadlineOption

        if ($PSReadline.Version.Major -ge 2) {
            $tokens = $options | Get-Member -MemberType Property -Name *Color `
                | ForEach-Object { $_.Name -replace '(.+)Color', '$1' }

            foreach ($t in $tokens) {
                $ansiColor = Invoke-Expression "`$options.$($t)Color.ToString()"
                $ansiColor = [regex]::Replace($ansiColor, '.*\[((?:\d{1,3};?)+)m', '$1')
                $color = ($colorMap.GetEnumerator() | Where-Object { $_.Value.Ansi.FG -in ($ansiColor -split ';') } | Select-Object -First 1).Key
                $colorMap[$color].Tokens += $t
            }
        } else {
            $tokens = $options | Get-Member -MemberType Property -Name *ForegroundColor `
                | ForEach-Object { $_.Name -replace '(.+)ForegroundColor', '$1' }

            foreach ($t in $tokens) {
                $color = Invoke-Expression "`$options.$($t)ForegroundColor.ToString()"
                $colorMap[$color].Tokens += $t
            }
        }
    }

    switch ($Mode) {
        'Ansi' {
            Write-Host ("`n{0,8} {1,-5} " -f '', '  m') -NoNewline
            foreach ($bg in ($Script:AnsiColorMap.GetEnumerator() | Where-Object { [System.Convert]::ToInt32($_.Value.BG) -le 47 } | Sort-Object { $_.Value.BG })) {
                Write-Host ' ' -NoNewline
                Write-Host ("{0,-5}" -f " $($bg.Value.BG)m") -NoNewline
            }

            Write-Host ''
            foreach ($fg in ($Script:AnsiColorMap.GetEnumerator() | Sort-Object { $_.Value.FG })) {
                $fgcolor = $fg.Value.PShell.Name
                Write-Host ("{0,-8} " -f "$($fg.Value.FG)m", ' gYw') -NoNewline
                Write-Host ("{0,-5} " -f ' gYw') -ForegroundColor $fgcolor -NoNewline
                foreach ($bg in ($Script:AnsiColorMap.GetEnumerator() | Where-Object { [System.Convert]::ToInt32($_.Value.BG) -le 47 } | Sort-Object { $_.Value.BG })) {
                    $bgcolor = $bg.Value.PShell.Name
                    Write-Host ' ' -NoNewline
                    Write-Host ("{0,-5}" -f ' gYw') -BackgroundColor $bgcolor -ForegroundColor $fgcolor -NoNewline
                }
                Write-Host ''
            }
            Write-Host "`n"
        }
        'Cmd' {
            Write-Host ''
            Write-Host (' {0,18} | {1} | {2}' -f 'Cmd Color [Table]', (CenterString 'Dark' 14), (CenterString 'Light' 14))
            Write-Host (' ' + ('-' * 52))
            foreach ($color in ($Script:CmdColorMap.GetEnumerator() | Sort-Object {$_.Value.Table })) {
                Write-Host (' {0,13} [{1}] | ' -f $color.Name, $color.Value.Table) -NoNewline
                Write-Host (CenterString $color.Name 14) -ForegroundColor $color.Value.PShell.Name -BackgroundColor Black -NoNewline
                Write-Host ' | ' -NoNewline
                Write-Host (CenterString $color.Name 14) -ForegroundColor $color.Value.PShell.Name -BackgroundColor White
            }
            Write-Host "`n"
        }
        'PowerShell' {
            Write-Host ''
            Write-Host (' {0,13} | {1} | {2}' -f 'PS Color', (CenterString 'Theme' 10), 'Tokens')
            Write-Host (' ' + ('-' * 78))
            foreach ($color in ($colorMap.GetEnumerator() | Sort-Object {$_.Value.Cmd.Table })) {
                Write-Host (' {0,13} | ' -f $color.Name) -NoNewline
                Write-Host (CenterString ' ' 10) -ForegroundColor Black -BackgroundColor $color.Name -NoNewline
                Write-Host ' | ' -NoNewline
                Write-Host ($color.Value.Tokens -join ', ') -ForegroundColor $color.Name
            }
            Write-Host "`n"
        }
        Default {
            $PSColorMap.GetEnumerator() | Sort-Object {[System.Convert]::ToInt32($_.Value.Ansi.BG)} `
                | Format-Table -Property Name, @{Label = 'Cmd'; Expression = {$_.Value.Cmd.Name}},
            @{Label = 'Table'; Expression = {$_.Value.Cmd.Table}},
            @{Label = 'Ansi'; Expression = {$_.Value.Ansi.Name}},
            @{Label = 'FG'; Expression = {$_.Value.Ansi.FG}},
            @{Label = 'BG'; Expression = {$_.Value.Ansi.BG}} -AutoSize
        }
    }
}


$Script:PSColorMap = @{
    'Black'       = @{
        'Ansi'   = @{
            'Name' = 'Black'
            'FG'   = '30'
            'BG'   = '40'
        }
        'Cmd'    = @{
            'Name'  = 'Black'
            'Table' = '00'
        }
        'Tokens' = @()
    }
    'DarkRed'     = @{
        'Ansi'   = @{
            'Name' = 'Red'
            'FG'   = '31'
            'BG'   = '41'
        }
        'Cmd'    = @{
            'Name'  = 'Red'
            'Table' = '04'
        }
        'Tokens' = @()
    }
    'DarkGreen'   = @{
        'Ansi'   = @{
            'Name' = 'Green'
            'FG'   = '32'
            'BG'   = '42'
        }
        'Cmd'    = @{
            'Name'  = 'Green'
            'Table' = '02'
        }
        'Tokens' = @()
    }
    'DarkYellow'  = @{
        'Ansi'   = @{
            'Name' = 'Yellow'
            'FG'   = '33'
            'BG'   = '43'
        }
        'Cmd'    = @{
            'Name'  = 'Yellow'
            'Table' = '06'
        }
        'Tokens' = @()
    }
    'DarkBlue'    = @{
        'Ansi'   = @{
            'Name' = 'Blue'
            'FG'   = '34'
            'BG'   = '44'
        }
        'Cmd'    = @{
            'Name'  = 'Blue'
            'Table' = '01'
        }
        'Tokens' = @()
    }
    'DarkMagenta' = @{
        'Ansi'   = @{
            'Name' = 'Magenta'
            'FG'   = '35'
            'BG'   = '45'
        }
        'Cmd'    = @{
            'Name'  = 'Purple'
            'Table' = '05'
        }
        'Tokens' = @()
    }
    'DarkCyan'    = @{
        'Ansi'   = @{
            'Name' = 'Cyan'
            'FG'   = '36'
            'BG'   = '46'
        }
        'Cmd'    = @{
            'Name'  = 'Aqua'
            'Table' = '03'
        }
        'Tokens' = @()
    }
    'Gray'        = @{
        'Ansi'   = @{
            'Name' = 'White'
            'FG'   = '37'
            'BG'   = '47'
        }
        'Cmd'    = @{
            'Name'  = 'White'
            'Table' = '07'
        }
        'Tokens' = @()
    }
    'DarkGray'    = @{
        'Ansi'   = @{
            'Name' = 'Bright Black'
            'FG'   = '90'
            'BG'   = '100'
        }
        'Cmd'    = @{
            'Name'  = 'Gray'
            'Table' = '08'
        }
        'Tokens' = @()
    }
    'Red'         = @{
        'Ansi'   = @{
            'Name' = 'Bright Red'
            'FG'   = '91'
            'BG'   = '101'
        }
        'Cmd'    = @{
            'Name'  = 'Light Red'
            'Table' = '12'
        }
        'Tokens' = @()
    }
    'Green'       = @{
        'Ansi'   = @{
            'Name' = 'Bright Green'
            'FG'   = '92'
            'BG'   = '102'
        }
        'Cmd'    = @{
            'Name'  = 'Light Green'
            'Table' = '10'
        }
        'Tokens' = @()
    }
    'Yellow'      = @{
        'Ansi'   = @{
            'Name' = 'Bright Yellow'
            'FG'   = '93'
            'BG'   = '103'
        }
        'Cmd'    = @{
            'Name'  = 'Light Yellow'
            'Table' = '14'
        }
        'Tokens' = @()
    }
    'Blue'        = @{
        'Ansi'   = @{
            'Name' = 'Bright Blue'
            'FG'   = '94'
            'BG'   = '104'
        }
        'Cmd'    = @{
            'Name'  = 'Light Blue'
            'Table' = '09'
        }
        'Tokens' = @()
    }
    'Magenta'     = @{
        'Ansi'   = @{
            'Name' = 'Bright Magenta'
            'FG'   = '95'
            'BG'   = '105'
        }
        'Cmd'    = @{
            'Name'  = 'Light Purple'
            'Table' = '13'
        }
        'Tokens' = @()
    }
    'Cyan'        = @{
        'Ansi'   = @{
            'Name' = 'Bright Cyan'
            'FG'   = '96'
            'BG'   = '106'
        }
        'Cmd'    = @{
            'Name'  = 'Light Aqua'
            'Table' = '11'
        }
        'Tokens' = @()
    }
    'White'       = @{
        'Ansi'   = @{
            'Name' = 'Bright White'
            'FG'   = '97'
            'BG'   = '107'
        }
        'Cmd'    = @{
            'Name'  = 'Bright White'
            'Table' = '15'
        }
        'Tokens' = @()
    }
}

$Script:CmdColorMap = @{}
$Script:AnsiColorMap = @{}

foreach ($key in $Script:PSColorMap.Keys) {
    $value = $Script:PSColorMap[$key]
    $pshell = @{'Name' = $key}
    $ansi = @{'Cmd' = $value.Cmd; 'PShell' = $pshell; 'BG' = $value.Ansi.BG; 'FG' = $value.Ansi.FG}
    $cmd = @{'Ansi' = $value.Ansi; 'PShell' = $pshell; 'Table' = $value.Cmd.Table}

    $Script:CmdColorMap.Add($value.Cmd.Name, $cmd)
    $Script:AnsiColorMap.Add($value.Ansi.Name, $ansi)
}