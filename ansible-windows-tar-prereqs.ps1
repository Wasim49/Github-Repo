# Define registry path for Winlogon settings
$reg_winlogon_path = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"

# Function to log messages to console and log file
function Log-Message {
    param([string]$message)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logMessage = "$timestamp - $message"
    Write-Host $logMessage
    Add-Content -Path "C:\scripts\execution-log.txt" -Value $logMessage
}

# Ensure the logs directory exists
if (-not (Test-Path -Path "C:\scripts")) {
    New-Item -ItemType Directory -Path "C:\scripts"
}

# Log the script start time
Log-Message "Starting script execution."

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
    Log-Message "Downloading and installing .NET Framework 4.6..."
    $dotNetInstallerUrl = "https://go.microsoft.com/fwlink/?linkid=2099469"
    $installerPath = "$env:TEMP\ndp46-targetingpack-kb3045566.exe"

    # Download the installer if it doesn't exist locally
    if (-not (Test-Path -Path $installerPath)) {
        Invoke-WebRequest -Uri $dotNetInstallerUrl -OutFile $installerPath
    }

    # Run the installer silently
    Start-Process -FilePath $installerPath -ArgumentList "/quiet", "/norestart" -Wait
    Log-Message ".NET Framework 4.6 installation completed."
} else {
    Log-Message ".NET Framework 4.6 or higher is already installed."
}

# Disable automatic logon and remove saved credentials
Set-ItemProperty -Path $reg_winlogon_path -Name AutoAdminLogon -Value 0
Remove-ItemProperty -Path $reg_winlogon_path -Name DefaultUserName -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $reg_winlogon_path -Name DefaultPassword -ErrorAction SilentlyContinue
Log-Message "Automatic logon disabled and saved credentials removed."

# Get the list of network interfaces
$networkInterfaces = Get-NetConnectionProfile

# Loop through each network interface and set the desired network category
foreach ($interface in $networkInterfaces) {
    $interfaceName = $interface.InterfaceAlias
    Log-Message "Changing network category for interface: $interfaceName"

    # Set the network category to 'Private' (You can change to 'Public' if needed)
    Set-NetConnectionProfile -InterfaceAlias $interfaceName -NetworkCategory "Private"
    Log-Message "Network category for '$interfaceName' set to 'Private'."
}

# Enable PowerShell Remoting on the target machine (in case it's not already)
Enable-PSRemoting -Force
Log-Message "PowerShell Remoting enabled."

# Set Trusted Hosts to "*" (use cautiously, restrict to specific hosts for security)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
Log-Message "Trusted Hosts set to '*' for PowerShell remoting."

# Check the status of WinRM service
$winrmService = Get-Service WinRM
Log-Message "WinRM Service Status: $($winrmService.Status)"

# Start WinRM service if it's not already running
if ($winrmService.Status -ne 'Running') {
    Start-Service WinRM
    Log-Message "WinRM service started."
} else {
    Log-Message "WinRM service is already running."
}

# Configure WinRM to start automatically
Set-Service -Name WinRM -StartupType Automatic
Log-Message "WinRM service startup set to Automatic."

# Verify if firewall exceptions are added (it should automatically happen if network is Private)
Enable-NetFirewallRule -DisplayGroup "Windows Remote Management"
Log-Message "WinRM firewall rule enabled."

# Output the updated network interfaces to verify
Get-NetConnectionProfile

New-NetFirewallRule -Name "Allow WinRM HTTP" -DisplayName "Allow WinRM HTTP" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 5985
New-NetFirewallRule -Name "Allow WinRM HTTPS" -DisplayName "Allow WinRM HTTPS" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 5986

winrm enumerate winrm/config/listener

# Install OpenSSH
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
Log-Message "Downloading OpenSSH..."
Invoke-WebRequest -Uri $zipUrl -OutFile $downloadPath

# Extract the contents of the zip file
Log-Message "Extracting OpenSSH..."
Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

# Copy the extracted files to the installation directory
Log-Message "Installing OpenSSH..."
Copy-Item -Path "$extractPath\*" -Destination $installPath -Recurse -Force

# Run the install-sshd.ps1 script (if it exists)
$sshdScriptPath = "C:\Program Files\OpenSSH\OpenSSH-Win64\install-sshd.ps1"
if (Test-Path -Path $sshdScriptPath) {
    Log-Message "Running install-sshd.ps1 script..."
    powershell.exe -ExecutionPolicy Bypass -File "$sshdScriptPath"
} else {
    Log-Message "install-sshd.ps1 script not found. Skipping SSH server installation."
}

# Configure SSH to start automatically
Set-Service -Name sshd -StartupType Automatic
Log-Message "OpenSSH (sshd) service startup set to Automatic."

# Add the firewall rule to allow SSH traffic on port 22
Log-Message "Adding firewall rule for SSH..."
netsh advfirewall firewall add rule name=sshd dir=in action=allow protocol=TCP localport=22

# Start SSH service
Log-Message "Starting SSH service..."
net start sshd
Log-Message "OpenSSH Installation done."

# Restart the system after script execution
Log-Message "Restarting the system after script execution."
Restart-Computer
