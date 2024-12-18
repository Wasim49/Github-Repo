# Define the path for the transcript log file
$logFilePath = "c:\scripts\session.log"

# Start the transcript to capture everything in the PowerShell session
Start-Transcript -Path $logFilePath -Append

Write-Host "Starting execution of wrapper script..."

# Define the URLs of the scripts
$installScriptUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/actual-scripts/hashicorp-vault/vault-install.ps1"
$checkScriptUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/actual-scripts/hashicorp-vault/vault-manual-check.ps1"
$storageScriptUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/actual-scripts/hashicorp-vault/vault-storage-setup.ps1"
$vaulunsealscripturi = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/actual-scripts/hashicorp-vault/vault-unseal.ps1"

# Define the local folder path where the scripts will be saved
$scriptsFolder = "c:\scripts"

# Define the local file paths where the scripts will be saved
$installScriptPath = "$scriptsFolder\vault-install.ps1"
$checkScriptPath = "$scriptsFolder\vault-manual-check.ps1"
$storageScriptPath = "$scriptsFolder\vault-storage-setup.ps1"
$vaultunsealpath = "$scriptsFolder\vault-unseal.ps1"

# Create the scripts folder if it doesn't exist
if (-not (Test-Path -Path $scriptsFolder)) {
    New-Item -Path $scriptsFolder -ItemType Directory
    Write-Host "Created scripts folder."
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

# Download the Vault unseal script
Write-Host "Downloading Vault unseal Script..."
Invoke-WebRequest -Uri $vaulunsealscripturi -OutFile $vaultunsealpath
Write-Host "Vault unseal Script downloaded to $storageScriptPath."


# Execute the Vault installation script
Write-Host "Executing Vault Installation Script..."
. $installScriptPath

# Execute the Vault manual check script
Write-Host "Executing Vault Manual Check Script..."
. $checkScriptPath

# Execute the Vault storage setup script
Write-Host "Executing Vault Storage Setup Script..."
. $storageScriptPath

Write-Host "All scripts executed successfully. Check $logFilePath for logs."

# Stop the transcript
Stop-Transcript




