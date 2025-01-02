# Ensure Chocolatey is installed and update if necessary
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Output "Chocolatey is already installed. Upgrading Chocolatey..."
    choco upgrade chocolatey -y
} else {
    Write-Output "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install or Upgrade Chef Workstation
Write-Output "Installing or upgrading Chef Workstation..."
choco upgrade chef-workstation -y

# Verify Chef Workstation installation path
$chefPath = "C:\opscode\chef-workstation\bin"
if (Test-Path $chefPath) {
    Write-Output "Chef Workstation is installed at: $chefPath"
} else {
    Write-Output "Chef Workstation installation path not found. Please check the installation."
    Exit 1
}

# Add Chef Workstation to PATH if not already present
$envPath = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)
if ($envPath -notlike "*$chefPath*") {
    Write-Output "Adding Chef Workstation to PATH..."
    [Environment]::SetEnvironmentVariable("PATH", "$envPath;$chefPath", [System.EnvironmentVariableTarget]::Machine)
    Write-Output "PATH updated. Restart your session to apply changes."
} else {
    Write-Output "Chef Workstation is already in the PATH."
}

# Verify the installation
try {
    $chefVersion = chef --version
    Write-Output "Chef Workstation installed successfully: $chefVersion"
} catch {
    Write-Output "Chef binary not found. Ensure PATH is updated and restart your session."
}

