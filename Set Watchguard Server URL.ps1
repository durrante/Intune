##Creates Watchguard Server URL for Servium
##Alex Durrant - HybrIT
if((Test-Path -LiteralPath "HKCU:\SOFTWARE\WatchGuard\SSLVPNClient\Settings") -ne $true) {  New-Item "HKCU:\SOFTWARE\WatchGuard\SSLVPNClient\Settings" -force -ea SilentlyContinue };
New-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\WatchGuard\SSLVPNClient\Settings' -Name 'Server' -Value 'sslvpn.servium.com' -PropertyType String -Force -ea SilentlyContinue;