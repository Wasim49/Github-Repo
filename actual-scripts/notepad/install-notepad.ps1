# Define the URL for the latest Notepad++ installer
$installerUrl = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/latest/download/npp.8.5.9.Installer.x64.exe"
$installerPath = "$env:TEMP\nppInstaller-x64.exe"

# Download the installer
Write-Output "Downloading Notepad++ installer..."
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing

# Run the installer silently, preventing Notepad++ from launching after installation
Write-Output "Installing Notepad++ silently..."
Start-Process -FilePath $installerPath -ArgumentList "/S" -NoNewWindow -Wait

# Clean up the installer
Remove-Item -Path $installerPath -Force
Write-Output "Notepad++ installed successfully."

# Confirm installation
if (Test-Path "C:\Program Files\Notepad++\notepad++.exe") {
    Write-Output "Notepad++ installed successfully."
} else {
    Write-Output "Notepad++ installation failed."
}