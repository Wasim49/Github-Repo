# Ensure Chocolatey is installed
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Output "Chocolatey is already installed. Upgrading Chocolatey..."
    choco upgrade chocolatey -y
} else {
    Write-Output "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install or Upgrade Chef Client
Write-Output "Installing or upgrading Chef Infra Client..."
choco install chef-client -y

# Verify Chef Client installation path
$chefClientPath = "C:\opscode\chef\bin"
if (Test-Path $chefClientPath) {
    Write-Output "Chef Infra Client is installed at: $chefClientPath"
} else {
    Write-Output "Chef Infra Client installation path not found. Please check the installation."
    Exit 1
}

# Add Chef Client to PATH if not already present
$envPath = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)
if ($envPath -notlike "*$chefClientPath*") {
    Write-Output "Adding Chef Infra Client to PATH..."
    [Environment]::SetEnvironmentVariable("PATH", "$envPath;$chefClientPath", [System.EnvironmentVariableTarget]::Machine)
    Write-Output "PATH updated. Restart your session to apply changes."
} else {
    Write-Output "Chef Infra Client is already in the PATH."
}

# Verify the installation
try {
    $chefVersion = chef-client --version
    Write-Output "Chef Infra Client installed successfully: $chefVersion"
} catch {
    Write-Output "Chef Client binary not found. Ensure PATH is updated and restart your session."
}


# Install prerequisites (WinRM, Firewall, etc.)
Write-Host "Configuring WinRM and Firewall..."

# Check if the network profile is set to Private; if not, change it
$networkProfile = Get-NetConnectionProfile
if ($networkProfile.NetworkCategory -ne 'Private') {
    Write-Host "Network profile is not Private, changing it..."
    Set-NetConnectionProfile -Name $networkProfile.Name -NetworkCategory Private
    Write-Host "Network profile set to Private."
} else {
    Write-Host "Network profile is already set to Private."
}

# Enable WinRM
Write-Host "Enabling WinRM..."
Enable-PSRemoting -Force

# Set execution policy to allow running scripts
Write-Host "Setting execution policy..."
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

# Configure firewall rules for Chef communication
Write-Host "Configuring firewall rules for Chef communication..."
New-NetFirewallRule -Name "ChefClient" -DisplayName "Allow Chef Client" -Enabled True -Protocol TCP -Action Allow -LocalPort 443

# Configure WinRM firewall exception
Write-Host "Configuring WinRM firewall exception..."
New-NetFirewallRule -Name "WinRM" -DisplayName "Allow WinRM" -Enabled True -Protocol TCP -Action Allow -LocalPort 5985

# Write-Host "The below is chef client version"
# chef-client --version

# Write-Host "The below is where chef client binary is installed"
# Get-Command chef-client

Write-Host "Chef Client installation and prerequisites completed and below is chef client version"



