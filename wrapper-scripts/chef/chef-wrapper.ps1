$logfilepath = "c:\scripts\chef-install-session.log"  # Log file inside c:\scripts folder

# Start the transcript to capture everything in the PowerShell session
Start-Transcript -Path $logfilepath -Append

Write-Host "Starting execution of Chef and OpenSSH wrapper script..."

# Define the URLs for the installation and uninstallation scripts
$chefInstallScriptUrl = "https://raw.githubusercontent.com/YourGithubRepo/chef-scripts/main/install-chef-client-windows.ps1"
$opensshInstallScriptUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/refs/heads/main/actual-scripts/openssh/install-openssh.ps1"
$chefUninstallScriptUrl = "https://raw.githubusercontent.com/YourGithubRepo/chef-scripts/main/uninstall-chef-client.ps1"  # Add URL for uninstall script

# Define the local folder where scripts will be saved
$scriptsdir = "c:\scripts"

# Define the local file paths for the installation scripts
$chefInstallScriptPath = "$scriptsdir\install-chef-client-windows.ps1"
$opensshInstallScriptPath = "$scriptsdir\install-openssh.ps1"
$chefUninstallScriptPath = "$scriptsdir\uninstall-chef-client.ps1"  # Local path for uninstall script

# Create the c:\scripts folder if it doesn't exist
if (-not (Test-Path -Path $scriptsdir)) {
    New-Item -Path $scriptsdir -ItemType Directory
    Write-Host "Created scripts folder at $scriptsdir."
}

# Download the Chef installation script
Write-Host "Downloading Chef Installation Script..."
Invoke-WebRequest -Uri $chefInstallScriptUrl -OutFile $chefInstallScriptPath
Write-Host "Chef Installation Script downloaded to $chefInstallScriptPath."

# Download the OpenSSH installation script
Write-Host "Downloading OpenSSH Installation Script..."
Invoke-WebRequest -Uri $opensshInstallScriptUrl -OutFile $opensshInstallScriptPath
Write-Host "OpenSSH Installation Script downloaded to $opensshInstallScriptPath."

# Download the Chef Uninstallation script (but do not execute it)
Write-Host "Downloading Chef Uninstallation Script..."
Invoke-WebRequest -Uri $chefUninstallScriptUrl -OutFile $chefUninstallScriptPath
Write-Host "Chef Uninstallation Script downloaded to $chefUninstallScriptPath."

# Execute the Chef installation script
Write-Host "Executing Chef Installation Script..."
. $chefInstallScriptPath

# Execute the OpenSSH installation script
Write-Host "Executing OpenSSH Installation Script..."
. $opensshInstallScriptPath

Write-Host "Chef and OpenSSH Installation scripts executed successfully."

# Stop the transcript to end capturing the session
Stop-Transcript

# End of the script


