$studioVersion = "Studio18"; # Change this with the actual Trados Studio version
$serverUri = "https://example.com/" # Change this with the actual Groupshare Server
$userName = "user@example.com" # Change this with the username used for connecting to the Groupshare Server
$password = "password123!" # Change this with the password used for connecting to the Groupshare Server

# Clear the console host...
Clear-Host;

# Display a message to indicate the purpose of the script
Write-Host "This script demonstrates how the PowerShell Toolkit can be used to automate small workflows";

# Load the necessary modules to access Trados Studio Toolkit functions.
# These commands ensure that the required PowerShell modules are available to use in the script.
Write-Host "Start with loading PowerShell Toolkit modules.";

# Import the ToolkitInitializer module first. This sets up the environment.
Import-Module -Name ToolkitInitializer

# Import the specific toolkit modules for the Trados Studio version you are using.
# This makes all the necessary functions available for your script to use.
Import-ToolkitModules $studioVersion;

# Now, you can start using the functions provided by the toolkit.

# Create the CredentialStore object that will be used for retrieving project info and publishing projects
$credentialStore = Get-ProjectServer $serverUri $userName $password

# Retrieving the projects info from the Root Organization, "/"
Write-host "Now Let's see all the projects from the Root Organization"
$projectInfos = Show-ServerbasedProjects -server $credentialStore -organizationPath "/"
foreach ($projectInfo in $projectInfos)
{
    Write-Host "Project: $($projectInfo.Name) in oganization $($projectInfo.organizationPath)" -ForegroundColor Green;
}

# Publishing the Project created form the FileBasedProject_Roundtrip to the groupshare server
Write-Host "Publishing an existing filebased project to the server"
$project = Get-Project "c:\Projects\PowerShellToolKit\PowerShellTest\$StudioVersion\SampleProject"
Publish-Project $credentialStore $project "/"

# Download the project
$downloadLocation = "c:\Projects\PowerShellToolKit\PowerShellTest\$StudioVersion\ServerBasedProjects"
Write-Host "Now let's download the server project at c:\Projects\PowerShellToolKit\PowerShellTest\$StudioVersion\ServerBasedProjects"

$null = Get-ServerBasedProject $credentialStore "/" "My Test Project" $downloadLocation;

# Removes the Toolkit Modules and the ToolkitInitializer
Write-host "Finish!";
Remove-toolkitmodules;
Remove-module -name ToolkitInitializer;
