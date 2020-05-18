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

    # Reverse Lookup
    if ([QueryType]::PTR -eq $QueryType) {

        $client.QueryServerReverse($nsList, $Query)

    } else {

        $client.QueryServer($nsList, $Query, $QueryType, $QueryClass)

    }

}
