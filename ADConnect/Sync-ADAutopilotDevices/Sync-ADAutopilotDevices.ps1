<#
.SYNOPSIS
    Finds AD Object on the specified domain, replicates the object to a specific DC and then triggers an AAD Connect sync cycle.
.DESCRIPTION
    This script will find ADObjects within the specified domain that have either been created, modified within the last 10 minutes with a device name containing "MSHDJ", if this is TRUE, then another check will run to see if the userCertificate attribute is present and if so, replicate the object from the source DC to the destination DC for which AADConnect is configured to look at, once the replication has completed, AADConnect delta sync will be triggered
.NOTES
    FileName:    Sync-ADAutopilotDevices.ps1
    Author:      Alex Durrant
    Contact:     @adurrante
    Created:     07/02/2023
    Updated:     07/02/2023
    Version history:
    1.0.0 - (07/02/2023) Script created
#>

#Import ADSync and Active Directory PS Modules if NOT already imported.
if (!(Get-Module -Name "ActiveDirectory")) {
    Import-Module ActiveDirectory
}

if (!(Get-Module -Name "ADSync")) {
    Import-Module ADSync
}

# Define the target DC and target domain
$targetDC = "<< DC >>"
$targetDomain = "<< DOMAIN>>"

# Get a list of all DCs in the target domain
$domainControllers = Get-ADDomainController -Filter * -Server $targetDomain

# Get the current time
$now = Get-Date

# Calculate the time 10 minutes ago
$timeLimit = $now.AddMinutes(-10)

# Set the log file path
$logFile = "C:\scripts\AutopilotADDeviceReplicationObject.log"

# Loop through each DC
foreach ($dc in $domainControllers) {
    # Try to find the computer object
    try {
        Clear-Variable "Computers" -ErrorAction SilentlyContinue
        $computers = Get-ADComputer -Server $dc.HostName -Filter {((whenCreated -gt $timeLimit) -or (whenChanged -gt $timeLimit)) -and (Name -like "*MSHDJ*")} -Properties Name, whenCreated, whenChanged, userCertificate
        if ($computers) {
            $computers = $computers | Where-Object { $_.userCertificate -ne $null }
            foreach ($computer in $computers) {
                Write-Output "$(Get-Date -Format "dd-MM-yyyy HH:mm:ss") Found $($computer.Name) object on $($dc.HostName)" | Out-File -FilePath $logFile -Append
                # Trigger replication to the target DC
                    Sync-ADObject -Source $dc.HostName -Destination $targetDC -Object $computer.DistinguishedName
                    Write-Output "$(Get-Date -Format "dd-MM-yyyy HH:mm:ss") Successfully replicated $($computer.Name) object to $targetDC" | Out-File -FilePath $logFile -Append
                # Sleep for 60 seconds to allow for AD Replication
                Start-Sleep -Seconds 60
                # Trigger AAD Connect delta sync if NOT already running
                $status = Get-ADSyncScheduler
                    if ($status.SyncCycleInProgress -eq $false) {
                        Start-ADSyncSyncCycle -PolicyType Delta
                        Write-Output "$(Get-Date -Format "dd-MM-yyyy HH:mm:ss") Starting AAD Connect sync cycle for $($Computer.name)" | Out-File -FilePath $logFile -Append
                    }
                    else {
                        Write-Output "$(Get-Date -Format "dd-MM-yyyy HH:mm:ss") AAD Connect sync cycle is already running" | Out-File -FilePath $logFile -Append
                    }                
            }
        }
    break
	} catch {
        Write-Output "$(Get-Date -Format "dd-MM-yyyy HH:mm:ss") Error searching on $($dc.HostName): $_" | Out-File -FilePath $logFile -Append
    }
}
