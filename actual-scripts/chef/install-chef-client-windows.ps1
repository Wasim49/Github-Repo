# install-chef.ps1

# Define installation paths
$scriptsdir = "c:\scripts"
$chefInstallPath = "C:\chef"
$downloadUrl = "https://packages.chef.io/files/stable/chef/17.10.0/windows/2022/chef-client-17.10.0-1-x64.msi"
$msiPath = "$scriptsdir\chef-client.msi"

# Create directories if they don't exist
if (-Not (Test-Path -Path $scriptsdir)) {
    New-Item -ItemType Directory -Path $scriptsdir
}

# Download Chef Client installer
Write-Host "Downloading Chef Client..."
Invoke-WebRequest -Uri $downloadUrl -OutFile $msiPath

# Install Chef Client
Write-Host "Installing Chef Client..."
Start-Process msiexec.exe -ArgumentList "/i $msiPath /quiet /norestart" -Wait

# Verify installation
if (Test-Path "$chefInstallPath\bin\chef-client.exe") {
    Write-Host "Chef Client installed successfully."
} else {
    Write-Error "Chef Client installation failed."
    exit 1
}

# Install Prerequisites (WinRM, Firewall, etc.)
Write-Host "Configuring WinRM and Firewall..."
# Enable WinRM
Enable-PSRemoting -Force

# Set execution policy to allow running scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

# Configure firewall rules for Chef communication
New-NetFirewallRule -Name "ChefClient" -DisplayName "Allow Chef Client" -Enabled True -Protocol TCP -Action Allow -LocalPort 443

Write-Host "Chef Client installation and prerequisites completed."

# Optional: Chef Client could be started here if needed
# Start-Service chef-client
