@{

RootModule = 'DnsClient-PS.psm1'
ModuleVersion = '1.0.0'
GUID = '698438cc-f80d-4b88-aa04-16e302c1f326'
Author = 'Ryan Bolger'
Copyright = '(c) 2020 Ryan Bolger. All rights reserved.'
Description = 'A cross-platform DNS client for PowerShell utilizing the DnsClient.NET library.'
CompatiblePSEditions = @('Desktop','Core')
PowerShellVersion = '5.1'
DotNetFrameworkVersion = '4.7.1'

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = @(
    'lib\System.Buffers.4.4.0-netstandard2.0.dll'
    'lib\DnsClient.1.3.1-netstandard2.0.dll'
)

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = 'DnsClient-PS.Format.ps1xml'

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    'Get-DnsClientSetting'
    'Resolve-Dns'
    'Set-DnsClientSetting'
)

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'dns','resolver','dns-client','dns-resolver','dig','nslookup','Linux','Mac'

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/rmbolger/DnsClient-PS/blob/main/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/rmbolger/DnsClient-PS'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = @'
## 1.0 (2020-06-14)

* Initial Release
* Added functions
  * Get-DnsClientSetting
  * Resolve-Dns
  * Set-DnsClientSetting
'@

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
