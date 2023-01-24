
[CmdletBinding()]
param (
    [Parameter()][string]$PolicyName,
    [Parameter()][string]$Assignment,
    [Parameter()][string]$ComputernamePrefix,
    [Parameter()][string]$ActiveDirectoryFQDN,
    [Parameter()][string]$OUname
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
$DomainOUs = Import-Csv -Path "<<YOUR CSV PATH>>"

	
#Importing Module
Write-Host "Importing Module $Module_Name"
Import-Module $Module_Name

# Get Token
$AuthToken = Get-MsalToken -ClientId d1ddf0e4-d672-4dae-b554-9d5bdfd93547 -RedirectUri "urn:ietf:wg:oauth:2.0:oob" -Interactive

foreach($DomainOU in $DomainOUs)
{	

#Create Policy Parameter Object
$Profile = @{
	"@odata.type" = "#microsoft.graph.windowsDomainJoinConfiguration";
    displayName = $DomainOU.PolicyName;
    computerNameStaticPrefix = $DomainOU.ComputernamePrefix;
    activeDirectoryDomainName = $DomainOU.ActiveDirectoryFQDN;
    computerNameSuffixRandomCharCount = 10;
    organizationalUnit = $DomainOU.OUname
}	
#Convert Policy Parameter Object to JSON
$requestBody = $Profile | ConvertTo-Json #-Depth 5
#Create Policy via Graph
$URL = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations"
$CreateProfile = Invoke-RestMethod -Headers @{Authorization = "Bearer $($AuthToken.AccessToken)" }  -Uri $URL -Method POST -Body $requestBody -ContentType 'application/json'
#Detect whether Policy has been created
if ($CreateProfile){
    Write-Host "Policy created successfully" -ForegroundColor green
}
else {
    Write-Host "Error creating policy" -ForegroundColor red
}

## Assign Policy to All Devices
if ($DomainOU.Assignment -eq "All Devices") {
    $Assignment_JSON = 
    @"
    {
        "source": "direct",
        "intent": "apply",
        "target": {
            "@odata.type": "#microsoft.graph.allDevicesAssignmentTarget",
            "deviceAndAppManagementAssignmentFilterId": null,
            "deviceAndAppManagementAssignmentFilterType": "none"
        }
    }
"@
    $URL = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$($CreateProfile.id)/assignments"
    Invoke-RestMethod -Headers @{Authorization = "Bearer $($AuthToken.AccessToken)" }  -Uri $URL -Method POST -Body $Assignment_JSON -ContentType 'application/json'
}
## Assign Policy to All Users
if ($DomainOU.Assignment -eq "All Users") {
    $Assignment_JSON = 
    @"
    {
        "source": "direct",
        "intent": "apply",
        "target": {
            "@odata.type": "#microsoft.graph.allLicensedUsersAssignmentTarget",
            "deviceAndAppManagementAssignmentFilterId": null,
            "deviceAndAppManagementAssignmentFilterType": "none"
        }
    }
"@
    $URL = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$($CreateProfile.id)/assignments"
    Invoke-RestMethod -Headers @{Authorization = "Bearer $($AuthToken.AccessToken)" }  -Uri $URL -Method POST -Body $Assignment_JSON -ContentType 'application/json'
}
## Assign Policy to a custom group
if ($DomainOU.Assignment -ne "All Devices" -and $DomainOU.Assignment -ne "All Users") {
    $GroupID = $DomainOU.Assignment
    $Assignment_JSON =
    @"
    {
        "source": "direct",
        "intent": "apply",
        "target": {
            "@odata.type": "#microsoft.graph.groupAssignmentTarget",
            "deviceAndAppManagementAssignmentFilterId": null,
            "deviceAndAppManagementAssignmentFilterType": "none",
            "groupId": '$GroupID'
        }
    }
"@
    $URL = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$($CreateProfile.id)/assignments"
    Invoke-RestMethod -Headers @{Authorization = "Bearer $($AuthToken.AccessToken)" }  -Uri $URL -Method POST -Body $Assignment_JSON -ContentType 'application/json'
}

if ($DomainOU.Assignment){
    Write-Host "Profile succesfully assigned!" -ForegroundColor green
}
else {
    Write-Host "Error creating assignment" -ForegroundColor red
}
}
