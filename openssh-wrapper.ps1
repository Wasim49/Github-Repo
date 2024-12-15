
$logFilePath = "$env:USERPROFILE\Downloads\sshscripts\session.log"  # Log file in the Downloads folder

# Start the transcript to capture everything in the PowerShell session
Start-Transcript -Path $logFilePath -Append

Write-Host "Starting execution of OpenSSH wrapper script..."

# Define the URL of the OpenSSH script
$opensshScriptUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/install-openssh.ps1"

# Define the local folder path where the scripts will be saved (vaultscripts folder inside Downloads)
$downloadsFolder = "$env:USERPROFILE\Downloads\sshscripts"

# Define the local file path where the OpenSSH script will be saved inside the Downloads folder
$installScriptPath = "$downloadsFolder\vault-install.ps1"

# Create the sshscripts folder inside Downloads if it doesn't exist
if (-not (Test-Path -Path $downloadsFolder)) {
    New-Item -Path $downloadsFolder -ItemType Directory
    Write-Host "Created sshscripts folder at $downloadsFolder."
}

# Download the OpenSSH installation script
Write-Host "Downloading OpenSSH Installation Script..."
Invoke-WebRequest -Uri $opensshScriptUrl -OutFile $installScriptPath
Write-Host "OpenSSH Installation Script downloaded to $installScriptPath."

# Execute the OpenSSH installation script
Write-Host "Executing OpenSSH Installation Script..."
. $installScriptPath

Write-Host "OpenSSH Installation script executed successfully."

# Stop the transcript to end capturing the session
Stop-Transcript
