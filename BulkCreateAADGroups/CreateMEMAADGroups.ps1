<#
.SYNOPSIS
    Use this script to bulk create common AAD dynamic groups for use within Microsoft Endpoint Manager (Intune)
.DESCRIPTION
    Use this script to bulk create common AAD dynamic groups for use within Microsoft Endpoint Manager (Intune), the script will prompt you to select which sections of groups to create and will prompt for a prefix.
.NOTES
    Script name: CreateIntuneAADGroups.ps1
    Author:      Alex Durrant
    Contact:     @adurrante
    DateCreated: 30/06/2022
    DateUpdated: 09/01/2024
#>


## Install Azure AD Preview PS Module
if (Get-Module -ListAvailable -Name AzureADPreview) {
} 
else {
    Write-Host "Installing AzureAD PowerShell Module" -ForegroundColor Green       
    Install-Module -Name AzureADPreview -AllowClobber -Force
}

## Import Azure AD Preview Module
Write-Host "Importing AzureADPreview Module" -ForegroundColor Green
Import-Module AzureADPreview

## Sign into Azure AD
Write-Host "Please log into AzureAD" -ForegroundColo Green
Connect-AzureAD

## Set global Variables and present user with questions of which sections to run

$Prefix = $(Write-Host 'Please enter in the prefix of your AAD groups, e.g. Intune (Do not enter a hyphen, this will be added automatically after the prefix): ' -ForegroundColor Green -NoNewline; Read-Host) # This prefixes all group names once created.
$DeployIntuneBaseGroups = $(Write-Host "Do you want to create Intune Base groups (Y/N)?: " -ForegroundColor Green -NoNewline; Read-Host)
$DeployAutopilotGroups = $(Write-Host "Do you want to create Autopilot specific groups (Y/N)?: " -ForegroundColor Green -NoNewline; Read-Host)
$DeployAndroidGroups = $(Write-Host "Do you want to create Android specific groups (Y/N)?: " -ForegroundColor Green -NoNewline; Read-Host)
$DeployiOSandiPadOSGroups = $(Write-Host "Do you want to create iOS/iPadIS specific groups (Y/N)?: " -ForegroundColor Green -NoNewline; Read-Host)
$DeploymacOSOSGroups = $(Write-Host "Do you want to create macOS specific groups (Y/N)?: " -ForegroundColor Green -NoNewline; Read-Host)
$DeployWindowsGroups = $(Write-Host "Do you want to create Windows specific groups (Y/N)?: " -ForegroundColor Green -NoNewline; Read-Host)

####################### General Intune Dynamic Groups
if ($DeployIntuneBaseGroups -eq 'Y') {
        Write-Host "Creating Intune Base Dynamic AAD Groups" -ForegroundColor Green
    
    ## 1 -  All Users licenced for Microsoft Intune SKU

    $Groupname = "$Prefix-ALL-DU-IntuneLicenced"
    $Desc = "Contains all users licenced for Microsoft Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "user.assignedPlans -any (assignedPlan.servicePlanId -eq ""c1ec4a95-1f05-45b3-a911-aa3fa01094f5"" -and assignedPlan.capabilityStatus -eq ""Enabled"")" `
        -MembershipRuleProcessingState 'On'


    ## 2 - All Company Owned Devices

    $Groupname = "$Prefix-ALL-DD-CorpOwned"
    $Desc = "Contains all corporate owned devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceOwnership -eq ""Company"")" `
        -MembershipRuleProcessingState 'On'

    ## 3 - All Personally Owned Devices

    $Groupname = "$Prefix-ALL-DD-BYODOwned"
    $Desc = "Contains all personally owned devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceOwnership -eq ""Personal"")" `
        -MembershipRuleProcessingState 'On'

} else {
    Write-Warning -Message "Intune Base Dynamic AAD Groups will NOT be created." -ForegroundColor Yellow
}

