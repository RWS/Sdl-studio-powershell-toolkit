cls
Write-Host "This script demonstrates how the PowerShell Toolkit can be used to automate small workflows";

Write-Host "Start with loading PowerShell Toolkit modules.";
Import-Module -name "TMHelper";
Import-Module -name "ProjectHelper";
Import-Module -name "GetGuids";
Import-Module -name "PackageHelper";

Write-Host "Now let's create a new empty TM.";

$indexes = Get-DefaultFuzzyIndexes;
$recognizers = Get-DefaultRecognizers;
$tmFilePath = "c:\Projects\PowerShellToolKit\PowerShellTest\SampleTM\new_en_de.sdltm"

New-FileBasedTM $tmFilePath "Created by PowerShell" "en-US" "de-DE" $indexes $recognizers 7 4;
	
Write-Host "A TM created at: " $tmFilePath;

Write-Host "Now let's create a new project which will use the newly created TM.";

$projectName = "My Test Project";
$projectDestinationPath = "c:\Projects\PowerShellToolKit\PowerShellTest\" + [guid]::NewGuid();
$sourceLanguage = Get-Language "en-US";
$targetLanguages = Get-Languages @("de-DE");
$inputFilesFolderPath = "c:\Projects\PowerShellToolKit\PowerShellTest\SampleFiles";
$translationMemories = @($tmFilePath);


New-Project $projectName $projectDestinationPath $sourceLanguage $targetLanguages $translationMemories $inputFilesFolderPath $pathSampleFile;

Write-Host "A new project creation completed.";

Write-Host "Now open project and get analyze statistics.";

$project = Get-Project ($projectDestinationPath);

Get-AnalyzeStatistics $project;

Write-Host "Press any key to continue ...";

#enable when running in PowerShell command line
#$null = $Host.UI.RawUI.ReadKey([System.Management.Automation.Host.ReadKeyOptions]::IncludeKeyDown -bor [System.Management.Automation.Host.ReadKeyOptions]::NoEcho);

Write-Host "Now for each target language create translation package.";

foreach($targetLanguage in $targetLanguages)
{
	New-Package $targetLanguage ("c:\Projects\PowerShellToolKit\PowerShellTest\translationpackage_"+ $targetLanguage.IsoAbbreviation +".sdlppx") $project;
}

Write-Host "Completed.";
Remove-Module -Name "TMHelper";
Remove-Module -Name "ProjectHelper";
Remove-Module -name "GetGuids";
Remove-Module -name "PackageHelper";
