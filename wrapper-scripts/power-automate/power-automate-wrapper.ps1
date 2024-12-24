$logfilepath = "c:\scripts\power-automate-install-session.log"  # Log file inside c:\scripts folder

# Start the transcript to capture everything in the PowerShell session
Start-Transcript -Path $logfilepath -Append

Write-Host "Starting execution of Power Automate wrapper script..."

# Define the URLs for the installation and flow files
$powerAutomateInstallScriptUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/actual-scripts/power-automate/install-power-automate-desktop.ps1"
$powerAutomateFlowFilesUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/actual-scripts/power-automate/import-flow-zip-file.ps1"

# Define the local folder where scripts and flow files will be saved
$scriptsdir = "c:\scripts"

# Define the local file paths for the installation script and flow files
$powerAutomateInstallScriptPath = "$scriptsdir\install-power-automate-desktop.ps1"
$powerAutomateFlowFilesPath = "$scriptsdir\power-automate-flow-files.zip"

# Create the c:\scripts folder if it doesn't exist
if (-not (Test-Path -Path $scriptsdir)) {
    New-Item -Path $scriptsdir -ItemType Directory
    Write-Host "Created scripts folder at $scriptsdir."
}

# Download the Power Automate installation script
Write-Host "Downloading Power Automate Installation Script..."
Invoke-WebRequest -Uri $powerAutomateInstallScriptUrl -OutFile $powerAutomateInstallScriptPath
Write-Host "Power Automate Installation Script downloaded to $powerAutomateInstallScriptPath."

# Download the Power Automate flow files
Write-Host "Downloading Power Automate Flow Files..."
Invoke-WebRequest -Uri $powerAutomateFlowFilesUrl -OutFile $powerAutomateFlowFilesPath
Write-Host "Power Automate Flow Files downloaded to $powerAutomateFlowFilesPath."

# Execute the Power Automate installation script
Write-Host "Executing Power Automate Installation Script..."
. $powerAutomateInstallScriptPath

Write-Host "Power Automate Installation script executed successfully."

# Execute the flow import script
Write-Host "Executing Power Automate Flow Import Script..."
. $powerAutomateFlowFilesUrl  # Executes the script to import the flow

Write-Host "Power Automate Flow Import script executed successfully."

# Stop the transcript to end capturing the session
Stop-Transcript

# End of the script