####################### Autopilot Specific Device Queries
if ($DeployAutopilotGroups -eq 'Y') {
    $GroupTag = $(Write-Host 'Please enter in the desired Autopilot group tag: ' -ForegroundColor Green -NoNewline; Read-Host) # Used for Autopilot, to create AAD device groups containing specific group tags and groups WITHOUT group tags.
    Write-Host "Creating Autopilot Dynamic AAD Groups" -ForegroundColor Green

    ## 4 - All Autopilot Devices

    $Groupname = "$Prefix-AUTO-DD-AllDevices"
    $Desc = "Contains all Autopilot devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.devicePhysicalIDs -any (_ -startsWith ""[ZTDid]""))" `
        -MembershipRuleProcessingState 'On'


    ## 5 - All Autopilot Devices with a specific group tag (Ensure group tag is set when prompted)

    $Groupname = ("$Prefix-AUTO-DD-" + $GroupTag + "Devices")
    $Desc = "Contains all Autopilot devices with a group tag of '$GroupTag' within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.devicePhysicalIds -any _ -eq ""[OrderID]:$GroupTag"")" `
        -MembershipRuleProcessingState 'On'

    ## 6 - All Autopilot Devices WITHOUT a specific group tag (Ensure group tag is set when prompted)

    $Groupname = "$Prefix-AUTO-DD-AllDevicesExcept$GroupTag"
    $Desc = "Contains all Autopilot devices without a group tag of '$GroupTag' within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.devicePhysicalIDs -any (_ -startsWith ""[ZTDid]"")) -and (device.devicePhysicalIDs -notcontains ""[OrderID]:$GroupTag"")" `
        -MembershipRuleProcessingState 'On'

} else {
    Write-Warning -Message "Autopilot Dynamic AAD Groups will NOT be created." -ForegroundColor Yellow
}

####################### Andriod Specific Device Queries
if ($DeployAndroidGroups -eq 'Y') {
    Write-Host "Creating Android Dynamic AAD Groups" -ForegroundColor Green
    
    ## 7 - All Android Devices

    $Groupname = "$Prefix-AND-DD-AllDevices"
    $Desc = "Contains all Android devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceOSType -match ""Android"")" `
        -MembershipRuleProcessingState 'On'

    ## 8 - All Corporate Owned Android Devices

    $Groupname = "$Prefix-AND-DD-AllCorpDevices"
    $Desc = "Contains all corporate owned Android devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceOSType -eq ""Android"") -and (device.deviceOwnership -eq ""Company"")" `
        -MembershipRuleProcessingState 'On'

    ## 9 - All Personally Owned Android Devices

    $Groupname = "$Prefix-AND-DD-AllBYODDevices"
    $Desc = "Contains all personally owned Android devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceOSType -eq ""Android"") -and (device.deviceOwnership -eq ""Personal"")" `
        -MembershipRuleProcessingState 'On'

     ## 10 - All Android Enterprise Devices

    $Groupname = "$Prefix-AND-DD-AllEntDevices"
    $Desc = "Contains all Android Enterprise devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceOSType -match ""AndroidEnterprise"")" `
        -MembershipRuleProcessingState 'On'

     ## 11 - All Android Work Profile Devices

    $Groupname = "$Prefix-AND-DD-WPDevices"
    $Desc = "Contains all Android Work Profile devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceOSType -eq ""AndroidForWork"") and (device.managementType -eq ""MDM"")" `
        -MembershipRuleProcessingState 'On'


     ## 12 - All Android Full Managed Devices

    $Groupname = "$Prefix-AND-DD-FullMgdDevices"
    $Desc = "Contains all Android Fully Managed devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceOSType -eq ""AndroidEnterprise"") -and (device.enrollmentProfileName -eq null)" `
        -MembershipRuleProcessingState 'On'

} else {
    Write-Warning -Message "Android Dynamic AAD Groups will NOT be created." -ForegroundColor Yellow
}

####################### iOS/iPad Specific Device Queries
if ($DeployiOSandiPadOSGroups -eq 'Y') {
    Write-Host "Creating iOS and iPadOS Dynamic AAD Groups" -ForegroundColor Green

     ## 13 - All iPad Devices

    $Groupname = "$Prefix-iPad-DD-AllDevices"
    $Desc = "Contains all iPad devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceOSType -eq ""iPad"")" `
        -MembershipRuleProcessingState 'On'

     ## 14 - All iPhone Devices

    $Groupname = "$Prefix-iPhone-DD-AllDevices"
    $Desc = "Contains all iPhone devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceOSType -eq ""iPhone"")" `
        -MembershipRuleProcessingState 'On'

     ## 15 - All Corporate Owned iPads

    $Groupname = "$Prefix-iPad-DD-AllCorpDevices"
    $Desc = "Contains all Corporate owned iPad devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceOSType -eq ""iPad"") -and (device.deviceOwnership -eq ""Company"")" `
        -MembershipRuleProcessingState 'On'

     ## 16 - All Personally Owned iPads

    $Groupname = "$Prefix-iPad-DD-AllBYODDevices"
    $Desc = "Contains all personally owned iPad devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceOSType -eq ""iPad"") -and (device.deviceOwnership -eq ""Personal"")" `
        -MembershipRuleProcessingState 'On'

     ## 17 - All Corporate Owned iPhones

    $Groupname = "$Prefix-iPhone-DD-AllCorpDevices"
    $Desc = "Contains all Corporate owned iPhone devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceOSType -eq ""iPhone"") -and (device.deviceOwnership -eq ""Company"")" `
        -MembershipRuleProcessingState 'On'

     ## 18 - All Personally Owned iPhones

    $Groupname = "$Prefix-iPhone-DD-AllBYODDevices"
    $Desc = "Contains all personally owned iPhone devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceOSType -eq ""iPhone"") -and (device.deviceOwnership -eq ""Personal"")" `
        -MembershipRuleProcessingState 'On'

} else {
    Write-Warning -Message "iOS and iPadOS Dynamic AAD Groups will NOT be created." -ForegroundColor Yellow
}

if ($DeploymacOSOSGroups -eq 'Y') {
        Write-Host "Creating macOS Dynamic AAD Groups" -ForegroundColor Green

     ## 19 - All macOS Devices

    $Groupname = "$Prefix-Mac-DD-AllDevices"
    $Desc = "Contains all macOS devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceOSType -eq ""MacMDM"")" `
        -MembershipRuleProcessingState 'On'

     ## 20 - All Corporate Owned macOS Devices

    $Groupname = "$Prefix-Mac-DD-AllCorpDevices"
    $Desc = "Contains all corporate owned macOS devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceOSType -eq ""MacMDM"") -and (device.deviceOwnership -eq ""Company"")" `
        -MembershipRuleProcessingState 'On'
    
     ## 21 - All Personally Owned macOS Devices

    $Groupname = "$Prefix-Mac-DD-AllBYODDevices"
    $Desc = "Contains all personally owned macOS devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceOSType -eq ""MacMDM"") -and (device.deviceOwnership -eq ""Personal"")" `
        -MembershipRuleProcessingState 'On'

} else {
    Write-Warning -Message "macOS Dynamic AAD Groups will NOT be created." -ForegroundColor Yellow
}


