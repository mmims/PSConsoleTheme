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
            foreach($color in ($Script:CmdColorMap.GetEnumerator() | Sort-Object {$_.Value.Table })) {
                Write-Host (' {0,13} [{1}] | ' -f $color.Name, $color.Value.Table) -NoNewline
                Write-Host (CenterString $color.Name 14) -ForegroundColor $color.Value.PShell.Name -BackgroundColor Black -NoNewline
                Write-Host ' | ' -NoNewline
                Write-Host (CenterString $color.Name 14) -ForegroundColor $color.Value.PShell.Name -BackgroundColor White
            }
            Write-Host "`n"
        }
        'PowerShell' {
            Write-Host ''
            Write-Host (' {0,13} | {1} | {2}' -f 'PS Color', (CenterString 'Dark' 14), (CenterString 'Light' 14))
            Write-Host (' ' + ('-' * 47))
            foreach ($color in ($Script:PSColorMap.GetEnumerator() | Sort-Object {$_.Value.Table })) {
                Write-Host (' {0,13} | ' -f $color.Name) -NoNewline
                Write-Host (CenterString $color.Name 14) -ForegroundColor $color.Name -BackgroundColor Black -NoNewline
                Write-Host ' | ' -NoNewline
                Write-Host (CenterString $color.Name 14) -ForegroundColor $color.Name -BackgroundColor White
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
        'Ansi' = @{
            'Name' = 'Black'
            'FG'   = '30'
            'BG'   = '40'
        }
        'Cmd'  = @{
            'Name'  = 'Black'
            'Table' = '00'
        }
    }
    'DarkRed'     = @{
        'Ansi' = @{
            'Name' = 'Red'
            'FG'   = '31'
            'BG'   = '41'
        }
        'Cmd'  = @{
            'Name'  = 'Red'
            'Table' = '04'
        }
    }
    'DarkGreen'   = @{
        'Ansi' = @{
            'Name' = 'Green'
            'FG'   = '32'
            'BG'   = '42'
        }
        'Cmd'  = @{
            'Name'  = 'Green'
            'Table' = '02'
        }
    }
    'DarkYellow'  = @{
        'Ansi' = @{
            'Name' = 'Yellow'
            'FG'   = '33'
            'BG'   = '43'
        }
        'Cmd'  = @{
            'Name'  = 'Yellow'
            'Table' = '06'
        }
    }
    'DarkBlue'    = @{
        'Ansi' = @{
            'Name' = 'Blue'
            'FG'   = '34'
            'BG'   = '44'
        }
        'Cmd'  = @{
            'Name'  = 'Blue'
            'Table' = '01'
        }
    }
    'DarkMagenta' = @{
        'Ansi' = @{
            'Name' = 'Magenta'
            'FG'   = '35'
            'BG'   = '45'
        }
        'Cmd'  = @{
            'Name'  = 'Purple'
            'Table' = '05'
        }
    }
    'DarkCyan'    = @{
        'Ansi' = @{
            'Name' = 'Cyan'
            'FG'   = '36'
            'BG'   = '46'
        }
        'Cmd'  = @{
            'Name'  = 'Aqua'
            'Table' = '03'
        }
    }
    'Gray'        = @{
        'Ansi' = @{
            'Name' = 'White'
            'FG'   = '37'
            'BG'   = '47'
        }
        'Cmd'  = @{
            'Name'  = 'White'
            'Table' = '07'
        }
    }
    'DarkGray'    = @{
        'Ansi' = @{
            'Name' = 'Bright Black'
            'FG'   = '30;1'
            'BG'   = '100'
        }
        'Cmd'  = @{
            'Name'  = 'Gray'
            'Table' = '08'
        }
    }
    'Red'         = @{
        'Ansi' = @{
            'Name' = 'Bright Red'
            'FG'   = '31;1'
            'BG'   = '101'
        }
        'Cmd'  = @{
            'Name'  = 'Light Red'
            'Table' = '12'
        }
    }
    'Green'       = @{
        'Ansi' = @{
            'Name' = 'Bright Green'
            'FG'   = '32;1'
            'BG'   = '102'
        }
        'Cmd'  = @{
            'Name'  = 'Light Green'
            'Table' = '10'
        }
    }
    'Yellow'      = @{
        'Ansi' = @{
            'Name' = 'Bright Yellow'
            'FG'   = '33;1'
            'BG'   = '103'
        }
        'Cmd'  = @{
            'Name'  = 'Light Yellow'
            'Table' = '14'
        }
    }
    'Blue'        = @{
        'Ansi' = @{
            'Name' = 'Bright Blue'
            'FG'   = '34;1'
            'BG'   = '104'
        }
        'Cmd'  = @{
            'Name'  = 'Light Blue'
            'Table' = '09'
        }
    }
    'Magenta'     = @{
        'Ansi' = @{
            'Name' = 'Bright Magenta'
            'FG'   = '35;1'
            'BG'   = '105'
        }
        'Cmd'  = @{
            'Name'  = 'Light Purple'
            'Table' = '13'
        }
    }
    'Cyan'        = @{
        'Ansi' = @{
            'Name' = 'Bright Cyan'
            'FG'   = '36;1'
            'BG'   = '106'
        }
        'Cmd'  = @{
            'Name'  = 'Light Aqua'
            'Table' = '11'
        }
    }
    'White'       = @{
        'Ansi' = @{
            'Name' = 'Bright White'
            'FG'   = '37;1'
            'BG'   = '107'
        }
        'Cmd'  = @{
            'Name'  = 'Bright White'
            'Table' = '15'
        }
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