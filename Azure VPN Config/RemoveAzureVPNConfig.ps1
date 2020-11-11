stop-process -Name AzVpnAppx -ErrorAction SilentlyContinue
Remove-Item "$env:userprofile\AppData\Local\Packages\Microsoft.AzureVpn_8wekyb3d8bbwe\LocalState\azurevpnconfig.xml" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:userprofile\AppData\Local\Packages\Microsoft.AzureVpn_8wekyb3d8bbwe\LocalState\rasphone.pbk" -Force -ErrorAction SilentlyContinue
