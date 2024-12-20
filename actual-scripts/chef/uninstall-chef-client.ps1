# Define the installation paths and MSI product details
$chefInstallPath = "C:\chef"
$opscodeInstallPath = "C:\opscode"
$msiPath = "C:\scripts\chef-client.msi"
$scriptpath = "C:\scripts"

# Uninstall Chef Client MSI product (using product code)
Write-Host "Uninstalling Chef Client..."

# Check if Chef MSI is installed via Windows Installer
$chefProductCode = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name = 'Chef Client'" 
if ($chefProductCode) {
    Write-Host "Uninstalling Chef Client MSI..."
    $chefProductCode.Uninstall()  # Uninstall the Chef MSI package
} else {
    Write-Host "Chef Client MSI product not found."
}

# Check if Chef binaries are present and remove them
if (Test-Path "$chefInstallPath\bin\chef-client.exe") {
    Write-Host "Removing Chef binaries from $chefInstallPath..."
    Remove-Item -Recurse -Force $chefInstallPath
}

if (Test-Path "$opscodeInstallPath") {
    Write-Host "Removing Opscode directory $opscodeInstallPath..."
    Remove-Item -Recurse -Force $opscodeInstallPath
}

# Remove Chef directories if they exist
if (Test-Path $chefInstallPath) {
    Write-Host "Removing directory: $chefInstallPath"
    Remove-Item -Recurse -Force $chefInstallPath
} else {
    Write-Host "$chefInstallPath not found."
}

if (Test-Path $opscodeInstallPath) {
    Write-Host "Removing directory: $opscodeInstallPath"
    Remove-Item -Recurse -Force $opscodeInstallPath
} else {
    Write-Host "$opscodeInstallPath not found."
}

# Cleaning up the registry keys related to Chef Client
$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Chef Client",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Chef Client"
)

foreach ($path in $registryPaths) {
    if (Test-Path $path) {
        Write-Host "Removing registry key $path"
        Remove-Item -Recurse -Force $path
    } else {
        Write-Host "Registry key $path not found."
    }
}

# Check if Chef Client MSI file exists in scripts folder and remove it
if (Test-Path $msiPath) {
    Write-Host "Removing Chef Client MSI file..."
    Remove-Item -Force $msiPath
} else {
    Write-Host "Chef Client MSI file not found at $msiPath."
}

# Remove the entire 'scripts' folder if it exists
if (Test-Path $scriptpath) {
    Write-Host "Removing directory: $scriptpath"
    Remove-Item -Recurse -Force $scriptpath
} else {
    Write-Host "$scriptpath not found."
}

Write-Host "Chef Client uninstallation completed."






