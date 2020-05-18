#Requires -Version 5.1

# Before we do anything else, make sure we have a sufficient .NET version that can load
# the .NET Standard 2.0 version of DnsClient.NET. It's supposed to be compatible with
# .NET 4.6.1, but only if the app is compiled to support it (which PowerShell 5.1 is not).
# So it only loads properly on .NET 4.7.1 or later. Any version of .NET Core should
# already work.
if ($PSVersionTable.PSEdition -eq 'Desktop') {
    # https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed#to-check-for-a-minimum-required-net-framework-version-by-querying-the-registry-in-powershell-net-framework-45-and-later
    $netBuild = (Get-ItemProperty "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release
    if ($netBuild -ge 461308) { <# 4.7.1+ - all good #> }
    else {
        if     ($netBuild -ge 460798) { $netVer = '4.7' }
        elseif ($netBuild -ge 394802) { $netVer = '4.6.2' }
        elseif ($netBuild -ge 394254) { $netVer = '4.6.1' }
        elseif ($netBuild -ge 393295) { $netVer = '4.6' }
        elseif ($netBuild -ge 379893) { $netVer = '4.5.2' }
        elseif ($netBuild -ge 378675) { $netVer = '4.5.1' }
        Write-Warning "**********************************************************************"
        Write-Warning "Insufficient .NET version. Found .NET $netVer (build $netBuild)."
        Write-Warning ".NET 4.7.1 or later is required to ensure proper functionality."
        Write-Warning "**********************************************************************"
    }
}

# Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction Ignore )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction Ignore )

# Dot source the files
Foreach($import in @($Public + $Private))
{
    Try { . $import.fullname }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# We need to maintain a LookupClientOptions instance to store the current
# settings for our primary LookupClient. Most of the defaults are fine except
# we'll disable cache so things work more like nslookup/dig by default.
# When users change settings, we'll change them in the options instance and
# create a new client instance based on those options.
$script:ClientOptions = [DnsClient.LookupClientOptions]::new()
$script:ClientOptions.UseCache = $false
$script:Client = [DnsClient.LookupClient]::new($script:ClientOptions)
