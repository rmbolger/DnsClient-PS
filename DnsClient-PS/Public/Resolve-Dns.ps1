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
        One or more name server FQDNs or IP addresses optionally with a port appended such as 'ns.example.com', '192.168.0.1', or 'ns.example.com:53'.

    .PARAMETER UseCache
        Whether DNS queries should use response caching or not. The cache duration is calculated by the resource record of the response. Usually, the lowest TTL is used.

    .PARAMETER Recursion
        Whether DNS queries should instruct the DNS server to do recursive lookups, or not.

    .PARAMETER Timeout
        TimeSpan used for limiting the connection and request time for one operation. Timeout must be greater than zero and less than 2147483647 milliseconds. If System.Threading.Timeout.InfiniteTimeSpan is used, no timeout will be applied.

    .PARAMETER Retries
        Number of tries to get a response from one name server before trying the next one. Only transient errors, like network or connection errors will be retried. Default is 2 which will be three tries total.

    .PARAMETER ThrowDnsErrors
        If specified, a DnsResponseException is thrown when the query result has a DnsResponseCode other than NoError.

    .PARAMETER UseRandomNameServer
        If specified, the client will randomly choose one of the configured NameServers on each consecutive request. If only one NameServer is configured, this setting is not used.

    .PARAMETER ContinueOnDnsError
        Whether to query the next configured NameServers in case the response of the last query returned a DnsResponseCode other than NoError.

    .PARAMETER ContinueOnEmptyResponse
        Whether to query the next configured NameServers if the response does not have an error DnsResponseCode but the query was not answered by the response.

    .PARAMETER UseTcpFallback
        Whether TCP should be used in case a UDP response is truncated.

    .PARAMETER UseTcpOnly
        If specified, UDP will not be used at all. Enable this only if UDP cannot be used because of your firewall rules for example. Also, zone transfers (AXFR) must use TCP only.

    .PARAMETER ExtendedDnsBufferSize
        The maximum buffer used for UDP requests. If this value is less or equal to 512 bytes, EDNS might be disabled.

    .PARAMETER EnableAuditTrail
        If specified, the AuditTrail property of the response object will contain a dig'like log of the DNS conversation.

    .PARAMETER RequestDnsSecRecords
        Whether EDNS should be enabled and the DO flag should be set.

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
