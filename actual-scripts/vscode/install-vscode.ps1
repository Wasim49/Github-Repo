# Define the URL for the latest VS Code installer
$installerUrl = "https://update.code.visualstudio.com/latest/win32-x64-user/stable"
$installersFolder = "C:\scripts\installers"          # Folder where installer will be saved
$installerPath = "$installersFolder\VSCodeUserSetup-x64-1.96.0.exe"  # Change this manually to match the version

# Define the desired installation directory (where you want VS Code to be installed)
$installDir = "C:\Program Files\Microsoft VS Code"  # Adjust the path as needed

# Download the installer
Write-Output "Downloading VS Code installer..."
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing

# Run the installer silently, specifying the installation directory
Write-Output "Installing VS Code silently..."
Start-Process -FilePath $installerPath -ArgumentList "/verysilent /norestart /mergetasks=!runcode /D=$installDir" -NoNewWindow -Wait

# Check if VS Code has been successfully installed
$vscodeExePath = "$installDir\Code.exe"

if (Test-Path $vscodeExePath) {
    Write-Output "VS Code installed successfully at: $vscodeExePath"
} else {
    Write-Output "VS Code installation failed."
}

# Clean up the installer
# Remove-Item -Path $installerPath -Force
# Write-Output "VS Code installation completed."

