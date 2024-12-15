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

