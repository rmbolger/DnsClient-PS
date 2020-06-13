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


}
