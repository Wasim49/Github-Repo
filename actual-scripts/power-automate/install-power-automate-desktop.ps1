# Step 1: Check if Power Automate Desktop is installed
$padPath = "C:\Program Files (x86)\Power Automate Desktop\PAD.ConsoleHost.exe"
$padInstalled = Test-Path $padPath

if ($padInstalled) {
    Write-Host "Power Automate Desktop is already installed."
} else {
    Write-Host "Power Automate Desktop is not installed. Installing..."

    # Define the path where the Power Automate installer is located
    $installerPath = "C:\scripts\Setup.Microsoft.PowerAutomate.exe"

    # Check if the installer already exists in the scripts folder
    if (-not (Test-Path $installerPath)) {
        Write-Host "Power Automate Desktop installer not found in C:\scripts. Downloading..."

        # Download Power Automate Desktop installer from the official URL
        $installerUrl = "https://go.microsoft.com/fwlink/?linkid=2102613"  # Official link for PAD installer

        # Download the installer
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
        Write-Host "Power Automate Desktop installer downloaded successfully."
    } else {
        Write-Host "Power Automate Desktop installer already exists in C:\scripts."
    }

    # Run the installer silently with acceptance of terms (using -accepteula)
    Write-Host "Running Power Automate Desktop installer..."
    Start-Process -FilePath $installerPath -ArgumentList "/quiet", "/norestart", "-accepteula" -Wait

    # Confirm installation
    if (Test-Path $padPath) {
        Write-Host "Power Automate Desktop installed successfully."
    } else {
        Write-Host "Power Automate Desktop installation failed."
    }
}

