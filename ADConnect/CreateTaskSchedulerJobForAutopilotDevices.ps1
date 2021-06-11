$credential = Get-Credential
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -command "& {.\Sync-NewAutopilotComputerstoAAD.ps1}"' -WorkingDirectory "C:\Scripts\"
$trigger = New-ScheduledTaskTrigger -Daily -At 12am
$task = Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Sync-NewAutopilotComputerstoAAD" -Description "Monitors an OU for computers created in the last 5 minutes, and forces a sync to AAD" -User $credential.UserName -Password $credential.GetNetworkCredential().Password
$task.Triggers.Repetition.Interval = "PT5M"
$task.Triggers.Repetition.Duration = "PT24H"
$task | Set-ScheduledTask -User $credential.UserName -Password $credential.GetNetworkCredential().Password