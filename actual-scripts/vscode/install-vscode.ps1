# Define the URL for the latest VS Code installer
$installerUrl = "https://code.visualstudio.com/docs/?dv=win64user"
$installerPath = "$env:TEMP\VSCodeUserSetup-x64-1.96.0"

# Download the installer
Write-Output "Downloading VS Code installer..."
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing

# Run the installer silently, preventing VS Code from launching after installation
Write-Output "Installing VS Code silently..."
Start-Process -FilePath $installerPath -ArgumentList "/verysilent /norestart /mergetasks=!runcode" -NoNewWindow -Wait

# Clean up the installer
Remove-Item -Path $installerPath -Force
Write-Output "VS Code installed successfully."

# Confirm installation
if (Test-Path "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe") {
    Write-Output "VS Code installed successfully."
} else {
    Write-Output "VS Code installation failed."
}