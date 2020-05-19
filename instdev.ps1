#Requires -Version 5.1

# set the user module path based on edition and platform
if ('PSEdition' -notin $PSVersionTable.Keys -or $PSVersionTable.PSEdition -eq 'Desktop') {
    $installpath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'WindowsPowerShell\Modules'
} else {
    if ($IsWindows) {
        $installpath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\Modules'
    } else {
        $installpath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) '.local/share/powershell/Modules'
    }
}

# create user-specific modules folder if it doesn't exist
New-Item -ItemType Directory -Force -Path $installpath | out-null

if ([String]::IsNullOrWhiteSpace($PSScriptRoot)) {
    # likely running from online, so download
    $webclient = New-Object System.Net.WebClient
    $url = 'https://github.com/rmbolger/DnsClient-PS/archive/master.zip'
    Write-Host "Downloading latest version of DnsClient-PS from $url" -ForegroundColor Cyan
    $file = Join-Path ([system.io.path]::GetTempPath()) 'DnsClient-PS.zip'

    # GitHub now requires TLS 1.2
    # https://blog.github.com/2018-02-23-weak-cryptographic-standards-removed/
    $currentMaxTls = [Math]::Max([Net.ServicePointManager]::SecurityProtocol.value__,[Net.SecurityProtocolType]::Tls.value__)
    $newTlsTypes = [enum]::GetValues('Net.SecurityProtocolType') | Where-Object { $_ -gt $currentMaxTls }
    $newTlsTypes | ForEach-Object {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor $_
    }

    $webclient.DownloadFile($url,$file)
    Write-Host "File saved to $file" -ForegroundColor Green

    # extract the zip
    Write-Host "Uncompressing the Zip file to $($installpath)" -ForegroundColor Cyan
    Expand-Archive $file -DestinationPath $installpath

    Write-Host "Removing any old copy" -ForegroundColor Cyan
    Remove-Item "$installpath\DnsClient-PS" -Recurse -Force -EA Ignore
    Write-Host "Renaming folder" -ForegroundColor Cyan
    Copy-Item "$installpath\DnsClient-PS-master\DnsClient-PS" $installpath -Recurse -Force -EA Continue
    Remove-Item "$installpath\DnsClient-PS-master" -recurse -confirm:$false
    Import-Module -Name DnsClient-PS -Force
} else {
    # running locally
    Remove-Item "$installpath\DnsClient-PS" -Recurse -Force -EA Ignore
    Copy-Item "$PSScriptRoot\DnsClient-PS" $installpath -Recurse -Force -EA Continue
    # force re-load the module (assuming you're editing locally and want to see changes)
    Import-Module -Name DnsClient-PS -Force
}
Write-Host 'Module has been installed' -ForegroundColor Green

Get-Command -Module DnsClient-PS