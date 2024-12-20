# Define the installation paths and MSI product details
$scriptpath = "C:\scripts"
# Define the product name (Chef Infra Client)
$productName = "Chef Infra Client"

# Search for the Chef Client in the list of installed programs
$chefPrograms = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*$productName*" }

if ($chefPrograms) {
    Write-Host "$($chefPrograms.Count) Chef Infra Client instance(s) found. Uninstalling..."

    # Uninstall all matching programs
    foreach ($program in $chefPrograms) {
        Write-Host "Uninstalling $($program.Name)..."
        $program.Uninstall()
    }

    Write-Host "Chef Infra Client uninstallation initiated successfully."
} else {
    Write-Host "Chef Infra Client is not installed or not found in Programs and Features."
}

# Remove the entire 'scripts' folder if it exists
if (Test-Path $scriptpath) {
    Write-Host "Removing directory: $scriptpath"
    Remove-Item -Recurse -Force $scriptpath
} else {
    Write-Host "$scriptpath not found."
}

Write-Host "Chef Client uninstallation completed."






