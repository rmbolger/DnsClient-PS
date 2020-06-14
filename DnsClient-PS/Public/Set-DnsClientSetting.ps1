function Set-DnsClientSetting {
    [CmdletBinding()]
    param(
        [Alias('ns','NameServers')]
        [string[]]$NameServer,
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
        [TimeSpan]$MinimumCacheTimeout,
        [TimeSpan]$MaximumCacheTimeout,
        [switch]$RequestDnsSecRecords
    )

    $nsList = Get-NameServerList $NameServer -IgnoreActive
    if ($nsList) {
        Write-Verbose "New active nameservers: $(($nsList | ForEach-Object { $_.ToString() }) -join ',')"
        $script:ActiveNameServers = $nsList
    }

    $cOpts = Get-LookupClientOptions
    $dirtyOptions = $false
    $psbKeys = $PSBoundParameters.Keys

    # deal with all the switch parameters
    # UseExtendedDns is not here because it's not directly settable.
    # It's a calculated property based on ExtendedDnsBufferSize and RequestDnsSecRecords.
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
        'MinimumCacheTimeout'
        'MaximumCacheTimeout'
        'RequestDnsSecRecords'
    )
    foreach ($pName in $paramNames) {
        if ($pName -in $psbKeys -and $cOpts.$pName -ne $PSBoundParameters[$pName]) {
            Write-Verbose "$pName set to $($PSBoundParameters[$pName])"
            $cOpts.$pName = $PSBoundParameters[$pName]
            $dirtyOptions = $true
        }
    }

    # make a new client instance if the options have been changed
    if ($dirtyOptions) {
        Write-Debug "Creating new LookupClient with changed options"
        $script:Client = [DnsClient.LookupClient]::new($cOpts)
    }


    <#
    .SYNOPSIS
        Change the currently active nameservers or resolver settings.

    .DESCRIPTION
        There are a variety of configurable options relating to how the resolver makes DNS queries. Use this function to set them.

    .PARAMETER NameServer
        One or more DNS server hostnames or IP addresses. The port is assumed to be 53 unless the server is followed by ":<port>" where <port> is an alternative listening port.

    .PARAMETER UseCache
        If specified, response caching is enabled. The cache duration is calculated by the resource record of the response. Usually, the lowest TTL is used.

    .PARAMETER Recursion
        If specified, DNS queries should instruct the DNS server to do recursive lookups.

    .PARAMETER Timeout
        [TimeSpan] used for limiting the connection and request time for one operation. Timeout must be greater than zero and less than [TimeSpan]::MaxValue. If [Threading.Timeout]::InfiniteTimeSpan is used, no timeout will be applied. Default is 5 seconds.

    .PARAMETER Retries
        The number of tries to get a response from one name server before trying the next one. Only transient errors, like network or connection errors will be retried. Default is 2 which will be three tries total.

    .PARAMETER ThrowDnsErrors
        If specified, the resolver should throw a DnsResponseException in case the query result has a DnsResponseCode other than NoError. Default is False.

    .PARAMETER UseRandomNameServer
        If specified, the resolver will cycle through all configured NameServers on each consecutive request, basically using a random server. Default is True. If only one NameServer is configured, this setting is not used.

    .PARAMETER ContinueOnDnsError
        If specified, the resolver will query the next configured NameServer if the last query returned a DnsResponseCode other than NoError. Default is True.

    .PARAMETER ContinueOnEmptyResponse
        If specified, the resolver will query the next configured NameServer if the response does not have an error DnsResponseCode but the query was not answered by the response. Default is True.

    .PARAMETER UseTcpFallback
        If specified, the resolver will retry using TCP when a UDP response is truncated. Default is True.

    .PARAMETER UseTcpOnly
        If specified, the resolver will never use UDP. Default is False. Enable this only if UDP cannot be used because of your firewall rules for example. Also, zone transfers must use TCP only.

    .PARAMETER ExtendedDnsBufferSize
        The maximum buffer used for UDP requests. Defaults to 4096. If this value is less or equal to 512 bytes, EDNS might be disabled.

    .PARAMETER EnableAuditTrail
        If specified, DNS responses will contain an AuditTrail property which contains a human readable version of the response similar to dig output. Default is False.

    .PARAMETER MinimumCacheTimeout
        [TimeSpan] which can override the TTL of a resource record in case the TTL of the record is lower than this minimum value. Default is Null. This is useful in case the server retruns records with zero TTL.

    .PARAMETER MaximumCacheTimeout
        [TimeSpan] which can override the TTL of a resource record in case the TTL of the record is higher than this maximum value. Default is Null.

    .PARAMETER RequestDnsSecRecords
        If specified, EDNS should be enabled and the DO flag should be set. Defaults to False.

    .EXAMPLE
        Set-DnsClientSetting -NameServer ns1.example.com,ns2.example.com

        Set the specified nameservers for the current resolver instance.

    .EXAMPLE
        Set-DnsClientSetting -NameServer 127.0.0.1:5353

        Set a nameserver IP address with an alternate port.

    .EXAMPLE
        Set-DnsClientSetting -UseCache -MaximumCacheTimeout [TimeSpan]::FromMinutes(1)

        Enable the resolver cache but cap all response TTLs at 1 minute.

    .EXAMPLE
        Set-DnsClientSetting -Recursion:$false

        Disable recursive queries.

    .EXAMPLE
        Set-DnsClientSetting -Timeout [Threading.Timeout]::InfiniteTimeSpan

        Disable query timeouts.

    .LINK
        Get-DnsClientSetting

    #>
}
