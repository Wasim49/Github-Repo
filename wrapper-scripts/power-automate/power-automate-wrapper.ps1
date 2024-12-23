# GitHub URL of the raw .zip solution file
$githubUrl = "https://github.com/username/repository/archive/refs/heads/main.zip"  # Replace with the correct URL

# Local path to save the downloaded solution
$localFilePath = "C:\path\to\save\solution.zip"  # Adjust this path

# Download the solution file from GitHub
Invoke-WebRequest -Uri $githubUrl -OutFile $localFilePath

# Define the environment name (replace with your environment)
$environmentName = "YourEnvironmentName"  # Replace with your environment name

# Import the necessary PowerApps modules
Import-Module Microsoft.PowerApps.Administration.PowerShell
Import-Module Microsoft.PowerApps.Client.PowerShell

# Log in to PowerApps
Add-PowerAppsAccount

# Import the solution
Import-AdminSolution -EnvironmentName $environmentName -SolutionFilePath $localFilePath

Write-Host "Solution imported successfully into environment: $environmentName"
