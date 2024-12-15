Set-ExecutionPolicy Bypass -Scope Process -Force

# Define the path for the transcript log file
$logFilePath = "$env:USERPROFILE\Downloads\opensshscripts\session.log"

# Start the transcript to capture everything in the PowerShell session
Start-Transcript -Path $logFilePath -Append

Write-Host "Starting execution of OpenSSH installation script..."

# Define the URL of the OpenSSH script
$opensshScriptUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/install-openssh.ps1"

# Define the local folder path where the script will be saved (opensshscripts folder inside Downloads)
$downloadsFolder = "$env:USERPROFILE\Downloads\opensshscripts"

# Define the local file path where the OpenSSH script will be saved inside the opensshscripts folder
$opensshScriptPath = "$downloadsFolder\install-openssh.ps1"

# Create the opensshscripts folder inside Downloads if it doesn't exist
if (-not (Test-Path -Path $downloadsFolder)) {
    New-Item -Path $downloadsFolder -ItemType Directory
    Write-Host "Created opensshscripts folder."
}

# Download the OpenSSH installation script
Write-Host "Downloading OpenSSH Installation Script..."
Invoke-WebRequest -Uri $opensshScriptUrl -OutFile $opensshScriptPath
Write-Host "OpenSSH Installation Script downloaded to $opensshScriptPath."

# Execute the OpenSSH installation script
Write-Host "Executing OpenSSH Installation Script..."
. $opensshScriptPath

Write-Host "OpenSSH Installation script executed successfully."

# Stop the transcript to end capturing the session
Stop-Transcript
