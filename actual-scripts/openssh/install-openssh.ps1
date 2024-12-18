# Define the URL for the OpenSSH zip file and the installation path
$zipurl = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.8.1.0p1-Preview/OpenSSH-Win64.zip"
$scriptsdir = "c:\scripts"
$downloadpath = "$scriptsdir\OpenSSH-Win64.zip"
$extractpath = "$scriptsdir\OpenSSH-Win64"
$installpath = "c:\program files\OpenSSH"

# Create the directory for extraction if it doesn't exist
if (-Not (Test-Path -Path $extractpath)) {
    New-Item -ItemType Directory -Path $extractpath
}

# Create the installation directory if it doesn't exist
if (-Not (Test-Path -Path $installpath)) {
    New-Item -ItemType Directory -Path $installpath
}

# Download the OpenSSH zip file
Write-Host "Downloading OpenSSH..."
Invoke-WebRequest -Uri $zipurl -OutFile $downloadpath

# Extract the contents of the zip file
Write-Host "Extracting OpenSSH..."
Expand-Archive -Path $downloadpath -DestinationPath $extractpath -Force

# Copy the extracted files to the installation directory
Write-Host "Installing OpenSSH..."
Copy-Item -Path "$extractpath\*" -Destination $installpath -Recurse -Force

# Run the install-sshd.ps1 script (if it exists), change install to uninstall-sshd.ps1 in the below line to remove openssh
$sshdscriptpath = "$installpath\OpenSSH-Win64\install-sshd.ps1"
if (Test-Path -Path $sshdscriptpath) {
    Write-Host "Running install-sshd.ps1 script..."
    powershell.exe -ExecutionPolicy Bypass -File "$sshdscriptpath"
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


