function Assert {
    param(
        [Parameter(Position=0, Mandatory=1)]
        $conditionToCheck,

        [Parameter(Position=1, Mandatory=1)]
        $failureMessage
    )
    if (!$conditionToCheck) {
        throw("Assert: " + $failureMessage)
    }
}