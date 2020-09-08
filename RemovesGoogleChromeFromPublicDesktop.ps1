##Removes Google Chrome from public desktops
##Alex Durrant - HybrIT
##Version 1.0
##www.hybrit.co.uk
$AllUserProfile = ([Environment]::GetEnvironmentVariable("Public"))+"\Desktop"
Remove-Item -Path "$AllUserProfile\Google Chrome.lnk" -ErrorAction SilentlyContinue