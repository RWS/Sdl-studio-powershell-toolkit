$StudioVersion = "Studio18";
$ProjectSourceFiles = "C:\Path\To\Samples"
Clear-Host
Write-Host "This script demonstrates how the PowerShell Toolkit can be used to automate small workflows";

Write-Host "Start with loading PowerShell Toolkit modules.";

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
$sourceLanguage = "en-US";
$targetLanguages = "de-DE", "fr-FR";
$tmProvider = Get-TranslationProvider -tmPath "$tmFilePath"
$tmProvider
$inputFilesFolderPath = "$ProjectSourceFiles\SampleFiles";
$pathForPerfectMatch = "$ProjectSourceFiles\ForPerfectMatch"
$referenceFiles = @("Reference_1_Pp.pptx", "sample2_reference.pptx")
$localizableFiles = @("meme1.jpg", "meme2.jpg")
$mergeFiles = @("books.xml","datax.xml", "data.json", "data2.json")
$mergeName = "MergedFile"
$dueDate = "2030-03-24";
$description = "ApiProject"

New-Project -ProjectName $projectName -projectDestination $projectDestinationPath -sourceLanguage $sourceLanguage -targetLanguages $targetLanguages -translationProviders @($tmProvider) -sourceFilesFolder $inputFilesFolderPath -referenceFiles $referenceFiles -localizableFiles $localizableFiles -mergeFiles $mergeFiles -mergeFileName $mergeName -pathToPerfectMatch $pathForPerfectMatch -projectDueDate $dueDate -projectDescription $description;

Write-Host "A new project creation completed.";

Write-Host "Now open project and get analyze statistics.";

$project = Get-Project ($projectDestinationPath);

Get-AnalyzeStatistics $project;

Write-Host "Press any key to continue ...";

Write-Host "Now for each target language create translation package.";

$targetLanguages = Get-Languages $targetLanguages;
foreach($targetLanguage in $targetLanguages)
{
	Export-Package $targetLanguage ("c:\Projects\PowerShellToolKit\PowerShellTest\$StudioVersion\translationpackage_"+ $targetLanguage.IsoAbbreviation +".sdlppx") $project;
}

Write-Host "Completed.";
Remove-ToolkitModules;
Remove-Module -Name ToolkitInitializer
