function Resolve-QueryOptions {
    [CmdletBinding()]
    param(
        [switch]$UseCache,
        [switch]$Recursion,
        [TimeSpan]$Timeout,
        [int]$Retries,
        [switch]$ThrowDnsErrors,
        [switch]$UseRandomNameServer,
        [switch]$ContinueOnDnsError,
        [switch]$ContinueOnEmptyResponse,
        [switch]$UseTcpFallback,
        [switch]$UseTcpOnly,
        [int]$ExtendedDnsBufferSize,
        [switch]$EnableAuditTrail,
        [switch]$RequestDnsSecRecords,
        [Parameter(ValueFromRemainingArguments)]
        $ExtraParams
    )

    # We want to allow per-call query options from Resolve-Dns. But we don't
    # want to bother creating a new instance of DnsQueryOptions if the caller
    # didn't specify any options or the options they did specify don't
    # conflict with the existing options on the current LookupClient.
    #
    # Within Resolve-Dns, we should be able to splat its $PSBoundParameters
    # against this function and return either $null to indicate there are no
    # query specific options to apply or a DnsQueryOptions instance that
    # contains the current LookupClient options with any overridden values.

    $cOpts = Get-LookupClientOptions
    $qOpts = $null
    $psbKeys = $PSBoundParameters.Keys

    # loop through the parameters to see if any are different
    $paramNames = @(
        'UseCache'
        'Recursion'
        'Timeout'
        'Retries'
        'ThrowDnsErrors'
        'UseRandomNameServer'
        'ContinueOnDnsError'
        'ContinueOnEmptyResponse'
        'UseTcpFallback'
        'UseTcpOnly'
        'ExtendedDnsBufferSize'
        'EnableAuditTrail'
        'RequestDnsSecRecords'
    )
    foreach ($pName in $paramNames) {
        if ($pName -in $psbKeys -and $cOpts.$pName -ne $PSBoundParameters[$pName]) {
            if (-not $qOpts) {
                Write-Debug "Cloning query specific options from client options"
                $qOpts = [DnsClient.DnsQueryOptions]::new()
                $paramNames | ForEach-Object {
                    $qOpts.$_ = $cOpts.$_
                }
            }
            Write-Debug "$pName($($PSBoundParameters[$pName])) differs from current value"
            $qOpts.$pName = $PSBoundParameters[$pName]
        }
    }

    return $qOpts
}
