function Set-TokenColorConfiguration {
    # [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [Parameter(Mandatory=$false)]
        $Theme,

        [Parameter(Mandatory=$false)]
        [switch] $Reset
    )

    $tokenColors = $Theme.tokens
    if(Get-Module PSReadLine) {
        if ($Reset -or !$TokenColors) {
            # Set-PSReadlineOption -ResetTokenColors could be used, but is set to be deprecated in 2.0
            $tokenColors = [PSCustomObject]@{
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
        } else {
            # Reset tokens to the defaults before applying theme specific mappings
            # Attempts to resolve issue where DefaultToken is set incorrectly
            Set-TokenColorConfiguration -Reset
        }

        # Breaking changes are coming in PSReadLine 2.0. Colors should be set via the -Color parameter with a hashtable
        foreach ($token in @('ContinuationPrompt','DefaultToken','Comment','Keyword','String','Operator','Variable','Command','Parameter','Type','Number','Member','Emphasis','Error')) {
            if (Get-Member $token -InputObject $tokenColors) {
                if ($token -in @('ContinuationPrompt','Emphasis','Error')) {
                    $expression = "Set-PSReadlineOption -$($token)ForegroundColor $($tokenColors.($token))"
                    Invoke-Expression $expression
                } elseif ($token -eq 'DefaultToken') {
                    Set-PSReadlineOption 'None' -ForegroundColor $tokenColors.($token)
                }
                else {
                    Set-PSReadlineOption $token -ForegroundColor $tokenColors.($token)
                }
            }

            if ($token -in @('ContinuationPrompt', 'Emphasis', 'Error')) {
                $expression = "Set-PSReadlineOption -$($token)BackgroundColor $($Theme.background)"
                Invoke-Expression $expression
            }
            elseif ($token -eq 'DefaultToken') {
                Set-PSReadlineOption 'None' -BackgroundColor $Theme.background
            }
            else {
                Set-PSReadlineOption $token -BackgroundColor $Theme.background
            }
        }
    }
}