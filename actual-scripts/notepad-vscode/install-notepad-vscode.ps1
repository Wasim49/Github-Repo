# Notepad ++

# Define the path to the software installer
$NotepadsoftwarePath = "C:\temp\npp.8.6.7.Installer.x64.exe"  # Replace with the actual path
# Define the default installation path of the software
$NotepaddefaultPath = "C:\Program Files\Notepad++\notepad++.exe"  # Replace with the actual default installation path

# Function to check if the software is installed based on the default installation path
function Is-SoftwareInstalled {
    param (
        [string]$path
    )
    if (Test-Path $path) {
        return $true
    }
    else {
        return $false
    }
}

# Function to install the software silently
function Install-Software {
    param (
        [string]$installerPath
    )
    # Execute the installer with silent arguments (adjust arguments as necessary)
    Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait
}

# Check if the software is already installed
if (Is-SoftwareInstalled -path $NotepaddefaultPath) {
    Write-Host "Notepad ++ is already installed at $NotepaddefaultPath."
}
else {
    Write-Host "Notepad ++ is not installed at $NotepaddefaultPath. Installing now..."
    Install-Software -installerPath $NotepadsoftwarePath
    Write-Host "Notepad ++  installation completed."
}



#----------------------------------------------------------------------------------------------------------#

# VsCode
# Define the path to the software installer
$VscodesoftwarePath = "C:\temp\VSCodeUserSetup-x64-1.91.1.exe"  # Replace with the actual path
# Define the default installation path of the software
$VscodedefaultPath = "C:\Users\wasadmin\AppData\Local\Programs\Microsoft VS Code\code.exe"  # Replace with the actual default installation path

# Function to check if the software is installed based on the default installation path
function Is-SoftwareInstalled {
    param (
        [string]$path
    )
    if (Test-Path $path) {
        return $true
    }
    else {
        return $false
    }
}

# Function to install the software silently
function Install-Software {
    param (
        [string]$installerPath
    )
    # Execute the installer with silent arguments (adjust arguments as necessary)
    Start-Process -FilePath $installerPath -ArgumentList "/silent", "/verysilent", "/norestart", "/MERGETASKS=!runcode" -Wait
}

# Check if the software is already installed
if (Is-SoftwareInstalled -path $VscodedefaultPath) {
    Write-Host "VScode is already installed at $VscodedefaultPath."
}
else {
    Write-Host "VScode is not installed at $VscodedefaultPath. Installing now..."
    Install-Software -installerPath $VscodesoftwarePath
    Write-Host "VScode installation completed."
}










