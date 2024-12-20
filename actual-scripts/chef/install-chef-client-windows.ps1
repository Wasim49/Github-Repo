# Define the installation paths
$scriptsdir = "C:\scripts"
$chefInstallPath = "C:\opscode\chef"
$downloadUrl = "https://packages.chef.io/files/stable/chef/17.10.0/windows/2022/chef-client-17.10.0-1-x64.msi"
$msiPath = "C:\scripts\chef-client.msi"
$extraFolder = "C:\chef"


# Create directories if they don't exist
if (-Not (Test-Path -Path $scriptsdir)) {
    New-Item -ItemType Directory -Path $scriptsdir
}

# Download Chef Client installer
Write-Host "Downloading Chef Client..."
Invoke-WebRequest -Uri $downloadUrl -OutFile $msiPath

# Install Chef Client
Write-Host "Installing Chef Client..."
if (Test-Path $msiPath) {
    Start-Process msiexec.exe -ArgumentList "/i C:\scripts\chef-client.msi ADDLOCAL=`"ChefClientFeature`" /qn" -Wait

    # Verify installation by checking if chef-client.bat exists
    if (Test-Path "$chefInstallPath\bin\chef-client.bat") {
        Write-Host "Chef Client installed successfully."

        # Check the version of Chef Client installed
        $chefClientVersion = & "$chefInstallPath\bin\chef-client.bat" --version
        Write-Host "Chef Client version: $chefClientVersion"
    } else {
        Write-Error "Chef Client installation failed. Verify MSI installer and prerequisites."
    }
} else {
    Write-Error "MSI file not found at $msiPath. Download might have failed."
}

# Remove that empty chef folder
Remove-Item -Path $extraFolder -Recurse -Force
Write-Host "Removed unnecessary 'chef' folder inside C directory"


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

Write-Host "The below is chef client version"
chef-client --version

Write-Host "The below is where chef client binary is installed"
Get-Command chef-client

Write-Host "Chef Client installation and prerequisites completed and below is chef client version"



