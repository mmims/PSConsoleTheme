function Set-TokenColorConfiguration {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [Parameter(Mandatory=$true)]
        $TokenColors
    )
    foreach ($token in @("Comment","Keyword","String","Operator","Variable","Command","Parameter","Type","Number","Member")) {
        if (Get-Member $token -InputObject $TokenColors) {
            Set-PSReadlineOption $token -ForegroundColor $TokenColors.($token)
        }
    }
}