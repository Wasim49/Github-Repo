# Define the URLs of the scripts
$installScriptUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/vault-install.ps1"
$checkScriptUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/vault-manual-check.ps1"
$storageScriptUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/vault-storage-setup.ps1"

# Define the local file paths where the scripts will be saved
$installScriptPath = "C:\vault-install.ps1"
$checkScriptPath = "C:\vault-manual-check.ps1"
$storageScriptPath = "C:\vault-storage-setup.ps1"

# Download the Vault installation script
Invoke-WebRequest -Uri $installScriptUrl -OutFile $installScriptPath

# Download the Vault manual check script
Invoke-WebRequest -Uri $checkScriptUrl -OutFile $checkScriptPath

# Download the Vault storage setup script
Invoke-WebRequest -Uri $storageScriptUrl -OutFile $storageScriptPath

# Execute the Vault installation script
Start-Process powershell -ArgumentList "-ExecutionPolicy Unrestricted -File $installScriptPath" -Wait

# Execute the Vault manual check script
Start-Process powershell -ArgumentList "-ExecutionPolicy Unrestricted -File $checkScriptPath" -Wait

# Execute the Vault storage setup script
Start-Process powershell -ArgumentList "-ExecutionPolicy Unrestricted -File $storageScriptPath" -Wait
