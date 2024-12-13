# Vault Storage Setup Script

# Variables
$vaultBinaryPath = "C:\ProgramData\chocolatey\bin\vault.exe"
$vaultConfigPath = "C:\Program Files\Vault\vault-config.hcl"
$vaultDataDir = "C:\VaultData"
$serviceName = "Vault"
$serviceArgs = "-config=$vaultConfigPath"

# Create Vault Data Directory
Write-Host "Creating Vault data directory..."
if (-Not (Test-Path -Path $vaultDataDir)) {
    New-Item -ItemType Directory -Path $vaultDataDir
}

# Write Vault Configuration (example)
Write-Host "Writing Vault configuration to $vaultConfigPath..."
$vaultConfig = @"
storage "file" {
  path = "$vaultDataDir"
}
listener "tcp" {
  address = "127.0.0.1:8200"
  tls_disable = 1
}
disable_mlock = true
ui = true
"@
$vaultConfig | Out-File -FilePath $vaultConfigPath -Force

# Checking if Vault is already running
Write-Host "Checking if Vault is already running on port 8200..."
$vaultProcess = Get-Process -Name vault -ErrorAction SilentlyContinue
if ($vaultProcess) {
    Write-Host "Vault is already running. Stopping the existing Vault process..."
    Stop-Process -Name vault -Force
}

# Start Vault Server
Write-Host "Starting Vault server on port 8200..."
Start-Process -FilePath $vaultBinaryPath -ArgumentList $serviceArgs -NoNewWindow -PassThru

# Wait for Vault to initialize
Write-Host "Waiting for Vault to initialize..."
Start-Sleep -Seconds 5

# Initialize Vault
Write-Host "Initializing Vault..."
$initCommand = "$vaultBinaryPath operator init -key-shares=5 -key-threshold=3"
$initResult = Invoke-Expression $initCommand

# Capture unseal keys and root token (for later use)
Write-Host "Vault initialized successfully. Saving unseal keys and root token..."
$initResult | Out-File -FilePath "C:\Users\vmadmin\Downloads\vault_config.json" -Force

# Unseal Vault
Write-Host "Unsealing Vault..."
$unsealKeys = ($initResult | Select-String -Pattern "Unseal Key" | ForEach-Object { $_.Line.Split(":")[1].Trim() })
$unsealCommand = "$vaultBinaryPath operator unseal $($unsealKeys[0])"
Invoke-Expression $unsealCommand
Start-Sleep -Seconds 5

$unsealCommand = "$vaultBinaryPath operator unseal $($unsealKeys[1])"
Invoke-Expression $unsealCommand
Start-Sleep -Seconds 5

$unsealCommand = "$vaultBinaryPath operator unseal $($unsealKeys[2])"
Invoke-Expression $unsealCommand
Start-Sleep -Seconds 5

# Enable KV secrets engine
Write-Host "Enabling KV secrets engine..."
$kvEnableCommand = "$vaultBinaryPath secrets enable -path=secret/ kv"
Invoke-Expression $kvEnableCommand

# Set Vault environment variables (VAULT_ADDR, VAULT_TOKEN, UNSEAL_KEYS)
Write-Host "Setting Vault environment variables..."
[System.Environment]::SetEnvironmentVariable("VAULT_ADDR", "http://127.0.0.1:8200", [System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable("VAULT_TOKEN", $($initResult | Select-String -Pattern "Initial Root Token" | ForEach-Object { $_.Line.Split(":")[1].Trim() }), [System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable("VAULT_UNSEAL_KEYS", ($unsealKeys -join ','), [System.EnvironmentVariableTarget]::User)

# Set up Vault as a Windows service
Write-Host "Setting up Vault as a Windows service..."
New-Service -Name $serviceName -BinaryPathName "$vaultBinaryPath $serviceArgs" -DisplayName "Vault" -Description "HashiCorp Vault" -StartupType Automatic

# Start the Vault service
Write-Host "Starting Vault service..."
Start-Service -Name $serviceName

# Check if the service was created and started successfully
$serviceStatus = Get-Service -Name $serviceName
Write-Host "Vault service status: $($serviceStatus.Status)"

# Final output
Write-Host "Vault is ready. You can find the initialization details at C:\Users\vmadmin\Downloads\vault_config.json."
Write-Host "Vault token, unseal keys, and VAULT_ADDR environment variables have been set."

# End of script
Write-Host "Script completed successfully."







