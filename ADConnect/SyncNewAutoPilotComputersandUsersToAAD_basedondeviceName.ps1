<#
.SYNOPSIS
    Trigger AAD Connect delta sync if device has been created within the OU search base and has a name containing 'MSHDJ' and the user certificate attribute is populated
.DESCRIPTION
    This script will trigger an AAD Connect delta sync if new devices are added to the domain within the OU search base and name contains 'MSHDJ' below.
.NOTES
    FileName:    SyncNewAutoPilotComputersandUsersToAAD_basedondeviceName.ps1
    Author:      Alex Durrant
    Contact:     @adurrante
    Created:     31/01/2023
    Updated:     31/01/2023
    Version history:
    1.0.0 - (31/01/2023) Script created
#>

Import-Module ActiveDirectory

$time = [DateTime]::Now.AddMinutes(-5)
$computers = Get-ADComputer -Filter 'Name -like "*MSHDJ*" -and Modified -ge $time' -SearchBase "OU=AutoPilotDevices,OU=Computers,DC=somedomain,DC=com" -Properties Created, Modified, userCertificate

If ($computers -ne $null) {
    ForEach ($computer in $computers) {
        $diff = $computer.Modified.Subtract($computer.Created)
        If (($diff.TotalHours -le 5) -And ($computer.userCertificate)) {
            # The below adds to AD groups automatically if you want
            #Add-ADGroupMember -Identity "Some Intune Co-management Pilot Device Group" -Members $computer
            $syncComputers = "True"
        }
    }
    # Wait for 30 seconds to allow for some replication
    Start-Sleep -Seconds 30
}

If (($syncComputers -ne $null) -Or ($users -ne $null)) {
    Try { Start-ADSyncSyncCycle -PolicyType Delta }
    Catch {}
}
