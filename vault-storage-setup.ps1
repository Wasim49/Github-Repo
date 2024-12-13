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

Write-Host "Starting Vault server on port 8200 and capturing output..."
$vaultLogPath = "C:\Users\$env:USERNAME\Downloads\vault_output.txt"
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
$envVars | ConvertTo-Json -Depth 2 | Set-Content "C:\Users\$env:USERNAME\Downloads\vault_config.json"

Write-Host "Vault initialized successfully and running in background. Unseal keys and root token saved to C:\Users\$env:USERNAME\Downloads\vault_config.json."

# Provide feedback to the user
Write-Host "Vault is ready. You can find the initialization details at C:\Users\$env:USERNAME\Downloads\vault_config.json."

# Path to the JSON configuration file
$jsonFilePath = "C:\Users\$env:USERNAME\Downloads\vault_config.json"

# Read and parse the JSON file, then extract the unseal keys, VAULT_TOKEN, and VAULT_ADDR
$vaultConfig = Get-Content -Path $jsonFilePath -Raw | ConvertFrom-Json

# Grabbing the Vault token, VAULT_ADDR, and the first three unseal keys (from the JSON configuration)
$vaultToken = $vaultConfig.VAULT_TOKEN
$vaultAddr = $vaultConfig.VAULT_ADDR
$unsealKeys = $vaultConfig.UNSEAL_KEYS[0..2]

# Combine the unseal keys into one string (delimited by commas)
$unsealKeysString = $unsealKeys -join ','

# Unseal Vault using the first three unseal keys
$unsealKeys | ForEach-Object { vault operator unseal $_ }

# Create Vault token, VAULT_ADDR, and unseal keys as system-wide environment variables
[System.Environment]::SetEnvironmentVariable("VAULT_TOKEN", $vaultToken, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("VAULT_ADDR", $vaultAddr, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("VAULT_UNSEAL_KEYS", $unsealKeysString, [System.EnvironmentVariableTarget]::Machine)

# Load the system environment variables into the current session
$env:VAULT_TOKEN = [System.Environment]::GetEnvironmentVariable("VAULT_TOKEN", "Machine")
$env:VAULT_ADDR = [System.Environment]::GetEnvironmentVariable("VAULT_ADDR", "Machine")
$env:VAULT_UNSEAL_KEYS = [System.Environment]::GetEnvironmentVariable("VAULT_UNSEAL_KEYS", "Machine")

# Provide feedback that the variables are set
Write-Host "Vault Token, VAULT_ADDR, and Unseal Keys set as system environment variables."

# Enable Vault secrets engine (if Vault is unsealed and token is set correctly)
vault secrets enable -path=secret kv

# Final message

Write-Host "Vault is ready. You can keep this master server session open or you can start master session in another powershell session using this command  vault server -config="C:\Program Files\Vault""





