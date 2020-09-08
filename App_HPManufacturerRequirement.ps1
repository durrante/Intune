$validManufacturer=@("HP")

if ( $validManufacturer -contains (Get-WmiObject win32_computersystem).Manufacturer){
    Write-Output 1
    Exit 0  
}