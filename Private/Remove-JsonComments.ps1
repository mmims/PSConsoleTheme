Function Remove-JsonComments {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string] $Data,

        [Parameter(Mandatory=$false)]
        [switch] $Minimize
    )

    New-Variable -Name 'SINGLECOMMENT' -Value 1 -Option Constant
    New-Variable -Name 'MULTICOMMENT' -Value 2 -Option Constant
    $inString = $false
    $inComment = $false
    $offset = 0
    $ret = ''

    for ($i = 0; $i -lt $Data.Length; $i++) {
        $curChar = $Data[$i]
        $nextChar = $Data[$i+1]

        if (!$inComment -and ($curChar -eq '"')) {
            if ($i -ge 2) {
                if (!(($Data[$i - 1] -eq '\') -and ($Data[$i - 2] -ne '\'))) {
                    $inString = !$inString
                }
            } else {
                $inString = !$inString
            }
        }

        if ($inString) {
            continue
        }

        if ($Minimize -and !$inComment -and ($curChar -imatch '\s')) {
            $ret += $Data.Substring($offset, ($i - $offset))
            $offset = $i + 1
        } elseif (!$inComment -and (($curChar + $nextChar) -eq '//')) {
            $inComment = $SINGLECOMMENT
            $ret += $Data.Substring($offset, ($i - $offset))
            $offset = $i
            $i++
        } elseif (($inComment -eq $SINGLECOMMENT) -and (($curChar + $nextChar) -eq "`r`n")) {
            $inComment = $false
            $i++
            $offset = $i
            if ($Minimize) {
                $offset++
            }
        } elseif (($inComment -eq $SINGLECOMMENT) -and ($curChar -eq "`n")) {
            $inComment = $false
            $offset = $i
            if ($Minimize) {
                $offset++
            }
        } elseif (!$inComment -and (($curChar + $nextChar) -eq '/*')) {
            $inComment = $MULTICOMMENT
            $ret += $Data.Substring($offset, $($i - $offset))
            $offset = $i
            $i++
        } elseif (($inComment -eq $MULTICOMMENT) -and (($curChar + $nextChar) -eq '*/')) {
            $inComment = $false
            $i++
            $offset = $i + 1
        }
    }

    if (!$inComment) {
        $ret += $Data.Substring($offset)
    }

    return $ret.Trim()
}