## 1.2.0 (2025-09-15)

* Upgraded DnsClient library version to 1.8.0 which includes support for the CERT record type and other bug fixes

## 1.1.1 (2023-05-22)

* Fixed Windows PowerShell support by rolling back the System.Buffers library dependency to 4.4.0 (#2).

## 1.1.0 (2023-03-25)

* Upgraded DnsClient library version to 1.7.0 which includes support for parsing many additional record types including TLSA, RRSIG, DS, NSEC, DNSKEY, NAPTR, NSEC3, NSEC3PARAM, and SPF

## 1.0.0 (2020-06-14)

* Initial Release
* Added functions
  * Get-DnsClientSetting
  * Resolve-Dns
  * Set-DnsClientSetting
