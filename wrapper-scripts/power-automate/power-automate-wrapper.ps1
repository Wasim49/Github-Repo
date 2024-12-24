$logfilepath = "c:\scripts\power-automate-install-session.log"  # Log file inside c:\scripts folder

# Start the transcript to capture everything in the PowerShell session
Start-Transcript -Path $logfilepath -Append

Write-Host "Starting execution of Power Automate wrapper script..."

# Define the URLs for the installation and flow files (these will already be downloaded in this case)
$powerAutomateInstallScriptUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/actual-scripts/power-automate/install-power-automate-desktop.ps1"
$powerAutomateFlowFilesUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/actual-scripts/power-automate/import-flow-zip-file.ps1"
$powerAutomateFlowFilesZipUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/actual-scripts/power-automate/power-automate-flow-files.zip"

# Define the local folder where scripts and flow files will be saved
$scriptsdir = "c:\scripts"

# Define the local file paths for the installation script and flow files
$powerAutomateInstallScriptPath = "$scriptsdir\install-power-automate-desktop.ps1"
$powerAutomateFlowFilesPath = "$scriptsdir\import-flow-zip-file.ps1"
$powerAutomateFlowFilesZipPath = "$scriptsdir\power-automate-flow-files.zip"

# Create the c:\scripts folder if it doesn't exist
if (-not (Test-Path -Path $scriptsdir)) {
    New-Item -Path $scriptsdir -ItemType Directory
    Write-Host "Created scripts folder at $scriptsdir."
}

# Download the Power Automate Installation script
Write-Host "Downloading Power Automate Installation Script..."
Invoke-WebRequest -Uri $powerAutomateInstallScriptUrl -OutFile $powerAutomateInstallScriptPath
Write-Host "Power Automate Installation Script downloaded to $powerAutomateInstallScriptPath."

# Download the Power Automate Flow Import script
Write-Host "Downloading Power Automate Flow Import Script..."
Invoke-WebRequest -Uri $powerAutomateFlowFilesUrl -OutFile $powerAutomateFlowFilesPath
Write-Host "Power Automate Flow Import Script downloaded to $powerAutomateFlowFilesPath."

# Download the Power Automate Flow Files Zip
Write-Host "Downloading Power Automate Flow Files Zip..."
Invoke-WebRequest -Uri $powerAutomateFlowFilesZipUrl -OutFile $powerAutomateFlowFilesZipPath
Write-Host "Power Automate Flow Files Zip downloaded to $powerAutomateFlowFilesZipPath."

# Get the current logged-in user's username
$currentUser = [System.Environment]::UserName

# Dynamically construct the PowerApps CLI path based on the current username
$powerAppsCLIPath = "C:\Users\$currentUser\AppData\Local\Microsoft\PowerAppsCLI"

# Execute the Power Automate Installation script
Write-Host "Executing Power Automate Installation Script..."
. $powerAutomateInstallScriptPath

Write-Host "Power Automate Installation script executed successfully."

# Execute the Power Automate Flow Import script in a new PowerShell session
Write-Host "Executing Power Automate Flow Import Script in new PowerShell session..."

# Add PowerAppsCLI to the PATH in the new session and run the import script
Start-Process powershell.exe -ArgumentList "-NoExit", "-Command", "`$env:Path += ';$powerAppsCLIPath'; & '$powerAutomateFlowFilesPath'"

Write-Host "Power Automate Flow Import script executed successfully in new session."

# Stop the transcript to end capturing the session
Stop-Transcript

Write-Host "Wrapper script executed successfully."






