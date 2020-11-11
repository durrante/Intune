stop-process -Name AzVpnAppx -ErrorAction SilentlyContinue
Copy-Item "$PSScriptRoot\azurevpnconfig.xml" -Destination "$env:userprofile\AppData\Local\Packages\Microsoft.AzureVpn_8wekyb3d8bbwe\LocalState\azurevpnconfig.xml" -Force
azurevpn -i azurevpnconfig.xml -f
Start-Sleep 2
stop-process -Name AzVpnAppx -ErrorAction SilentlyContinue
