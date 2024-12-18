# Read the Vault credentials from the JSON file created by the first script
$envVars = Get-Content -Path "c:\scripts\vault_config.json" | ConvertFrom-Json

# Set the environment variables for VAULT_ADDR and VAULT_TOKEN
$env:VAULT_ADDR = $envVars.VAULT_ADDR
$env:VAULT_TOKEN = $envVars.VAULT_TOKEN

# Now you can access the Vault address and unseal keys
$vaultAddr = $envVars.VAULT_ADDR
$unsealKeys = $envVars.UNSEAL_KEYS

