$Certs = Get-ChildItem -Path Cert:\LocalMachine\TrustedPublisher | Where-Object { $_.Thumbprint -eq "5E66E0CA2367757E800E65B770629026E131A7DC" }

if ($Certs) {
    Write-Host "found it"
} else {
    Exit 0
}