# Define the path for the Vault configuration file
$vaultConfigPath = "C:\Program Files\Vault\vault-config.hcl"

# Ensure the directory exists
if (-Not (Test-Path -Path (Split-Path -Path $vaultConfigPath))) {
    Write-Host "Creating directory for Vault configuration file..."
    New-Item -ItemType Directory -Path (Split-Path -Path $vaultConfigPath) -Force
}

# Content of the Vault configuration file
$configContent = @"
storage "file" {
  path = "C:\\VaultData"
}

listener "tcp" {
  address = "127.0.0.1:8200"
  tls_disable = 1
}

ui = true
"@

# Write the configuration to the file
Write-Host "Writing Vault configuration to $vaultConfigPath..."
Set-Content -Path $vaultConfigPath -Value $configContent

# Ensure the Vault data directory exists
$vaultDataPath = "C:\VaultData"
if (-Not (Test-Path -Path $vaultDataPath)) {
    Write-Host "Creating Vault data directory..."
    New-Item -ItemType Directory -Path $vaultDataPath -Force
}

# Start Vault in server mode using the Chocolatey-installed binary
$vaultBinaryPath = "C:\ProgramData\chocolatey\bin\vault.exe"
if (-Not (Test-Path -Path $vaultBinaryPath)) {
    Write-Host "Error: Vault executable not found at $vaultBinaryPath. Ensure Vault is installed via Chocolatey."
    Exit 1
}

Write-Host "Starting Vault server..."
Start-Process -FilePath $vaultBinaryPath -ArgumentList "server", "-config=$vaultConfigPath" -NoNewWindow

Write-Host "Vault storage setup complete."

