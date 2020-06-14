# DnsClient-PS

A cross-platform DNS client for PowerShell utilizing the DnsClient.NET library.

DNS query options in PowerShell and the native .NET class library have always been disappointing. [Resolve-DnsName](https://docs.microsoft.com/en-us/powershell/module/dnsclient/resolve-dnsname) is a decent addition, but it's only available on Windows and doesn't seem to be headed cross-platform anytime soon. The [System.Net.Dns](https://docs.microsoft.com/en-us/dotnet/api/system.net.dns) namespace is also extremely limited in its capabilities.

[DnsClient.NET](https://dnsclient.michaco.net/) is a simple yet very powerful and high performant open source library for the .NET Framework to do DNS lookups. This module attempts to expose its power in a PowerShell native manner in order to automate DNS tasks without needing to parse the output of utilities like `nslookup` and `dig`. However, it is not intended to be a general replacement for those utilities.

# Notable Features

- Fully supported cross platform
- Low level access to request/response protocol details
- Optional dig'like human readable output
- Optional response cache for performance sensitive tasks

# Install

## Release

The latest release version can found in the [PowerShell Gallery](https://www.powershellgallery.com/packages/DnsClient-PS/) or the [GitHub releases page](https://github.com/rmbolger/DnsClient-PS/releases). Installing from the gallery is easiest using `Install-Module` from the PowerShellGet module. See [Installing PowerShellGet](https://docs.microsoft.com/en-us/powershell/scripting/gallery/installing-psget) if you don't already have it installed.

```powershell
# install for all users (requires elevated privs)
Install-Module -Name DnsClient-PS -Scope AllUsers

# install for current user
Install-Module -Name DnsClient-PS -Scope CurrentUser
```

*NOTE: If you use PowerShell 5.1 or earlier, `Install-Module` may throw an error depending on your Windows and .NET version due to a change PowerShell Gallery made to their TLS settings. For more info and a workaround, see the [official blog post](https://devblogs.microsoft.com/powershell/powershell-gallery-tls-support/).*


## Development

To install the latest *development* version from the git main branch, use the following PowerShell command. This method assumes a default [`PSModulePath`](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_psmodulepath) environment variable.

```powershell
# install latest dev version
iex (irm https://raw.githubusercontent.com/rmbolger/DnsClient-PS/main/instdev.ps1)
```

# Quick Start

The primary function is `Resolve-Dns` and requires a `-Query` parameter that accepts one or more string values. This defaults to an A record lookup against your OS configured DNS server(s).

```powershell
Resolve-Dns -Query google.com

Resolve-Dns google.com

Resolve-Dns 'google.com','www.google.com'

'google.com','www.google.com' | Resolve-Dns
```

The `-QueryType` and `-NameServer` parameters are the other two common ones you'll generally use. NameServer can take an array with IP addresses or FQDNs. Each one can also have an explicit port specified by appending `:<port>`.

```powershell
# Do an AAAA lookup
Resolve-Dns google.com -QueryType AAAA

Resolve-Dns google.com AAAA

# Do an SRV lookup against a domain controller
Resolve-Dns _gc._tcp.contoso.com SRV -NameServer dc1.contoso.com

Resolve-Dns _gc._tcp.contoso.com SRV -ns dc1.contoso.com,dc2.contoso.com

Resolve-Dns _gc._tcp.contoso.com SRV -ns 192.168.0.1:53,dc2.contoso.com:53
```

The output of a successful query is a [DnsQueryResponse](https://dnsclient.michaco.net/docs/DnsClient.DnsQueryResponse.html) object. Its raw form isn't very human readable, but it's quite comprehensive in the detail it provides about the response. If all you care about are the answers, you will want to do something like this.

```powershell
Resolve-Dns google.com | Select-Object -Expand Answers

(Resolve-Dns google.com).Answers
```

Keep in mind that answers for different record types are also different object types with different properties. For example, notice the differences between the following:

```powershell
Resolve-Dns google.com a | Select-Object -Expand Answers | Get-Member
Resolve-Dns google.com txt | Select-Object -Expand Answers | Get-Member
Resolve-Dns google.com soa | Select-Object -Expand Answers | Get-Member
```

There are a number of optional parameters that can alter various settings for a query such as `-Recursion`, `-Timeout`, and `-UseTcpOnly`. These can be set on a per-call basis using the parameters available in `Resolve-Dns` or they can be set as new defaults for the current session using `Set-DnsClientSetting`.

```powershell
# Disable recursion and change the timeout for this call only
Resolve-Dns google.com -ns ns1.google.com -Recursion:$false -Timeout (New-Timespan -Sec 30)

# Change the settings for all queries in this session
Set-DnsClientSettings -ns ns1.google.com -Recursion:$false -Timeout (New-Timespan -Sec 30)
Resolve-Dns google.com

# Check the current session settings
Get-DnsClientSettings
```

# Requirements and Platform Support

* Supports Windows PowerShell 5.1 or later (Desktop edition) **with .NET Framework 4.7.1** or later.
* Supports [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-70) 7.0 or later (Core edition) on all supported OS platforms.
* PowerShell 6.x should also work, but I won't be actively testing against it.

# Changelog

See [CHANGELOG.md](/CHANGELOG.md)
