# Read the Vault credentials from the JSON file created by the first script
$envVars = Get-Content -Path "c:\scripts\vault_config.json" | ConvertFrom-Json

# Set the environment variables for VAULT_ADDR and VAULT_TOKEN
$env:VAULT_ADDR = $envVars.VAULT_ADDR
$env:VAULT_TOKEN = $envVars.VAULT_TOKEN

# Verify if the Vault server is accessible
Write-Host "Checking Vault status..."
$vaultStatus = vault status 2>&1

if ($vaultStatus -match "sealed\s*:\s*true") {
    Write-Host "Vault is sealed. Attempting to unseal Vault..."

    # Use the unseal key to unseal the Vault
    if ($envVars.PSObject.Properties.Name -contains 'UNSEAL_KEY') {
        vault operator unseal $envVars.UNSEAL_KEY
    } else {
        Write-Host "Error: Unseal key not found in the configuration file."
        Exit
    }

    # Re-check the Vault status
    $vaultStatus = vault status 2>&1
    if ($vaultStatus -match "sealed\s*:\s*true") {
        Write-Host "Vault is still sealed. Please unseal it manually."
        Exit
    } else {
        Write-Host "Vault has been successfully unsealed."
    }
} else {
    Write-Host "Vault is already unsealed."
}

# Example: Creating a secret
Write-Host "Adding a sample secret..."
vault kv put secret/my_secret vmpassword=izjKJ!TTVbE4

Write-Host "Secret successfully created."









