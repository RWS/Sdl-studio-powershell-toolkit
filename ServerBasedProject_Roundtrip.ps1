$studioVersion = "Studio18";
$serverUri = "https://example.com"
$userName = "sa"
$password = "sa"

Clear-Host;
Write-Host "This script demonstrates how the PowerShell Toolkit can be used to automate small workflows";

Write-Host "Start with loading PowerShell Toolkit modules.";
Import-ToolkitModules $studioVersion;

Write-host "Now Let's Publish the previously created Project to the server"
$credentialStore = Get-ProjectServer $serverUri $userName $password
$cache = Get-UMServer $serverUri $userName $password;
$manager = Get-UserManager $cache
$organizations = Get-AllOrganizations $manager
$project = Get-Project "c:\Projects\PowerShellToolKit\PowerShellTest\$StudioVersion\SampleProject"

Publish-Project $credentialStore $project $organizations[0]

Write-Host "Now let's download the server project"

$null = Get-ServerBasedProject $credentialStore $organizations[0] "My Test Project" "c:\Projects\PowerShellToolKit\PowerShellTest\$StudioVersion\ServerBasedProjects";

Write-host "Finish!";
Remove-toolkitmodules;
Remove-module -name ToolkitInitializer;
