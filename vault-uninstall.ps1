# Run the script as Administrator

# Define the paths
$binPath = "C:\ProgramData\chocolatey\bin\vault.exe"
$libPath = "C:\ProgramData\chocolatey\lib\vault"
$libBkpPath = "C:\ProgramData\chocolatey\lib-bkp\vault"

# Function to remove file or folder if it exists
function Remove-ItemIfExists {
    param (
        [string]$path
    )

    if (Test-Path $path) {
        Write-Host "Removing: $path"
        Remove-Item -Path $path -Recurse -Force
    } else {
        Write-Host "Not found: $path"
    }
}

# Stop any vault processes that might be running
$vaultProcesses = Get-Process -Name "vault" -ErrorAction SilentlyContinue
if ($vaultProcesses) {
    Write-Host "Stopping Vault processes..."
    Stop-Process -Name "vault" -Force
} else {
    Write-Host "No Vault processes running."
}

# Remove Vault executable from bin directory
Remove-ItemIfExists -path $binPath

# Remove Vault directory from lib
Remove-ItemIfExists -path $libPath

# Remove Vault directory from lib-bkp
Remove-ItemIfExists -path $libBkpPath

# Optionally, you can clean up the Chocolatey cache folder if needed
$cachePath = "C:\ProgramData\chocolatey\cache\vault"
Remove-ItemIfExists -path $cachePath

Write-Host "Vault uninstallation complete."