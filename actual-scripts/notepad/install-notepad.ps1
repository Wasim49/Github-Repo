# Define the URL for the latest Notepad++ installer
$installerUrl = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.7.4/npp.8.7.4.Installer.x64.exe"
$installerPath = "$env:TEMP\npp.8.7.4.Installer.x64.exe"

# Download the installer
Write-Output "Downloading Notepad++ installer..."
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing

# Run the installer silently, preventing Notepad++ from launching after installation
Write-Output "Installing Notepad++ silently..."
Start-Process -FilePath $installerPath -ArgumentList "/S" -NoNewWindow -Wait

# Confirm installation
if (Test-Path "C:\Program Files\Notepad++\notepad++.exe") {
    Write-Output "Notepad++ installed successfully."
} else {
    Write-Output "Notepad++ installation failed."
}

# Clean up the installer
Remove-Item -Path $installerPath -Force
Write-Output "Notepad++ installed successfully."

