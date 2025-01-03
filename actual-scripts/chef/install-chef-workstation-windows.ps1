# Step 1: Verify Chocolatey Installation
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Output "Chocolatey is already installed. Upgrading Chocolatey..."
    choco upgrade chocolatey -y
} else {
    Write-Output "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Step 2: Verify Chef Workstation Installation
Write-Output "Installing or upgrading Chef Workstation..."
choco upgrade chef-workstation -y

# Step 3: Check if Git is installed
if (-Not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Output "Git is not installed. Installing Git..."
    choco install git -y
    Write-Output "Git installed successfully. Restarting the script in the same session..."
    Exit 0
}

# Step 4: Create directories for the repository
$basePath = "C:\scripts\chef"
if (-Not (Test-Path $basePath)) {
    Write-Output "Creating directory structure at $basePath..."
    New-Item -ItemType Directory -Path $basePath -Force | Out-Null
} else {
    Write-Output "Directory structure already exists at $basePath."
}

# Step 5: Clone the specific repository
$repoUrl = "https://github.com/Wasim49/Github-Repo.git"
$repoPath = $basePath

if (Test-Path $repoPath) {
    Write-Output "Repository already cloned. Removing the old repository..."
    Remove-Item -Recurse -Force -Path $repoPath
}

Write-Output "Cloning the repository from $repoUrl..."
git clone $repoUrl $repoPath

# Debug: Show the contents of the cloned folder
Write-Output "Contents of $basePath after cloning:"
Get-ChildItem -Path $basePath

# Step 6: Check if 'install_software' folder exists in the cloned repository
$installSoftwarePath = Join-Path $basePath "install_software"
if (-Not (Test-Path $installSoftwarePath)) {
    Write-Output "The folder 'install_software' was not found in the cloned repository. Please check the repository structure."
    Exit 1
}

Write-Output "The folder 'install_software' found successfully."

# Step 7: Change directory to the 'recipes' folder
$recipesPath = Join-Path $installSoftwarePath "recipes"
if (-Not (Test-Path $recipesPath)) {
    Write-Output "Recipes folder not found. Please check the repository structure."
    Exit 1
}

Write-Output "Changing directory to $recipesPath..."
Set-Location $recipesPath

# New Step: Copy metadata.rb to nodes directory (before all knife commands)
$metadataPath = Join-Path $recipesPath "metadata.rb"
$nodesPath = Join-Path $recipesPath "nodes"

# Check if 'nodes' directory exists, if not, create it
if (-Not (Test-Path $nodesPath)) {
    Write-Output "Nodes directory does not exist. Creating it..."
    New-Item -ItemType Directory -Path $nodesPath -Force | Out-Null
} else {
    Write-Output "Nodes directory already exists."
}

# Copy metadata.rb to the nodes directory
Write-Output "Copying metadata.rb to $nodesPath..."
Copy-Item -Path $metadataPath -Destination $nodesPath -Force

Write-Output "metadata.rb copied successfully to the nodes folder."

# Step 8: Run `cookstyle` on `default.rb`
Write-Output "Running cookstyle on default.rb..."
cookstyle default.rb

# Step 9: Run `chef-client` in local mode
Write-Output "Running chef-client in local mode with --why-run..."
chef-client --local-mode default.rb --why-run

# Step 10: Change directory to Chef working directory before running knife commands
$chefDir = "C:\scripts\chef\install_software"  # You can change this if your chef directory is different
Write-Output "Changing directory to $chefDir..."
Set-Location $chefDir

# Step 11: Set the KNIFE_CONFIG environment variable to specify the correct knife.rb file
$knifeConfigPath = "C:\scripts\chef\install_software\knife.rb"  # Specify the correct path to knife.rb

if (-Not (Test-Path $knifeConfigPath)) {
    Write-Output "Warning: No knife configuration file found at $knifeConfigPath. You may need to create one for proper Chef Server interaction."
} else {
    Write-Output "Knife configuration file found at $knifeConfigPath."
    $env:KNIFE_CONFIG = $knifeConfigPath  # Set the environment variable for knife
}

# Step 12: Fetch SSL certificates (Optional if needed)
Write-Output "Fetching SSL certificates from the Chef server..."
knife ssl fetch

# Step 13: Check SSL certificates (Optional if needed)
Write-Output "Checking SSL certificates..."
knife ssl check

# Step 14: Upload all cookbooks to Chef server
Write-Output "Uploading all cookbooks to the Chef server..."
knife cookbook upload -a --cookbook-path $recipesPath

Write-Output "Automation completed successfully."




