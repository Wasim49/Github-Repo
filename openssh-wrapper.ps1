# Set the execution policy for the current PowerShell session to bypass any restrictions
Set-ExecutionPolicy Bypass -Scope Process -Force

# Define the Downloads folder path where the scripts and log will be stored
$downloadsFolder = "$env:USERPROFILE\Downloads\opensshscripts"  # Downloads folder path
$logFilePath = "$downloadsFolder\session.log"  # Log file in the Downloads folder

# Start the transcript to capture everything in the PowerShell session
Start-Transcript -Path $logFilePath -Append

Write-Host "Starting execution of OpenSSH installation script..."

# Define the URL of the OpenSSH script
$opensshScriptUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/install-openssh.ps1"

# Define the local file path where the OpenSSH script will be saved inside the Downloads folder
$opensshScriptPath = "$downloadsFolder\install-openssh.ps1"

# Create the temp folder inside Downloads if it doesn't exist
if (-not (Test-Path -Path $downloadsFolder)) {
    New-Item -Path $downloadsFolder -ItemType Directory
    Write-Host "Created temp folder at $downloadsFolder."
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



