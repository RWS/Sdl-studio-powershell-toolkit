$studioVersion = "Studio18"; # Change this with the actual Trados Studio version
$serverUri = "https://example.com/" # Change this with the actual Groupshare Server
$userName = "user@example.com" # Change this with the username used for connecting to the Groupshare Server
$password = "password123!" # Change this with the password used for connecting to the Groupshare Server

# Clear the console host...
Clear-Host

# Display a message to indicate the purpose of the script
Write-Host "This script demonstrates how the PowerShell Toolkit can be used to automate small workflows";

# Load the necessary modules to access Trados Studio Toolkit functions.
# These commands ensure that the required PowerShell modules are available to use in the script.
Write-Host "Start with loading PowerShell Toolkit modules.";

# Import the ToolkitInitializer module first. This sets up the environment.
Import-Module -Name ToolkitInitializer;

# Import the specific toolkit modules for the Trados Studio version you are using.
# This makes all the necessary functions available for your script to use.
Import-ToolkitModules $studioVersion;

# Now, you can start using the functions provided by the toolkit.

# Create the tmServer instance that will be used for accessing and manipulating Groupshare resources.
Write-Host "Let's connect to the TM Server";
$tmServer = Get-TMServer $serverUri $userName $password;

# Gets all the existing Database Servers.
Write-Host "Display all the DB servers.";
$dbServers = Get-DbServers $tmServer;
foreach($dbServer in $dbServers)
{
	Write-Host $dbServer.Name -ForegroundColor green;
}

# Retrieve all the containers within the Root Organization("/") only
Write-Host "Display the first 10 containers";
$containers = Get-Containers $tmServer "/";

foreach ($container in $container)
{
    Write-Host $container.Name "in organization "$container.ParentResourceGroupPath -ForegroundColor Green;
}

# Retrieve all the server-based translation memories from the Root Organization only ("/")
Write-Host "Now let's look more closely on all the TMs.";
$tms = Get-ServerBasedTMs $tmServer "/";
Write-Host "We have" $tms.Count "in the Root Organization"
foreach ($tm in $tms)
{
    write-host $tm.Name "in organization" $tm.ParentResourceGroupPath -ForegroundColor Green;
}

# Populates the variables for container Creation
Write-Host "Now Let's create a new container"
$containerName = "Api Made Container"
$containerDBName = "API_$studioVersion"

# Create a new container and store it in the $workingcontainer variable
$workingContainer = New-Container $tmServer $dbServers[0] $containerName $containerDBName;
Write-Host "Container " $workingContainer.Name " created."

# Populate the variables for server-based Translation Memory creation
Write-Host "Now create a TM.";
$sourceLanguageCode = "en-US";
$targetLanguageCode = @("de-DE", "fr-FR");

# Write the newly created translation memory
New-ServerBasedTM $tmServer $workingContainer "API Translation Memory"  $sourceLanguageCode $targetLanguageCode

# Removes the Toolkit Modules and the ToolkitInitializer
Write-host "Finished";
Remove-ToolkitModules
Remove-Module -Name ToolkitInitializer