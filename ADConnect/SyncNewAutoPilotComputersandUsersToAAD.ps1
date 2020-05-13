##Triggers an ADConnect Delta Sync if new objects are found to be have been created in the OU's in question, this is helpful with Hybrid AD joined devices via Autopilot and avoids the 3rd authenication prompt, change the OU's to match your environment
$time = [DateTime]::Now.AddMinutes(-5)
$computers = Get-ADComputer -Filter 'Created -ge $time' -SearchBase "OU=Autopilot Domain Join,OU=Devices,DC=testdomain,DC=co,DC=uk" -Properties Created
$users = Get-ADUser -Filter 'Created -ge $time' -SearchBase "OU=Accounts,DC=testdomain,DC=co,DC=uk" -Properties Created
if (($null -ne $computers) -or ($null -ne $users)) {
    Start-AdSyncSyncCycle
}
