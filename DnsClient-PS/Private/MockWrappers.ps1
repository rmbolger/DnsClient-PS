# The functions in this file exist solely to allow
# easier mocking in Pester tests.

function Get-LookupClient {
    [OutputType([DnsClient.LookupClient])]
    $script:Client
}

function Get-LookupClientOptions {
    [OutputType([DnsClient.LookupClientOptions])]
    $script:ClientOptions
}
