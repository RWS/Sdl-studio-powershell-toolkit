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

# Creates the user manager instance, this variable will be used for accessing various resources.
Write-Host "Connect to the management server.";
$manager = Get-UserManager $serverUri $userName $password;

# Retrieve all the existing users from the server
$allUsers = Get-AllUsers $manager

# Display the first 10 users or less (this is because, depending on the groupshare server, the returned list might be longer)
Write-Host "We have" $allUsers.Count "users..."
Write-Host "Let's list the first 10 (or less) users"
$max = 10;

for ($i = 0; $i -lt $max -and $i -lt $allUsers.Count; $i++)
{
    Write-Host $allUsers[$i].Name -ForegroundColor Green;
}

# Display the first 10 organizations or less (this is because, depending on the groupshare server, the returned list might be longer)
Write-Host "List the first 10 organizations on the server."
$allOrganizations = Get-AllOrganizations $manager;

for ($i = 0; $i -lt 10 -and $i -lt $allOrganizations.Count; $i++)
{
	
	Write-Host $allOrganizations[$i].Name -ForegroundColor green;
}

# Store user related information for new user creation
Write-Host "Now let's try to add a new user."
$userName = "APIUser_$studioVersion";
$userDisplayName = "API User $StudioVersion";
$userEmailAddress = "api@api.com";
$userDescription = "User created using API";
$userPassword = "ClearP@123";

# Creates the new user
$null = New-User $manager "/" $userName $userDisplayName $userPassword $userEmailAddress $userDescription;
Write-Host "Completed.";


# Removes the Toolkit Modules and the ToolkitInitializer
Remove-ToolkitModules;
Remove-Module -name "ToolkitInitializer";