# Define the URL for the latest Notepad++ installer
$installerurl = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.7.4/npp.8.7.4.Installer.x64.exe"
$installersfolder = "C:\scripts\installers"           # Folder where installer will be saved
$installerpath = "$installersfolder\npp.8.7.4.Installer.x64.exe"

# Download the installer
Write-Output "Downloading Notepad++ installer..."
Invoke-WebRequest -Uri $installerurl -OutFile $installerpath -UseBasicParsing

# Run the installer silently
Write-Output "Installing Notepad++ silently..."
Start-Process -FilePath $installerpath -ArgumentList "/S" -NoNewWindow -Wait

# Check if Notepad++ has been successfully installed
$notepadExePath = "C:\Program Files\Notepad++\notepad++.exe"

if (Test-Path $notepadExePath) {
    Write-Output "Notepad++ installed successfully at: $notepadExePath"
} else {
    Write-Output "Notepad++ installation failed."
}


# # Clean up the installer
# Remove-Item -Path $installerpath -Force
# Write-Output "Notepad++ installation completed."



