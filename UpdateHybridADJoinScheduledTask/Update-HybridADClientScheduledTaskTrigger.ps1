<#
Version: 1.0
Author:  Alex Durrant
Script:  Update-HybridADClientScheduledTaskTrigger.ps1
Date:    18/01/2023
Description:
Reconfigures the built-in Automatic-Device-Join scheduled task trigger for user logon only from 1 minute delay to 2 minutes if it exists, this is used for Hybrid AD join when pre-login VPN solutions either drop or reconnect on very first login.
Release notes:
Version 1.0: Original published version.
The script is provided "AS IS" with no warranties.
#>

$task = "Automatic-Device-Join"
$taskExists = Get-ScheduledTask | Where-Object {$_.TaskName -like $task}
$taskName = $taskExists

if($taskExists) {
    Write-output "$Task scheduled task is being reconfigured..."
    $RepeatingTrigger = $Taskname.Triggers[0]
    $RepeatingTrigger.Delay = "PT2M"
    Set-ScheduledTask -InputObject $TaskName
} else {
   Write-output "$Task scheduled task does NOT exist on this device..."
   Exit 0   
}
