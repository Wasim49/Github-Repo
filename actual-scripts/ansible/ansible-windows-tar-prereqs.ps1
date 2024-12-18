# Check for administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Script needs to be run as administrator." -ForegroundColor Red
    Exit
}

# Define registry path for Winlogon settings
$reg_winlogon_path = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"

# Start transcript for detailed logging
Start-Transcript -Path "C:\scripts\execution-log.txt" -Append

# Ensure the logs directory exists
if (-not (Test-Path -Path "C:\scripts")) {
    New-Item -ItemType Directory -Path "C:\scripts"
}

# Log-Message function to write to console and log file
function Log-Message {
    param([string]$message)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logMessage = "$timestamp - $message"
    Write-Host $logMessage  # This will be captured by Start-Transcript
}

# Script start message
Log-Message "Starting script execution."

# Function to check for .NET Framework 4.6 or higher
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
    
    if (-not (Test-Path -Path $installerPath)) {
        Invoke-WebRequest -Uri $dotNetInstallerUrl -OutFile $installerPath
    }

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

# Set network category to Private for each interface
$networkInterfaces = Get-NetConnectionProfile
foreach ($interface in $networkInterfaces) {
    $interfaceName = $interface.InterfaceAlias
    Log-Message "Changing network category for interface: $interfaceName"
    Set-NetConnectionProfile -InterfaceAlias $interfaceName -NetworkCategory "Private"
    Log-Message "Network category for '$interfaceName' set to 'Private'."
}

# Enable PowerShell Remoting and set Trusted Hosts
Enable-PSRemoting -Force
Log-Message "PowerShell Remoting enabled."
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
Log-Message "Trusted Hosts set to '*' for PowerShell remoting."

# Check and configure WinRM service
$winrmService = Get-Service WinRM
Log-Message "WinRM Service Status: $($winrmService.Status)"
if ($winrmService.Status -ne 'Running') {
    Start-Service WinRM
    Log-Message "WinRM service started."
}
Set-Service -Name WinRM -StartupType Automatic
Log-Message "WinRM service startup set to Automatic."
Enable-NetFirewallRule -DisplayGroup "Windows Remote Management"
Log-Message "WinRM firewall rule enabled."

# Install OpenSSH
$zipUrl = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.8.1.0p1-Preview/OpenSSH-Win64.zip"
$downloadPath = "C:\Program Files\OpenSSH\OpenSSH-Win64.zip"  # Download path in Program Files
$extractPath = "C:\Program Files\OpenSSH"                      # Extract path directly to OpenSSH folder
$installPath = "C:\Program Files\OpenSSH"                      # Base installation path

# Create the installation directory if it doesn't exist
if (-Not (Test-Path -Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath
}

# Download the OpenSSH zip file to Program Files
Log-Message "Downloading OpenSSH to Program Files..."
Invoke-WebRequest -Uri $zipUrl -OutFile $downloadPath

# Extract the contents of the zip file to the specified folder
Log-Message "Extracting OpenSSH..."
Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

# Directly run the install-sshd.ps1 script from the extracted folder
Log-Message "Running install-sshd.ps1 script..."
powershell.exe -ExecutionPolicy Bypass -File "C:\Program Files\OpenSSH\OpenSSH-Win64\install-sshd.ps1"

# Start SSH service
Log-Message "Starting SSH service..."
net start sshd
Log-Message "OpenSSH Installation done."

# Configure OpenSSH to start automatically
Set-Service -Name sshd -StartupType Automatic
Log-Message "OpenSSH (sshd) service startup set to Automatic."

# Add the firewall rule to allow SSH traffic on port 22
Log-Message "Adding firewall rule for SSH..."
netsh advfirewall firewall add rule name=sshd dir=in action=allow protocol=TCP localport=22


# Restart the system after script execution
Log-Message "Restarting the system after script execution."
Stop-Transcript
Restart-Computer



