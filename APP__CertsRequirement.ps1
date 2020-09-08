##PowerShell Detection Script to determine if Cert is installed (Change thumbprint)
$Certs = Get-ChildItem -Path Cert:\LocalMachine\TrustedPublisher | Where-Object { $_.Thumbprint -eq "976178E853F0554E0B80C6A2833DB18682186D19" }

if ($Certs) {
    Write-Output 1
} else {
    Exit 0
}