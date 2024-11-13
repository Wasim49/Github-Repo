# Define registry path for Winlogon settings
$reg_winlogon_path = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"

# Function to check if .NET Framework 4.6 or higher is installed
function Test-NetFramework46Installed {
    $netFrameworkRegPath = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"
    if (Test-Path -Path $netFrameworkRegPath) {
        $releaseKey = (Get-ItemProperty -Path $netFrameworkRegPath -Name Release -ErrorAction SilentlyContinue).Release
        if ($releaseKey -ge 393295) {
            return $true  # .NET Framework 4.6 or higher is installed
        }
    }
    return $false
}

# Install .NET Framework 4.6 if not already installed
if (-not (Test-NetFramework46Installed)) {
    Write-Host "Downloading and installing .NET Framework 4.6..."
    $dotNetInstallerUrl = "https://download.microsoft.com/download/0/7/1/0710A28D-103E-4C5F-A640-E1E0C7528ABA/NDP46-KB3045557-x86-x64-AllOS-ENU.exe"
    $installerPath = "$env:TEMP\NDP46-KB3045557-x86-x64-AllOS-ENU.exe"

    # Download the installer if it doesn't exist locally
    if (-not (Test-Path -Path $installerPath)) {
        Invoke-WebRequest -Uri $dotNetInstallerUrl -OutFile $installerPath
    }

    # Run the installer silently
    Start-Process -FilePath $installerPath -ArgumentList "/quiet", "/norestart" -Wait
    Write-Host ".NET Framework 4.6 installation completed."
} else {
    Write-Host ".NET Framework 4.6 or higher is already installed."
}

# Disable automatic logon and remove saved credentials
Set-ItemProperty -Path $reg_winlogon_path -Name AutoAdminLogon -Value 0
Remove-ItemProperty -Path $reg_winlogon_path -Name DefaultUserName -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $reg_winlogon_path -Name DefaultPassword -ErrorAction SilentlyContinue

# Get the list of network interfaces
$networkInterfaces = Get-NetConnectionProfile

# Loop through each network interface and set the desired network category
foreach ($interface in $networkInterfaces) {
    $interfaceName = $interface.InterfaceAlias
    Write-Host "Changing network category for interface: $interfaceName"

    # Set the network category to 'Private' (You can change to 'Public' if needed)
    Set-NetConnectionProfile -InterfaceAlias $interfaceName -NetworkCategory "Private"
    Write-Host "Network category for '$interfaceName' set to 'Private'."
}

# Enable PowerShell Remoting on the target machine (in case it's not already)
Enable-PSRemoting -Force

# Set Trusted Hosts to "*" (use cautiously, restrict to specific hosts for security)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force # # Allow connections from any IP (for testing purposes)

# Get current network connection profile and display it for debugging
$connectionProfile = Get-NetConnectionProfile
Write-Output "Current Network Profile: $($connectionProfile.NetworkCategory) for $($connectionProfile.InterfaceAlias)"

# Check the status of WinRM service
$winrmService = Get-Service WinRM
Write-Output "WinRM Service Status: $($winrmService.Status)"

# Start WinRM service if it's not already running
if ($winrmService.Status -ne 'Running') {
    Start-Service WinRM
    Write-Output "WinRM service started."
} else {
    Write-Output "WinRM service is already running."
}

# Verify if firewall exceptions are added (it should automatically happen if network is Private)
Enable-NetFirewallRule -DisplayGroup "Windows Remote Management"
Write-Output "WinRM firewall rule enabled."

# Output the updated network interfaces to verify
Get-NetConnectionProfile

New-NetFirewallRule -Name "Allow WinRM HTTP" -DisplayName "Allow WinRM HTTP" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 5985
New-NetFirewallRule -Name "Allow WinRM HTTPS" -DisplayName "Allow WinRM HTTPS" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 5986

winrm enumerate winrm/config/listener

# Define the URL for the OpenSSH zip file and the installation path
$zipUrl = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.8.1.0p1-Preview/OpenSSH-Win64.zip"
$downloadPath = "$env:USERPROFILE\Downloads\OpenSSH-Win64.zip"
$extractPath = "C:\Program Files\OpenSSH\OpenSSH-Win64"
$installPath = "C:\Program Files\OpenSSH"

# Create the directory for extraction if it doesn't exist
if (-Not (Test-Path -Path $extractPath)) {
    New-Item -ItemType Directory -Path $extractPath
}

# Create the installation directory if it doesn't exist
if (-Not (Test-Path -Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath
}

# Download the OpenSSH zip file
Write-Host "Downloading OpenSSH..."
Invoke-WebRequest -Uri $zipUrl -OutFile $downloadPath

# Extract the contents of the zip file
Write-Host "Extracting OpenSSH..."
Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

# Copy the extracted files to the installation directory
Write-Host "Installing OpenSSH..."
Copy-Item -Path "$extractPath\*" -Destination $installPath -Recurse -Force

# Run the install-sshd.ps1 script (if it exists), change install to uninstall-sshd.ps1 in the below line to remove openssh
$sshdScriptPath = "C:\Program Files\OpenSSH\OpenSSH-Win64\install-sshd.ps1"
if (Test-Path -Path $sshdScriptPath) {
    Write-Host "Running install-sshd.ps1 script..."
    powershell.exe -ExecutionPolicy Bypass -File "$sshdScriptPath"
} else {
    Write-Host "install-sshd.ps1 script not found. Skipping SSH server installation."
}

# Add the firewall rule to allow SSH traffic on port 22
Write-Host "Adding firewall rule for SSH..."
netsh advfirewall firewall add rule name=sshd dir=in action=allow protocol=TCP localport=22

# Check status: start sshd and verify
Write-Host "OpenSSH Installation done"
net start sshd
Get-Service -Name sshd

# Restart the system after script execution
Restart-Computer -Force -Wait
