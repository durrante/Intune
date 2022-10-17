$ServiceName = 'DellOptimizer'
$Action = 'disabled'
$Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

If (-not (Test-Path -Path 'c:\Program Files\Dell\DellOptimizer\DellOptimizer.exe')){
    Write-Host "Dell Optimizer is not installed on this device"
	exit 0   
} 

If ($service.StartType -eq $Action) {
    Write-Host "$ServiceName is already configured correctly."
    Exit 0
}
else {
    Write-Warning "$ServiceName is not configured correctly."
    Exit 1
}