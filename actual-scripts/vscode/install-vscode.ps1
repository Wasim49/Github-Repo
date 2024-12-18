## NOTES ABOUT THIS SCRIPT
## The url points to microsoft link that downlaods latest latest vscode exe version 
## This script will  only work if you change the installerPath varible exe version, download  the file via url first on cg machine and change the version in installerPath




# Define the URL for the latest VS Code installer
$installerUrl = "https://update.code.visualstudio.com/latest/win32-x64-user/stable" ## This link autoatically downlaods the latest vscode exe file
$installerPath = "$env:TEMP\VSCodeUserSetup-x64-1.96.0.exe"                          ## you have to manually change this

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