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
  address = "127.0.0.1:8200"  # Use port 8200
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

# Stop any existing Vault process running on port 8200
Write-Host "Checking if Vault is already running on port 8200..."
$existingVaultProcess = Get-NetTCPConnection -LocalPort 8200
if ($existingVaultProcess) {
    Write-Host "Vault is already running. Stopping the existing Vault process..."
    # Get the process ID (PID) of the running Vault process
    $vaultProcessId = $existingVaultProcess.OwningProcess
    # Stop the Vault process
    Stop-Process -Id $vaultProcessId -Force
    Write-Host "Vault process stopped."
}

# Start Vault in server mode using the Chocolatey-installed binary
$vaultBinaryPath = "C:\ProgramData\chocolatey\bin\vault.exe"
if (-Not (Test-Path -Path $vaultBinaryPath)) {
    Write-Host "Error: Vault executable not found at $vaultBinaryPath. Ensure Vault is installed via Chocolatey."
    Exit 1
}

# Start Vault Server as a background process
Write-Host "Starting Vault server on port 8200..."
$serviceArgs = "-config=$vaultConfigPath"
Start-Process -FilePath $vaultBinaryPath -ArgumentList $serviceArgs -NoNewWindow -PassThru

# Wait for Vault to be ready (add delay to allow Vault to start properly)
Write-Host "Waiting for Vault to initialize..."
Start-Sleep -Seconds 15  # Adjust if needed based on system performance


# Initialize Vault
Write-Host "Initializing Vault..."
$initOutput = vault operator init 2>&1 | Out-String

# Validate initialization output
if (-Not $initOutput) {
    Write-Host "Error: Failed to initialize Vault."
    Exit 1
}

# Parse the unseal keys and root token from the initialization output
$unsealKeys = @()
$rootToken = $null

foreach ($line in $initOutput -split "`n") {
    if ($line -match "Unseal Key [0-9]+: (\S+)") {
        $unsealKeys += $Matches[1]
    } elseif ($line -match "Initial Root Token: (\S+)") {
        $rootToken = $Matches[1]
    }
}

# Validate parsing
if ($unsealKeys.Count -ne 5 -or -Not $rootToken) {
    Write-Host "Error: Could not extract all unseal keys or the root token from the Vault output."
    Exit 1
}

# Save unseal keys and root token to a JSON file
$vaultAddr = 'http://127.0.0.1:8200'

$envVars = @{
    VAULT_ADDR  = $vaultAddr
    VAULT_TOKEN = $rootToken
    UNSEAL_KEYS = $unsealKeys
}
$envVars | ConvertTo-Json -Depth 2 | Set-Content "C:\Users\$env:USERNAME\Downloads\vault_config.json"

Write-Host "Vault initialized successfully and running as a process. Unseal keys and root token saved to C:\Users\$env:USERNAME\Downloads\vault_config.json."

# Provide feedback to the user
Write-Host "Vault is initialized. You can find the initialization details at C:\Users\$env:USERNAME\Downloads\vault_config.json."

# Enable KV secrets engine
Write-Host "Enabling KV secrets engine..."
$kvEnableCommand = "$vaultBinaryPath secrets enable -path=secret/ kv"
Invoke-Expression $kvEnableCommand

# Set up Vault as a Windows service
$serviceName = "Vault"
Write-Host "Setting up Vault as a Windows service..."
New-Service -Name $serviceName -BinaryPathName "$vaultBinaryPath $serviceArgs" -DisplayName "Vault" -Description "HashiCorp Vault" -StartupType Automatic

# Start the Vault service and ensure it starts correctly
Write-Host "Starting Vault service..."
Start-Service -Name $serviceName
Start-Sleep -Seconds 5  # Allow the service to fully start

# Verify if Vault service is running
$serviceStatus = Get-Service -Name $serviceName
if ($serviceStatus.Status -ne 'Running') {
    Write-Host "Error: Vault service did not start. Current status: $($serviceStatus.Status)"
    Exit 1
}

# Provide final feedback
Write-Host "Vault is now running as a service, and the KV secrets engine is enabled."









