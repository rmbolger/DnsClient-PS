using namespace DnsClient

function Resolve-Dns {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)]
        [string]$Query,
        [Parameter(Position=1)]
        [QueryType]$QueryType = [QueryType]::A,
        [QueryClass]$QueryClass = [QueryClass]::IN,
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
        [switch]$RequestDnsSecRecords
    )

    Begin {
        $client = Get-LookupClient
        $nsList = Get-NameServerList $NameServer
        $qOpts = Resolve-QueryOptions @PSBoundParameters
    }

    Process {
        # Check for IP based PTR
        if ($QueryType -eq [QueryType]::PTR -and
            $Query -notmatch '\.in-addr\.arpa(?:\.)?')
        {
            # We're going to assume anyone asking for a PTR
            # where the query doesn't end with .in-addr.arpa
            # has given us an IP that we can use with
            # QueryServerReverse.

            if ($qOpts) {
                $client.QueryServerReverse($nsList, $Query, $qOpts)
            } else {
                $client.QueryServerReverse($nsList, $Query)
            }

        } else {

            # Everything else should be a standard query question
            $question = [DnsQuestion]::new($Query, $QueryType, $QueryClass)

            if ($qOpts) {
                $client.QueryServer($nsList, $question, $qOpts)
            } else {
                $client.QueryServer($nsList, $question)
            }

        }

    }


}
