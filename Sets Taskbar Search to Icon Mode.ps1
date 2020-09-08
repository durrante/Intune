##Sets the taskbar search to icon mode
##HybrIT - Alex Durrant
##V1.0
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value "1" -PropertyType DWORD -Force