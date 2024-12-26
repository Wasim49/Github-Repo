# Step 1: Define the GitHub URL and local download path
$githubUrl = "https://raw.githubusercontent.com/Wasim49/Github-Repo/main/actual-scripts/power-automate/power-automate-flow-files.zip"  # Replace with your GitHub URL
$downloadPath = "C:\scripts\power-automate-flow-files.zip"  # Path to where the ZIP file will be downloaded
$jsonPath = "C:\scripts\environment-details.json"  # JSON file to save environment details

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
$username = 'cloud_user_p_579f9d7b@realhandsonlabs.com'
$password = '9duAo#9HgU1Lca6FTnyX'

Write-Host "Authenticating with Power Platform CLI..."
try {
    pac auth create --name $authProfileName --username $username --password $password
    Write-Host "Authentication successful."
} catch {
    if ($_.Exception.Message -like "*AuthProfileNameAlreadyExist*") {
        Write-Host "Auth profile already exists. Proceeding with existing profile."
    } else {
        Write-Host "Error authenticating with Power Platform CLI: $_"
        exit
    }
}

# Step 4: Create a new environment
$environmentName = 'target-env'
$environmentType = 'Trial'

Write-Host "Creating a new environment..."
try {
    $creationOutput = pac admin create --name $environmentName --type $environmentType
    Write-Host $creationOutput
    Write-Host "Environment '$environmentName' created successfully."
} catch {
    Write-Host "Error creating environment: $_"
    exit
}

# Step 5: List environments and extract details to JSON
Write-Host "Listing environments and extracting details to JSON..."
try {
    $envListOutput = pac admin list
    $envListLines = $envListOutput -split "`n" | Where-Object { $_ -match $environmentName }
    $envDetails = @{}

    foreach ($line in $envListLines) {
        if ($line -match "(\S+)\s+(\S+)\s+(https://\S+)\s+(\S+)\s+(\S+)") {
            $envDetails = @{
                Name            = $matches[1]
                EnvironmentId   = $matches[2]
                EnvironmentUrl  = $matches[3]
                Type            = $matches[4]
                OrganizationId  = $matches[5]
            }
        }
    }

    if ($envDetails) {
        $envDetails | ConvertTo-Json -Depth 3 | Out-File $jsonPath
        Write-Host "Environment details saved to $jsonPath."
    } else {
        Write-Host "No matching environment found."
        exit
    }
} catch {
    Write-Host "Error listing environments: $_"
    exit
}

# Step 6: Retrieve environment URL from JSON file
Write-Host "Retrieving environment URL from JSON..."
try {
    $environmentDetails = Get-Content $jsonPath | ConvertFrom-Json
    $environmentUrl = $environmentDetails.EnvironmentUrl
    if ($environmentUrl) {
        Write-Host "Environment URL: $environmentUrl"
    } else {
        Write-Host "Environment URL not found in JSON file."
        exit
    }
} catch {
    Write-Host "Error reading environment details from JSON: $_"
    exit
}

# Step 7: Import the solution
Write-Host "Importing the solution..."
try {
    pac solution import --path $downloadPath --environment $environmentUrl
    Write-Host "Solution imported successfully to environment '$environmentUrl'."
} catch {
    Write-Host "Error importing solution: $_"
    exit
}











