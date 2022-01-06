Install-Module -Name Microsoft.Graph.Intune
Connect-MSGraph -AdminConsent
Connect-MSGraph
$Devices = Get-IntuneManagedDevice -Filter "contains(operatingsystem, 'iOS')" -select id
$output = Foreach ($Device in $Devices)
{
    Get-IntuneManagedDevice -managedDeviceId $Device.id -select devicename,userDisplayName, emailaddress, userPrincipalName, model, isSupervised, activationLockBypassCode
}

$output | Export-Csv "ios-activation-bypass-codes.csv"
