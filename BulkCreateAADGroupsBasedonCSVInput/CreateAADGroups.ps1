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

## Import CSV and variables
$Groups = Import-Csv -Path "<CSV Location>"
$dynamicGroupTypeString = "DynamicMembership"

## Create Groups

foreach($Group in $Groups)
{
New-AzureADMSGroup -DisplayName $Group.DisplayName -Description $Group.Description -MailEnabled $False -MailNickName $Group.DisplayName -SecurityEnabled $True -membershipRule $Group.MembershipRule -GroupTypes $dynamicGroupTypeString -MembershipRuleProcessingState "On"
} 