####################### Windows Device Queries
if ($DeployWindowsGroups -eq 'Y') {
    Write-Host "Creating Windows Dynamic AAD Groups" -ForegroundColor Green

         ## 22 - All Windows Devices within Intune

    $Groupname = "$Prefix-WIN-DD-AllDevices"
    $Desc = "Contains all Windows devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceOSType -eq ""Windows"") -and (device.managementType -eq ""MDM"")" `
        -MembershipRuleProcessingState 'On'


         ## 23 - All Windows 10 Devices within Intune

    $Groupname = "$Prefix-WIN-DD-AllW10Devices"
    $Desc = "Contains all Windows 10 devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceOSType -eq ""Windows"") and (device.deviceOSVersion -contains ""10.0.1"") -and (device.managementType -eq ""MDM"")" `
        -MembershipRuleProcessingState 'On'

         ## 24 - All Windows 11 Devices within Intune

    $Groupname = "$Prefix-WIN-DD-AllW11Devices"
    $Desc = "Contains all Windows 11 devices within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceOSType -eq ""Windows"") and (device.deviceOSVersion -contains ""10.0.2"") -and (device.managementType -eq ""MDM"")" `
        -MembershipRuleProcessingState 'On'

        ## 25 - All Devices Managed via ConfigMgr

    $Groupname = "$Prefix-WIN-DD-SCCMMgdDevices"
    $Desc = "Contains all Windows devices managed by ConfigMgr within Intune"

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(device.deviceManagementAppId -eq ""54b943f8-d761-4f8d-951e-9cea1846db5a"")" `
        -MembershipRuleProcessingState 'On'
		
		
		## 26 - Patch Management - Pilot

    $Groupname = "$Prefix-WIN-US-Update-PilotUsers"
    $Desc = "Contains all users targeted for the pilot phase of Windows Update for Business and Driver Updates."

    New-AzureADGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" 
		
		## 27 - Patch Management - UAT

    $Groupname = "$Prefix-WIN-US-Update-UATUsers"
    $Desc = "Contains all users targeted for the UAT phase of Windows Update for Business and Driver Updates."

    New-AzureADGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" 
		
	    ## 28 - Patch Management - Broad  (All Users licenced for Microsoft Intune SKU)

    $Groupname = "$Prefix-ALL-DU-Update-Broad"
    $Desc = "Contains all Intune licenced users that are targeted for the UAT phase of Windows Update for Business and Driver Updates."

    New-AzureADMSGroup `
        -Description "$Desc" `
        -DisplayName "$Groupname" `
        -MailEnabled $false `
        -SecurityEnabled $true `
        -MailNickname "$Groupname" `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "user.assignedPlans -any (assignedPlan.servicePlanId -eq ""c1ec4a95-1f05-45b3-a911-aa3fa01094f5"" -and assignedPlan.capabilityStatus -eq ""Enabled"")" `
        -MembershipRuleProcessingState 'On'

} else {
    Write-Warning -Message "Windows Dynamic AAD Groups will NOT be created." -ForegroundColor Yellow
}

#Script completed message
Write-Host "Script execution complete, enjoy your groups!" -ForegroundColor Green
