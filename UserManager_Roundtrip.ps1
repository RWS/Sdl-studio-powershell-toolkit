$studioVersion = "Studio18";
$serverUri = "https://example.com"
$userName = "sa"
$password = "sa"

Clear-Host
Write-Host "This script demonstrates how the PowerShell Toolkit can be used to automate small workflows";

Write-Host "Start with loading PowerShell Toolkit modules.";
Import-Module -Name ToolkitInitializer;
Import-ToolkitModules $studioVersion;

Write-Host "Connect to the management server.";
$cache = Get-UMServer $serverUri $userName $password;
$manager = Get-UserManager $cache
$allUsers = Get-AllUsers $manager

Write-Host "We have" $allUsers.Count "users..."
Write-Host "Let's list the first 10 (or less) users"
$max = 10;

for ($i = 0; $i -lt $max -and $i -lt $allUsers.Count; $i++)
{
    Write-Host $allUsers[$i].Name -ForegroundColor Green;
}

Write-Host "List the first 10 organizations on the server."
$allOrganizations = Get-AllOrganizations $manager;

for ($i = 0; $i -lt 10 -and $i -lt $allOrganizations.Count; $i++)
{
	
	Write-Host $allOrganizations[$i].Name -ForegroundColor green;
}

Write-Host "Now let's try to add a new user."
$userName = "APIUser_$studioVersion";
$userDisplayName = "API User $StudioVersion";
$userEmailAddress = "api@api.com";
$userDescription = "User created using API";
$userPassword = "ClearP@123";

$null = New-User $manager $allOrganizations[0] $userName $userDisplayName $userPassword $userEmailAddress $userDescription;

Write-Host "Completed.";
Remove-ToolkitModules;
Remove-Module -name "ToolkitInitializer";