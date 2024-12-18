Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Vault using Chocolatey
Write-Host "Installing Vault..."
choco install vault -y

# Start Vault in dev mode and capture its output
Write-Host "Starting Vault in dev mode and capturing output..."
$vaultLogPath = "c:\scripts\vault_output.txt"
$vaultProcess = Start-Process "vault" -ArgumentList "server", "-dev" -WindowStyle Hidden -PassThru -RedirectStandardOutput $vaultLogPath

# Wait for Vault to initialize
Write-Host "Waiting for Vault to initialize..."
Start-Sleep -Seconds 10

# Check if the log file exists
if (-Not (Test-Path $vaultLogPath)) {
    Write-Host "Error: Vault output log file not found at $vaultLogPath."
    Stop-Process -Id $vaultProcess.Id -Force
    Exit
}

# Read the Vault log output
$vaultOutput = Get-Content $vaultLogPath -Raw

# Extract the root token
$vaultToken = if ($vaultOutput -match 'Root Token: (\S+)') { $Matches[1] } else { $null }

# Extract the unseal key
$unsealKey = if ($vaultOutput -match 'Unseal Key: (\S+)') { $Matches[1] } else { $null }

# Validate the token and unseal key extraction
if (-not $vaultToken -or -not $unsealKey) {
    Write-Host "Error: Could not find the root token or unseal key in the Vault output log."
    Stop-Process -Id $vaultProcess.Id -Force
    Exit
}

# Set the Vault address
$vaultAddr = 'http://127.0.0.1:8200'

# Store the environment variables including the unseal key in a JSON file
$envVars = @{
    VAULT_ADDR  = $vaultAddr
    VAULT_TOKEN = $vaultToken
    UNSEAL_KEY  = $unsealKey
}
$envVars | ConvertTo-Json -Depth 2 | Set-Content "c:\scripts\vault_config.json"

Write-Host "Vault installation complete."
Write-Host "VAULT_ADDR, VAULT_TOKEN, and UNSEAL_KEY have been saved to c:\scripts\vault_config.json"

# Stop the Vault process
Write-Host "Stopping Vault process..."
Stop-Process -Id $vaultProcess.Id -Force

