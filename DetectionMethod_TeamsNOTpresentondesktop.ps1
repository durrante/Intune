$DesktopPath = [Environment]::GetFolderPath("Desktop")
if (-Not (Test-Path "$DesktopPath\Microsoft Teams*")) {
    Write-Host "Missing"
}