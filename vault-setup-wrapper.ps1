# Define the URLs of the scripts
$installScriptUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/vault-install.ps1"
$checkScriptUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/vault-manual-check.ps1"
$storageScriptUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/vault-storage-setup.ps1"

# Define the local folder path where the scripts will be saved (vaultscripts folder inside Downloads)
$downloadsFolder = "$env:USERPROFILE\Downloads\vaultscripts"

# Define the log file path
$logFilePath = "$downloadsFolder\execution-log.txt"

# Define the local file paths where the scripts will be saved inside the vaultscripts folder
$installScriptPath = "$downloadsFolder\vault-install.ps1"
$checkScriptPath = "$downloadsFolder\vault-manual-check.ps1"
$storageScriptPath = "$downloadsFolder\vault-storage-setup.ps1"

# Create the vaultscripts folder inside Downloads if it doesn't exist
if (-not (Test-Path -Path $downloadsFolder)) {
    New-Item -Path $downloadsFolder -ItemType Directory
}

# Function to log output
function Log-Message {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp : $Message"
    Write-Output $logEntry | Out-File -FilePath $logFilePath -Append -Encoding utf8
}

# Log the start of the script execution
Log-Message "Starting execution of wrapper script."

# Download the Vault installation script
Log-Message "Downloading Vault Installation Script..."
Invoke-WebRequest -Uri $installScriptUrl -OutFile $installScriptPath
Log-Message "Vault Installation Script downloaded to $installScriptPath."

# Download the Vault manual check script
Log-Message "Downloading Vault Manual Check Script..."
Invoke-WebRequest -Uri $checkScriptUrl -OutFile $checkScriptPath
Log-Message "Vault Manual Check Script downloaded to $checkScriptPath."

# Download the Vault storage setup script
Log-Message "Downloading Vault Storage Setup Script..."
Invoke-WebRequest -Uri $storageScriptUrl -OutFile $storageScriptPath
Log-Message "Vault Storage Setup Script downloaded to $storageScriptPath."

# Execute the Vault installation script
Log-Message "Executing Vault Installation Script..."
try {
    . $installScriptPath 2>&1 | Tee-Object -FilePath $logFilePath -Append
    Log-Message "Vault Installation Script executed successfully."
} catch {
    Log-Message "Error during Vault Installation Script execution: $_"
}

# Execute the Vault manual check script
Log-Message "Executing Vault Manual Check Script..."
try {
    . $checkScriptPath 2>&1 | Tee-Object -FilePath $logFilePath -Append
    Log-Message "Vault Manual Check Script executed successfully."
} catch {
    Log-Message "Error during Vault Manual Check Script execution: $_"
}

# Execute the Vault storage setup script
Log-Message "Executing Vault Storage Setup Script..."
try {
    . $storageScriptPath 2>&1 | Tee-Object -FilePath $logFilePath -Append
    Log-Message "Vault Storage Setup Script executed successfully."
} catch {
    Log-Message "Error during Vault Storage Setup Script execution: $_"
}

# Log the completion of the script
Log-Message "All scripts executed successfully. Log file saved at $logFilePath."
Write-Host "Execution complete. See log file at $logFilePath."



