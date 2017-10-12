function Set-TokenColorConfiguration {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [Parameter(Mandatory=$false)]
        $TokenColors,

        [Parameter(Mandatory=$false)]
        [switch] $Reset
    )

    if(Get-Module PSReadLine) {
        $defaultColors = @{}
        if ($Reset.IsPresent) {
            $defaultColors = @{
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

        foreach ($token in @('Comment','Keyword','String','Operator','Variable','Command','Parameter','Type','Number','Member')) {
            if ($Reset.IsPresent) {
                Set-PSReadlineOption $token -ForegroundColor $defaultColors.($token)
            } elseif (Get-Member $token -InputObject $TokenColors) {
                Set-PSReadlineOption $token -ForegroundColor $TokenColors.($token)
            }
        }
    }
}