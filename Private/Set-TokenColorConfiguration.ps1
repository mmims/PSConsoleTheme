function Set-TokenColorConfiguration {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [Parameter(Mandatory=$false)]
        $TokenColors,

        [Parameter(Mandatory=$false)]
        [switch] $Reset
    )

    if(Get-Module PSReadLine) {
        if ($Reset.IsPresent) {
            $TokenColors = @{
                'Comment' = 'DarkGreen'
                'Keyword' = 'Green'
                'String' = 'DarkCyan'
                'Operator' = 'DarkGray'
                'Variable' = 'Green'
                'Command' = 'Yellow'
                'Parameter' = 'DarkGray'
                'Type' = 'Gray'
                'Number' = 'White'
                'Member' = 'White'
            }
        }

        if (!$TokenColors) {
            return
        }

        foreach ($token in @('Comment','Keyword','String','Operator','Variable','Command','Parameter','Type','Number','Member')) {
            if (Get-Member $token -InputObject $TokenColors) {
                Set-PSReadlineOption $token -ForegroundColor $TokenColors.($token)
            }
        }
    }
}