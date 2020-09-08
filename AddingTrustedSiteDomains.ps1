if (-not (Test-Path -Path 'HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\letsconfigmgr.com'))

{

New-Item -Path 'HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\letsconfigmgr.com'

Set-ItemProperty -Path 'HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\letsconfigmgr.com' -Name https -Value 2 -Type DWord

}