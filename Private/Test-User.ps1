function Test-User {
    param(
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Theme
    )
    Process {
        $true
    }
}