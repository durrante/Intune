## Updates the ComputerName Prefix on existing domain join profiles, use https://github.com/durrante/Intune/blob/master/Graph%20API%20Examples/Get-DomainJoinConfigurationProfiles.ps1 to gather profile ID's


[CmdletBinding()]
param (
    [Parameter()][string]$ComputernamePrefix
)

#Checking for correct modules and installing them if needed
$InstalledModules = Get-InstalledModule
$Module_Name = "MSAL.PS"
If ($InstalledModules.name -notcontains $Module_Name) {
	Write-Host "Installing module $Module_Name"
	Install-Module $Module_Name -Force
}
Else {
	Write-Host "$Module_Name Module already installed"
}

## Import CSV and variables
$CSV = Import-Csv -Path "PATH TO CSV" ## Remember to create the CSV with configuration profile ID's and desired computer name prefixes.

	
#Importing Module
Write-Host "Importing Module $Module_Name"
Import-Module $Module_Name

# Get Token
$AuthToken = Get-MsalToken -ClientId d1ddf0e4-d672-4dae-b554-9d5bdfd93547 -RedirectUri "urn:ietf:wg:oauth:2.0:oob" -Interactive

Foreach ($row in $csv)
{	

#Create Policy Parameter Object
$Profile = @{
	"@odata.type" = "#microsoft.graph.windowsDomainJoinConfiguration";
    computerNameStaticPrefix = $Row.computerNameStaticPrefix;
    computerNameSuffixRandomCharCount = 7 # Ensure that the overall number of the prefix and the remaining number listed here is 15 (e.g. if prefix is 5 characters then this setting would be 10 = 15)
}	
#Convert Policy Parameter Object to JSON
$requestBody = $Profile | ConvertTo-Json #-Depth 5
#Create Policy via Graph
$URL = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$($row.ProfileId)"
Invoke-RestMethod -Headers @{Authorization = "Bearer $($AuthToken.AccessToken)" }  -Uri $URL -Method PATCH -Body $requestBody -ContentType 'application/json'
}
