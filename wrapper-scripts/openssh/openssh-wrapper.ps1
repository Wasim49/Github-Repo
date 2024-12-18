$logfilepath = "c:\scripts\session.log"  # Log file inside c:\scripts folder

# Start the transcript to capture everything in the PowerShell session
Start-Transcript -Path $logfilepath -Append

Write-Host "Starting execution of OpenSSH wrapper script..."

# Define the URL of the OpenSSH script
$openshscripturl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/actual-scripts/openssh/install-openssh.ps1"

# Define the local folder path where the script will be saved (c:\scripts)
$scriptsdir = "c:\scripts"

# Define the local file path where the OpenSSH script will be saved inside c:\scripts
$installscriptpath = "$scriptsdir\install-openssh.ps1"

# Create the c:\scripts folder if it doesn't exist
if (-not (Test-Path -Path $scriptsdir)) {
    New-Item -Path $scriptsdir -ItemType Directory
    Write-Host "Created scripts folder at $scriptsdir."
}

# Download the OpenSSH installation script
Write-Host "Downloading OpenSSH Installation Script..."
Invoke-WebRequest -Uri $openshscripturl -OutFile $installscriptpath
Write-Host "OpenSSH Installation Script downloaded to $installscriptpath."

# Execute the OpenSSH installation script
Write-Host "Executing OpenSSH Installation Script..."
. $installscriptpath

Write-Host "OpenSSH Installation script executed successfully."

# Stop the transcript to end capturing the session
Stop-Transcript





