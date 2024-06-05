cls
Write-Host "This script demonstrates how the PowerShell Toolkit can be used to automate small workflows";

Write-Host "Start with loading PowerShell Toolkit modules.";
$StudioVersion = "Studio18";
Import-Module -Name ToolkitInitializer
Import-ToolkitModules $StudioVersion

Write-Host "Now let's create a new empty TM.";

$tmFilePath = "c:\Projects\PowerShellToolKit\PowerShellTest\$StudioVersion\SampleTM\new_en_de.sdltm";
$sdltmdesc = "Created by PowerShell" ;
$sdltmsrclangcode = "en-US" ;
$sdltmtgtlangcode = "de-DE" ;

New-FileBasedTM -filePath $tmFilePath -description $sdltmdesc -sourceLanguageName $sdltmsrclangcode -targetLanguageName $sdltmtgtlangcode;

Write-Host "A TM created at: " $tmFilePath;

Write-Host "Now let's create a new project which will use the newly created TM.";

$projectName = "My Test Project";
$projectDestinationPath = "c:\Projects\PowerShellToolKit\PowerShellTest\$StudioVersion\" + "SampleProject";
$sourceLanguage = Get-Language "en-US";
$targetLanguages = Get-Languages @("de-DE");
$inputFilesFolderPath = "c:\Projects\PowerShellToolKit\PowerShellTest\$StudioVersion\SampleFiles";

if(!(test-path $inputFilesFolderPath))
{
	New-Item -ItemType Directory -Force -Path $inputFilesFolderPath
}
New-Item ($inputFilesFolderPath + "\sampleTestFile.txt") -type file -force -value "This is text added to the sample file."

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
	New-Package $targetLanguage ("c:\Projects\PowerShellToolKit\PowerShellTest\$StudioVersion\translationpackage_"+ $targetLanguage.IsoAbbreviation +".sdlppx") $project;
}

Write-Host "Completed.";
Remove-ToolkitModules;
Remove-Module -Name ToolkitInitializer