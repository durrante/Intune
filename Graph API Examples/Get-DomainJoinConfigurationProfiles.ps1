## Uses Graph API to retrieve all configuration profiles with 'Domain Join' being present in the profile name to a list.

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

#Importing Module
Write-Host "Importing Module $Module_Name"
Import-Module $Module_Name

# Get Token
$AuthToken = Get-MsalToken -ClientId d1ddf0e4-d672-4dae-b554-9d5bdfd93547 -RedirectUri "urn:ietf:wg:oauth:2.0:oob" -Interactive

# Get Graph Response (remember to '`' out any variables that you've created from graph explorer

$IntuneList = Invoke-RestMethod -Headers @{Authorization = "Bearer $($AuthToken.AccessToken)" }  -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations?`$filter=contains(displayName, 'Domain Join')" -Method GET

# Gather the value from the response

$list=$IntuneList.value

# Check the value looks good

$list[0]

# Define your list

$List | Select displayName, Id

# Export to CSV

$List | Select displayName, Id, computerNameStaticPrefix | Export-CSV -Path c:\temp\OutputList2.csv
