function Set-TokenColorConfiguration {
    # [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [Parameter(Mandatory=$false)]
        $TokenColors,

        [Parameter(Mandatory=$false)]
        [switch] $Reset
    )

    if(Get-Module PSReadLine) {
        if ($Reset.IsPresent -or !$TokenColors) {
            $TokenColors = @{
                'ContinuationPrompt' = 'Gray'
                'DefaultToken' = 'Gray'
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
                'Emphasis' = 'Cyan'
                'Error' = 'Red'
            }
        }

        foreach ($token in @('ContinuationPrompt','DefaultToken','Comment','Keyword','String','Operator','Variable','Command','Parameter','Type','Number','Member','Emphasis','Error')) {
            if (Get-Member $token -InputObject $TokenColors) {
                Set-PSReadlineOption $token -ForegroundColor $TokenColors.($token)
            }
        }
    }
}