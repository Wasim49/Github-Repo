# Step 1: Define the GitHub URL and local download path
$githubUrl = "https://github.com/Wasim49/Github-Repo/blob/main/actual-scripts/power-automate/power-automate-flow-files.zip"  # Replace with your GitHub URL
$downloadPath = "C:\scripts\power-automate-flow-files.zip"  # Path to where the ZIP file will be downloaded

# Step 2: Download the solution file from GitHub
Write-Host "Downloading solution file from GitHub..."
try {
    Invoke-WebRequest -Uri $githubUrl -OutFile $downloadPath
    Write-Host "Solution file downloaded successfully from GitHub to $downloadPath."
} catch {
    Write-Host "Error downloading solution: $_"
    exit
}

# Step 3: Authenticate with Power Platform CLI
$authProfileName = 'MyAuthProfile'
$environmentUrl = 'https://orgfd0ed784.crm11.dynamics.com'
$username = 'cloud_user_p_e8a24d7c@realhandsonlabs.com'
$password = 'OWl$weJrExQAoV76zOyC'

Write-Host "Authenticating with Power Platform CLI..."
try {
    pac auth create --name $authProfileName --environment $environmentUrl --username $username --password $password
    Write-Host "Authentication successful."
} catch {
    Write-Host "Error authenticating with Power Platform CLI: $_"
    exit
}

# Step 4: Import the solution file into the Power Platform environment
Write-Host "Importing solution into the Power Platform environment..."
try {
    pac solution import --path $downloadPath --environment $environmentUrl
    Write-Host "Solution imported successfully."
} catch {
    Write-Host "Error importing solution: $_"
    exit
}

Write-Host "Process completed successfully!"

