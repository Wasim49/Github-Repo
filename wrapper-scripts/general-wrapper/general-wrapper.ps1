# Define the path for the transcript log file
$logFilePath = "$env:USERPROFILE\Downloads\scripts\session.log"

# Start the transcript to capture everything in the PowerShell session
Start-Transcript -Path $logFilePath -Append

Write-Host "Starting execution of wrapper script..."

# Define the URLs of the scripts
$notepadurl= "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/actual-scripts/notepad/install.notepad.ps1"
$vscodeurl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/vault-manual-check.ps1"


# Define the local folder path where the scripts will be saved (vaultscripts folder inside Downloads)
$downloadsFolder = "$env:USERPROFILE\Downloads\scripts"

# Define the local file paths where the scripts will be saved inside the vaultscripts folder
$notepadpath = "$downloadsFolder\install-notepad.ps1"
$vscodepath = "$downloadsFolder\install-vscode.ps1"

# Create the vaultscripts folder inside Downloads if it doesn't exist
if (-not (Test-Path -Path $downloadsFolder)) {
    New-Item -Path $downloadsFolder -ItemType Directory
    Write-Host "Created vaultscripts folder."
}

# Download the notepad installation script
Write-Host "Downloading notepad Installation Script..."
Invoke-WebRequest -Uri $notepadurl -OutFile $notepadpath
Write-Host "Vault Installation Script downloaded to $notepadpath."

# Download the vscode installation script
Write-Host "Downloading Vault Manual Check Script..."
Invoke-WebRequest -Uri $vscodeurl -OutFile $vscodepath
Write-Host "Vault Manual Check Script downloaded to $vscodepath."


# Execute the Vault installation script
Write-Host "Executing Vault Installation Script..."
. $notepadpath

# Execute the Vault manual check script
Write-Host "Executing Vault Manual Check Script..."
. $vscodepath


Write-Host "All scripts executed successfully."

Write-Host "Notepad is installed"

Write-Host "Vscode is installed"

# Stop the transcript to end capturing the session
Stop-Transcript