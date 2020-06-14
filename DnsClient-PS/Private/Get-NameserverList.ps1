function Get-NameServerList {
    [OutputType([Collections.Generic.List[DnsClient.NameServer]])]
    [CmdletBinding()]
    param(
        [string[]]$NameServer,
        [switch]$IgnoreActive
    )

    # Since Powershell can't coerce an array of IP addresses into
    # the IReadonlyCollection[NameServer] list we need for the
    # QueryServer* methods in LookupClient and we also want to
    # allow users to use FQDNs for nameservers, we'll do some
    # extra work here to make things "just work"

    # Unless called with -IgnoreActive, this method should always
    # return a valid nameserver list that can be called using
    # LookupClient.QueryServer* methods.

    if (-not $NameServer -or $NameServer.Count -eq 0) {
        if ($IgnoreActive) {
            Write-Debug "Returning null nameservers"
            return $null
        }
        elseif ($script:ActiveNameServers) {
            Write-Debug "Returning ActiveNameServers"
            return ,$script:ActiveNameServers
        }
        else {
            Write-Debug "Returning default nameservers"
            return ,(Get-LookupClient).NameServers
        }
    }

    $nsList = [Collections.Generic.List[DnsClient.NameServer]]::new()

    foreach ($val in $NameServer) {

        # each value here should be an FQDN or IP
        # optionally followed by a ":PORT"

        if (-not $val) {
            Write-Warning "Skipping null nameserver value"
            continue
        }

        # split the nameserver from the port if it exists
        $nsString, $port = $val.Split(':')

        if ([String]::IsNullOrWhiteSpace($nsString)) {
            Write-Warning "Skipping empty nameserver value"
            continue
        }

        # if it's just an IP address, we're done
        if ($ip = $nsString -as [ipaddress]) {

            # WARNING: The [ipaddress] conversion will happily accept
            # integer values and convert them to an IP
            # (e.g. '1' -as [ipaddress] = 0.0.0.1)
            # Technically this is a "feature", but may bite people unaware.

            if ($port -and ($port -as [int]) -gt 0) {
                $ns = [DnsClient.NameServer]::new($ip, $port)
            } else {
                $ns = [DnsClient.NameServer]::new($ip)
            }
            $nsList.Add($ns)
            Write-Debug "Parsed nameserver as $ns"

            continue
        }

        # It's not an IP address, so we'll try and resolve it using the
        # default system resolver.
        $response = Resolve-Dns $nsString
        if ($response.Answers.Count -gt 0) {

            # If there are multiple answers, we're only going to use the first one
            # Time will tell if that comes back to bit us.
            if ($port -and ($port -as [int]) -gt 0) {
                $ns = [DnsClient.NameServer]::new($response.Answers[0].Address, $port)
            } else {
                $ns = [DnsClient.NameServer]::new($response.Answers[0].Address)
            }
            $nsList.Add($ns)
            Write-Debug "Parsed nameserver as $ns"

        } else {
            Write-Warning "Unable to resolve nameserver $nsString to an IP address. Skipping."
        }

    }

    # return what we've got if there is anything
    if ($nsList.Count -gt 0) {
        Write-Debug "Returning converted nameservers"
        return ,$nsList
    } elseif (-not $IgnoreActive) {
        Write-Debug "Returning default nameservers"
        return ,(Get-LookupClient).NameServers
    } else {
        Write-Debug "Returning null nameservers"
        return $null
    }

}
