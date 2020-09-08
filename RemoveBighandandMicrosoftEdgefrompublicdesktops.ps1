##Removes Bighand and Microsoft Edge from public desktops
##Alex Durrant - HybrIT
##Version 1.0
##www.hybrit.co.uk
$AllUserProfile = ([Environment]::GetEnvironmentVariable("Public"))+"\Desktop"
Remove-Item -Path "$AllUserProfile\BigHand Hub.lnk" -ErrorAction SilentlyContinue
Remove-Item -Path "$AllUserProfile\Microsoft Edge.lnk" -ErrorAction SilentlyContinue