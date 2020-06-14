using namespace DnsClient

function Resolve-Dns {
    [OutputType([DnsClient.DnsQueryResponse])]
    [CmdletBinding(DefaultParameterSetName='QuestionParts')]
    param(
        [Parameter(
            ParameterSetName = 'QuestionParts',
            Mandatory,
            Position=0,
            ValueFromPipeline)]
        [string[]]$Query,

        [Parameter(
            ParameterSetName = 'QuestionParts',
            Position=1)]
        [QueryType]$QueryType = [QueryType]::A,

        [Parameter(
            ParameterSetName = 'QuestionParts'
        )]
        [QueryClass]$QueryClass = [QueryClass]::IN,

        [Parameter(
            ParameterSetName = 'QuestionObject',
            Position=0,
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('Questions')]
        [DnsQuestion[]]$Question,

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

        # build the question object(s) out of the parts
        if ('QuestionParts' -eq $PSCmdlet.ParameterSetName) {

            $Question = foreach ($qry in $Query) {
                if ($QueryType -eq [QueryType]::PTR -and
                    $qry -notmatch '\.in-addr\.arpa(?:\.)?')
                {
                    [LookupClient]::GetReverseQuestion($qry)
                } else {
                    [DnsQuestion]::new($qry, $QueryType, $QueryClass)
                }
            }
        }

        foreach ($qst in $Question) {

            if ($qOpts) {
                $client.QueryServer($nsList, $qst, $qOpts)
            } else {
                $client.QueryServer($nsList, $qst)
            }

        }

    }

    <#
    .SYNOPSIS
        Perform a DNS query.

    .DESCRIPTION
        Performs a DNS query using the specified query parameters and returns a DnsQueryResponse object.

    .PARAMETER Query
        One or more query strings such as 'www.example.com', '192.168.0.1', or '1.0.168.192.in-addr.arpa'.

    .PARAMETER QueryType
        A query type such as A, AAAA, MX, TXT, SOA, or NS.

    .PARAMETER QueryClass
        A query class such as IN.

    .PARAMETER Question
        A DnsQuestion object that represents a query, type, and class.

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

    .PARAMETER RequestDnsSecRecords
        If specified, EDNS should be enabled and the DO flag should be set. Defaults to False.

    .EXAMPLE
        Resolve-Dns -Query google.com

        Perform a basic A record query against the OS configured nameservers.

    .EXAMPLE
        Resolve-Dns google.com -QueryType AAAA -NameServer 192.168.0.1

        Perform a AAAA record query against a specific nameserver.

    .EXAMPLE
        Resolve-Dns 8.8.8.8 PTR

        Perform a PTR query using an IP address

    .EXAMPLE
        Resolve-Dns 1.0.168.192.in-addr.arpa. PTR

        Perform a PTR query using 'in-addr.arpa' format.

    .EXAMPLE
        Resolve-Dns google.com NS -Recursive:$false | Select-Object -Expand Answers

        Perform a non-recursive NS query and only display the answers.

    .EXAMPLE
        'example.com','example.net','example.org' | Resolve-Dns

        Perform A record lookups against for multiple queries using the pipeline.

    .LINK
        Project: https://github.com/rmbolger/DnsClient-PS

    .LINK
        Set-DnsClientSetting

    .LINK
        Get-DnsClientSetting

    #>
}
