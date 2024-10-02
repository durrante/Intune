<#  
Script to delete files and folders older than 7 days in all user download directories
Does not apply to public or administrator accounts

Author: Alex Durrant
Version: V2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
#>

# Define the time threshold for old files and folders (7 days ago)
$thresholdDate = (Get-Date).AddDays(-7)

# Define the log file path
$logFilePath = "C:\Program Files\ScheduledTasks\DownloadsFolderCleanup_log.txt"

# Ensure the ScheduledTasks directory exists
if (-not (Test-Path -Path "C:\Program Files\ScheduledTasks")) {
    New-Item -Path "C:\Program Files\ScheduledTasks" -ItemType Directory -Force
}

# Function to log messages to the log file
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Add-Content -Path $logFilePath -Value $logEntry
}

Log-Message "Starting cleanup process."

# Get all user profile directories excluding Default, Public, and Administrator
$userProfiles = Get-WmiObject -Class Win32_UserProfile | Where-Object {
    $_.Special -eq $false -and
    $_.LocalPath -notmatch 'Default|Public|Administrator'
} | Select-Object -ExpandProperty LocalPath

foreach ($profile in $userProfiles) {
    # Define the Downloads directory path for the current user profile
    $downloadsPath = Join-Path -Path $profile -ChildPath 'Downloads'
    
    if (Test-Path -Path $downloadsPath) {
        # Get all files in the Downloads directory older than the threshold date
        $oldFiles = Get-ChildItem -Path $downloadsPath -File -Recurse | Where-Object {
            $_.LastWriteTime -lt $thresholdDate
        }

        foreach ($file in $oldFiles) {
            try {
                # Forcefully delete the old file
                Remove-Item -Path $file.FullName -Force -ErrorAction Stop
                Log-Message "Deleted file: $($file.FullName)"
            } catch {
                Log-Message "Failed to delete file: $($file.FullName). Error: $_"
            }
        }

        # Get all directories in the Downloads directory older than the threshold date
        $oldFolders = Get-ChildItem -Path $downloadsPath -Directory -Recurse | Where-Object {
            $_.LastWriteTime -lt $thresholdDate
        }

        foreach ($folder in $oldFolders) {
            try {
                # Forcefully delete the old folder
                Remove-Item -Path $folder.FullName -Recurse -Force -ErrorAction Stop
                Log-Message "Deleted folder: $($folder.FullName)"
            } catch {
                Log-Message "Failed to delete folder: $($folder.FullName). Error: $_"
            }
        }
    } else {
        Log-Message "Downloads directory not found for profile: $profile"
    }
}

Log-Message "Cleanup process completed."
