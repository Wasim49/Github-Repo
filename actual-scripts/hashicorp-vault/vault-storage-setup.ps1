# Define the path for the Vault configuration file
$vaultConfigPath = "c:\scripts\vault-config.hcl"

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
$vaultDataPath = "c:\VaultData"
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
$vaultBinaryPath = "c:\ProgramData\chocolatey\bin\vault.exe"
if (-Not (Test-Path -Path $vaultBinaryPath)) {
    Write-Host "Error: Vault executable not found at $vaultBinaryPath. Ensure Vault is installed via Chocolatey."
    Exit 1
}

Write-Host "Starting Vault server on port 8200 and capturing output..."
$vaultLogPath = "c:\scripts\vault_output.txt"
$vaultProcess = Start-Process -FilePath $vaultBinaryPath -ArgumentList "server", "-config=`"$vaultConfigPath`"" -WindowStyle Hidden -PassThru -RedirectStandardOutput $vaultLogPath

# Wait for Vault server to initialize
Write-Host "Waiting for Vault server to initialize..."
Start-Sleep -Seconds 10

# Initialize Vault
Write-Host "Initializing Vault..."
$initOutput = vault operator init 2>&1 | Out-String

# Validate initialization output
if (-Not $initOutput) {
    Write-Host "Error: Failed to initialize Vault."
    Stop-Process -Id $vaultProcess.Id -Force
    Exit
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
    Stop-Process -Id $vaultProcess.Id -Force
    Exit
}

# Save unseal keys and root token to a JSON file
$vaultAddr = 'http://127.0.0.1:8200'

$envVars = @{
    VAULT_ADDR  = $vaultAddr
    VAULT_TOKEN = $rootToken
    UNSEAL_KEYS = $unsealKeys
}
$envVars | ConvertTo-Json -Depth 2 | Set-Content "c:\scripts\vault_config.json"

Write-Host "Vault configuration is complete. Vault binary is at C:\ProgramData\chocolatey\bin\vault.exe. Secrets are persisted in C:\VaultData. Token & unseal credentials are stored at c:\scripts\vault_config.json. c:\scripts contains everything else"

# Provide feedback to the user
Write-Host "After restart if you want to run vault again. Open two powershell sessions. In first run this command, vault server -config=""C:\scripts\vault-config.hcl"". In second powershell session run vault unseal script thats in c:\scripts, then do vault status in the second powershell session"












