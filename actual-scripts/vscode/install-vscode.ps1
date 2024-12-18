# Define the URL for the latest VS Code installer
$installerurl = "https://update.code.visualstudio.com/latest/win32-x64-user/stable"  # Link for latest VS Code EXE
$installersfolder = "C:\scripts\installers"          # Folder where installer will be saved
$installerpath = "$installersfolder\VSCodeUserSetup-x64-1.96.0.exe"  # Change this manually to match the version

# Download the installer
Write-Output "Downloading VS Code installer..."
Invoke-WebRequest -Uri $installerurl -OutFile $installerpath -UseBasicParsing

# Run the installer silently
Write-Output "Installing VS Code silently..."
Start-Process -FilePath $installerpath -ArgumentList "/verysilent /norestart /mergetasks=!runcode" -NoNewWindow -Wait

# Check if VS Code has been successfully installed
$vscodeExePath = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"

if (Test-Path $vscodeExePath) {
    Write-Output "VS Code installed successfully at: $vscodeExePath"
} else {
    Write-Output "VS Code installation failed."
}

# # Clean up the installer
# Remove-Item -Path $installerpath -Force
# Write-Output "VS Code installation completed."

