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
        [string[]]$NameServer
    )

    $client = Get-LookupClient
    $nsList = Get-NameServerList $NameServer

    # Check for IP based PTR
    if ($QueryType -eq [QueryType]::PTR -and
        $Query -notmatch '\.in-addr\.arpa(?:\.)?')
    {
        # We're going to assume anyone asking for a PTR
        # where the query doesn't end with .in-addr.arpa
        # has given us an IP that we can use with
        # QueryServerReverse.

        $client.QueryServerReverse($nsList, $Query)

    } else {

        # Everything else should be a standard query question
        $question = [DnsQuestion]::new($Query, $QueryType, $QueryClass)

        $client.QueryServer($nsList, $question)

    }

}
