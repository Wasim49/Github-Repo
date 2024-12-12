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
}

# Download the Vault installation script
Invoke-WebRequest -Uri $installScriptUrl -OutFile $installScriptPath

# Download the Vault manual check script
Invoke-WebRequest -Uri $checkScriptUrl -OutFile $checkScriptPath

# Download the Vault storage setup script
Invoke-WebRequest -Uri $storageScriptUrl -OutFile $storageScriptPath

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


