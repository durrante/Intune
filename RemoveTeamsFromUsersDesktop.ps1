$DesktopPath = [Environment]::GetFolderPath("Desktop")
Remove-item -path $DesktopPath\* -filter "Microsoft Teams*.lnk"