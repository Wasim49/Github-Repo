# Step 1: Read the Vault credentials from the JSON file
$envVars = Get-Content -Path "c:\scripts\vault_config.json" | ConvertFrom-Json

# Step 2: Set the environment variables for VAULT_ADDR and VAULT_TOKEN
$env:VAULT_ADDR = $envVars.VAULT_ADDR
$env:VAULT_TOKEN = $envVars.VAULT_TOKEN

# Step 3: Ensure Vault address is valid (already read from the JSON file)
$vaultAddr = $envVars.VAULT_ADDR
Write-Host "Vault Address: $vaultAddr"

# Step 4: Unseal Vault using the unseal keys
foreach ($unsealKey in $envVars.UNSEAL_KEYS) {
    Write-Host "Unsealing Vault with key: $unsealKey"
    
    # Execute the unseal command using the Vault address and unseal key
    $command = "vault operator unseal -address=$vaultAddr $unsealKey"
    Invoke-Expression $command
}

Write-Host "Vault unsealed successfully."

