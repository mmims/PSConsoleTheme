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
            # Set-PSReadlineOption -ResetTokenColors could be used, but is set to be deprecated in 2.0
            $TokenColors = [PSCustomObject]@{
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

        # Breaking changes are coming in PSReadLine 2.0. Colors should be set via the -Color parameter with a hashtable
        foreach ($token in @('ContinuationPrompt','DefaultToken','Comment','Keyword','String','Operator','Variable','Command','Parameter','Type','Number','Member','Emphasis','Error')) {
            if (Get-Member $token -InputObject $TokenColors) {
                if ($token -in @('ContinuationPrompt','Emphasis','Error')) {
                    $expression = "Set-PSReadlineOption -$($token)ForegroundColor $($TokenColors.($token))"
                    Invoke-Expression $expression
                } elseif ($token -eq 'DefaultToken') {
                    Set-PSReadlineOption 'None' -ForegroundColor $TokenColors.($token)
                }
                else {
                    Set-PSReadlineOption $token -ForegroundColor $TokenColors.($token)
                }
            }
        }
    }
}