# Get the list of network interfaces
$networkInterfaces = Get-NetConnectionProfile

# Loop through each network interface and set the desired network category
foreach ($interface in $networkInterfaces) {
    $interfaceName = $interface.InterfaceAlias
    Write-Host "Changing network category for interface: $interfaceName"

    # Set the network category to 'Private' (You can change to 'Public' if needed)
    Set-NetConnectionProfile -InterfaceAlias $interfaceName -NetworkCategory "Private"
    Write-Host "Network category for '$interfaceName' set to 'Private'."
}

# Enable PowerShell Remoting on the target machine (in case it's not already)
Enable-PSRemoting -Force

# Set Trusted Hosts to "*" (use cautiously, restrict to specific hosts for security)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force # # Allow connections from any IP (for testing purposes)


# Get current network connection profile and display it for debugging
$connectionProfile = Get-NetConnectionProfile
Write-Output "Current Network Profile: $($connectionProfile.NetworkCategory) for $($connectionProfile.InterfaceAlias)"


# Check the status of WinRM service
$winrmService = Get-Service WinRM
Write-Output "WinRM Service Status: $($winrmService.Status)"

# Start WinRM service if it's not already running
if ($winrmService.Status -ne 'Running') {
    Start-Service WinRM
    Write-Output "WinRM service started."
} else {
    Write-Output "WinRM service is already running."
}

# Verify if firewall exceptions are added (it should automatically happen if network is Private)
Enable-NetFirewallRule -DisplayGroup "Windows Remote Management"
Write-Output "WinRM firewall rule enabled."


# Output the updated network interfaces to verify
Get-NetConnectionProfile

New-NetFirewallRule -Name "Allow WinRM HTTP" -DisplayName "Allow WinRM HTTP" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 5985
New-NetFirewallRule -Name "Allow WinRM HTTPS" -DisplayName "Allow WinRM HTTPS" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 5986


winrm enumerate winrm/config/listener