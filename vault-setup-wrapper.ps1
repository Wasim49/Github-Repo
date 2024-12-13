# Define the path for the transcript log file
$logFilePath = "$env:USERPROFILE\Downloads\vaultscripts\session.log"

# Start the transcript to capture everything in the PowerShell session
Start-Transcript -Path $logFilePath -Append

Write-Host "Starting execution of wrapper script..."

# Define the URLs of the scripts
$installScriptUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/vault-install.ps1"
$checkScriptUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/vault-manual-check.ps1"
$storageScriptUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/vault-storage-setup.ps1"

# Define the local folder path where the scripts will be saved (vaultscripts folder inside Downloads)
$downloadsFolder = "$env:USERPROFILE\Downloads\vaultscripts"

# Define the local file paths where the scripts will be saved inside the vaultscripts folder
$installScriptPath = "$downloadsFolder\vault-install.ps1"
$checkScriptPath = "$downloadsFolder\vault-manual-check.ps1"
$storageScriptPath = "$downloadsFolder\vault-storage-setup.ps1"

# Create the vaultscripts folder inside Downloads if it doesn't exist
if (-not (Test-Path -Path $downloadsFolder)) {
    New-Item -Path $downloadsFolder -ItemType Directory
    Write-Host "Created vaultscripts folder."
}

# Download the Vault installation script
Write-Host "Downloading Vault Installation Script..."
Invoke-WebRequest -Uri $installScriptUrl -OutFile $installScriptPath
Write-Host "Vault Installation Script downloaded to $installScriptPath."

# Download the Vault manual check script
Write-Host "Downloading Vault Manual Check Script..."
Invoke-WebRequest -Uri $checkScriptUrl -OutFile $checkScriptPath
Write-Host "Vault Manual Check Script downloaded to $checkScriptPath."

# Download the Vault storage setup script
Write-Host "Downloading Vault Storage Setup Script..."
Invoke-WebRequest -Uri $storageScriptUrl -OutFile $storageScriptPath
Write-Host "Vault Storage Setup Script downloaded to $storageScriptPath."

# Execute the Vault installation script
Write-Host "Executing Vault Installation Script..."
. $installScriptPath

# Execute the Vault manual check script
Write-Host "Executing Vault Manual Check Script..."
. $checkScriptPath

# Execute the Vault storage setup script
Write-Host "Executing Vault Storage Setup Script..."
. $storageScriptPath

Write-Host "All scripts executed successfully."

Write-Host "Vault is ready. You can keep this master server session open or you can start master session in another powershell session using this command, vault server -config=""C:\Program Files\Vault"""

Write-Host "Vault binary is at C:\ProgramData\chocolatey\bin\vault.exe. Secrets are persisted in C:\VaultData. Configuration file is at C:\Program Files\Vault. Downloads folder contains everything else"

# Stop the transcript to end capturing the session
Stop-Transcript



