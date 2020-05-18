function Get-DnsClientSetting {
    [CmdletBinding()]
    param()

    # While it would be easy to just return the Settings object off the
    # current LookupClient, it wouldn't necessarily show the active
    # nameserver list and we want to have a bit more control over the output.

    $client = Get-LookupClient

    [pscustomobject]@{
        PSTypeName              = 'DnsClientSettingsPS'
        NameServers             = @((Get-NameServerList) | ForEach-Object { $_.ToString() })
        UseCache                = $client.Settings.UseCache
        Recursion               = $client.Settings.Recursion
        Timeout                 = $client.Settings.Timeout
        Retries                 = $client.Settings.Retries
        ThrowDnsErrors          = $client.Settings.ThrowDnsErrors
        UseRandomNameServer     = $client.Settings.UseRandomNameServer
        ContinueOnDnsError      = $client.Settings.ContinueOnDnsError
        ContinueOnEmptyResponse = $client.Settings.ContinueOnEmptyResponse
        UseTcpFallback          = $client.Settings.UseTcpFallback
        UseTcpOnly              = $client.Settings.UseTcpOnly
        UseExtendedDns          = $client.Settings.UseExtendedDns
        ExtendedDnsBufferSize   = $client.Settings.ExtendedDnsBufferSize
        EnableAuditTrail        = $client.Settings.EnableAuditTrail
        MinimumCacheTimeout     = $client.Settings.MinimumCacheTimeout
        MaximumCacheTimeout     = $client.Settings.MaximumCacheTimeout
        RequestDnsSecRecords    = $client.Settings.RequestDnsSecRecords
    }


    <#
    .SYNOPSIS
        Display the current resolver settings.

    .DESCRIPTION
        There are a variety of configurable options relating to how the resolver makes DNS queries. Use this function to display the current values for all of them. You can change them using Set-DnsClientSetting except for UseExtendedDns because that value is calculated from the values of ExtendedDnsBufferSize and RequestDnsSecRecords.

    .EXAMPLE
        Get-DnsClientSetting

        Display the current resolver settings.

    .LINK
        Set-DnsClientSetting

    #>
}
