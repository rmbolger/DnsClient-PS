# DnsClient-PS

A simple yet powerful cross-platform DNS client for PowerShell utilizing the DnsClient.NET library.

DNS query options in PowerShell and the native .NET class library have never really been great. [Resolve-DnsName](https://docs.microsoft.com/en-us/powershell/module/dnsclient/resolve-dnsname) is a step in the right direction, but it's only available on Windows and doesn't seem to be headed cross-platform anytime soon. The [System.Net.Dns](https://docs.microsoft.com/en-us/dotnet/api/system.net.dns) namespace is also extremely limited in its capabilities.

[DnsClient.NET](https://dnsclient.michaco.net/) is a simple yet very powerful and high performant open source library for the .NET Framework to do DNS lookups. This module attempts to expose its power in a PowerShell native manner.

# Notable Features

- Fully supported cross platform
- Low level access to request/response protocol details
- Optional dig'esque human readable output
- Optional response cache

# Install

## Release

Not released yet.

## Development

To install the latest *development* version from the git master branch, use the following PowerShell command. This method assumes a default PowerShell environment that includes the [`PSModulePath`](https://msdn.microsoft.com/en-us/library/dd878326.aspx) environment variable. You must also make sure `Get-ExecutionPolicy` does not return `Restricted` or `AllSigned`.

```powershell
# If necessary, set less restrictive execution policy.
# Not needed on non-Windows
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# install latest dev version
iex (irm https://raw.githubusercontent.com/rmbolger/DnsClient-PS/master/instdev.ps1)
```

# Quick Start

TODO

# Requirements and Platform Support

* Supports Windows PowerShell 5.1 or later (Desktop edition) **with .NET Framework 4.7.1** or later.
* Supports [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-70) 7.0 or later (Core edition) on all supported OS platforms.
* PowerShell 6.x should also work, but I won't be actively testing against it.

# Changelog

See [CHANGELOG.md](/CHANGELOG.md)
