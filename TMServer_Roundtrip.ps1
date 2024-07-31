$studioVersion = "Studio18";
$serverUri = "https://example.com"
$userName = "sa"
$password = "sa"

Clear-Host
Write-Host "This script demonstrates how the PowerShell Toolkit can be used to automate small workflows";

Write-Host "Start with loading PowerShell Toolkit modules.";
Import-Module -Name ToolkitInitializer;

Import-ToolkitModules $studioVersion;
Write-Host "Let's connect to the TM Server";
$tmServer = Get-TMServer $serverUri $userName $password;

Write-Host "Display all the DB servers.";
$dbServers = Get-DbServers $tmServer;
foreach($dbServer in $dbServers)
{
	Write-Host $dbServer.Name -ForegroundColor green;
}


Write-Host "Display the first 10 containers";
$containers = Get-Containers $tmServer;
for ($i = 0; $i -lt 10 -and $i -lt $containers.Count; $i++)
{
    Write-Host $containers[$i].Name "in organization" $containers[$i].ParentResourceGroupPath -ForegroundColor green;
}

Write-Host "Now let's look more closely on all the TMs.";
$tms = Get-ServerBasedTMs $tmServer;
Write-Host "We have" $tms.Count "translation memories..."
Write-Host "Let's list the first 10 TMs"
for ($i = 0; $i -lt 10 -and $i -lt $tms.Count; $i++)
{
    Write-Host $tms[$i].Name "in organization" $tms[$i].ParentResourceGroupPath -ForegroundColor green;
}

Write-Host "Now Let's create a new container"
$containerName = "Api Made Container"
$containerDBName = "API_$studioVersion"

$workingContainer = New-Container $tmServer $dbServers[0] $containerName $containerDBName;

Write-Host "Now create a TM.";
$sourceLanguageCode = "en-US";
$targetLanguageCode = "de-DE";
New-ServerBasedTM $tmServer $workingContainer "API Translation Memory"  $sourceLanguageCode $targetLanguageCode

Write-host "Finished";
Remove-ToolkitModules
Remove-Module -Name ToolkitInitializer