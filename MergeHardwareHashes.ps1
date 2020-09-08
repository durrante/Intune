# Set folder locations
$autopilotimportfolder = "C:\Folder With Autopilot Csv Files"
$autopilotoutputfile = "C:\Output\GiantAutopilotFile.csv"
 
# Get all the csv filenames
$gacsv = Get-ChildItem -Path "$autopilotimportfolder" | select Name
 
# Get csv content and paste them to one csv
foreach ($ga in $gacsv) {
        $name = $ga.name
 
        $tmpimp = $autopilotimportfolder
        $tmpimp += "\"
        $tmpimp += "$name"
 
       $tempimport = Import-Csv -Path $tmpimp
       $tempimport | Export-Csv -Path $autopilotoutputfile -NoTypeInformation -Append
 
   }
 