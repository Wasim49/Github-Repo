# Define the path for the transcript log file
$logfilepath = "C:\scripts\session.log"

# Start the transcript to capture everything in the PowerShell session
Start-Transcript -Path $logfilepath -Append

Write-Host "Starting execution of wrapper script..."

# Define the URLs of the scripts
$notepadurl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/actual-scripts/notepad/install-notepad.ps1"
$vscodeurl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/actual-scripts/vscode/install-vscode.ps1"

# Define the local folder path where the scripts will be saved (C:\scripts)
$scriptsfolder = "C:\scripts"

# Define the local folder path for installers (C:\scripts\installers)
$installersfolder = "C:\scripts\installers"

# Define the local file paths where the scripts will be saved
$notepadpath = "$scriptsfolder\install-notepad.ps1"
$vscodepath = "$scriptsfolder\install-vscode.ps1"

# Create the scripts folder if it doesn't exist
if (-not (Test-Path -Path $scriptsfolder)) {
    New-Item -Path $scriptsfolder -ItemType Directory
    Write-Host "Created scripts folder."
}

# Create the installers folder if it doesn't exist
if (-not (Test-Path -Path $installersfolder)) {
    New-Item -Path $installersfolder -ItemType Directory
    Write-Host "Created installers folder."
}

# Download the Notepad++ installation script
Write-Host "Downloading Notepad++ installation script..."
Invoke-WebRequest -Uri $notepadurl -OutFile $notepadpath
Write-Host "Notepad++ installation script downloaded to $notepadpath."

# Download the VS Code installation script
Write-Host "Downloading VS Code installation script..."
Invoke-WebRequest -Uri $vscodeurl -OutFile $vscodepath
Write-Host "VS Code installation script downloaded to $vscodepath."

# Execute the Notepad++ installation script
Write-Host "Executing Notepad++ installation script..."
. $notepadpath

# Execute the VS Code installation script
Write-Host "Executing VS Code installation script..."
. $vscodepath

Write-Host "All scripts executed successfully."

# Stop the transcript to end capturing the session
Stop-Transcript

