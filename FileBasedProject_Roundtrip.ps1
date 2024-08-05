$StudioVersion = "Studio18"; # Change this with the actual Trados Studio version
$ProjectSourceFiles = "C:\Path\To\Samples" # Change this value with the actual path to the Samples folder

# Clear the console host...
Clear-Host

# Display a message to indicate the purpose of the script
Write-Host "This script demonstrates how the PowerShell Toolkit can be used to automate small workflows";

# Load the necessary modules to access Trados Studio Toolkit functions.
# These commands ensure that the required PowerShell modules are available to use in the script.
Write-Host "Start with loading PowerShell Toolkit modules.";

# Import the ToolkitInitializer module first. This sets up the environment.
Import-Module -Name ToolkitInitializer

# Import the specific toolkit modules for the Trados Studio version you are using.
# This makes all the necessary functions available for your script to use.
Import-ToolkitModules $StudioVersion

# Now, you can start using the functions provided by the toolkit.

Write-Host "Now let's create a new empty TM.";

# Defining the necesarry properties for creating a Translation Memory.
$tmFilePath = "c:\Projects\PowerShellToolKit\PowerShellTest\$StudioVersion\SampleTM\new_en_de.sdltm";
$sdltmdesc = "Created by PowerShell" ;
$sdltmsrclangcode = "en-US" ;
$sdltmtgtlangcode = "de-DE" ;

# Creates a filebased translation memory with English (United States) as a source language and German as the target language
New-FileBasedTM -filePath $tmFilePath -description $sdltmdesc -sourceLanguageName $sdltmsrclangcode -targetLanguageName $sdltmtgtlangcode;

Write-Host "A TM created at: " $tmFilePath;
Write-Host "Now let's create a new project which will use the newly created TM.";

# Defining the necesarry properties for Project Creation
$projectName = "My Test Project";
$projectDestinationPath = "c:\Projects\PowerShellToolKit\PowerShellTest\$StudioVersion\" + "SampleProject";
$sourceLanguage = "en-US";
$targetLanguages = @("de-DE", "fr-FR");
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

# Creates the project
New-Project -ProjectName $projectName -projectDestination $projectDestinationPath -sourceLanguage $sourceLanguage -targetLanguages $targetLanguages -translationProviders @($tmProvider) -sourceFilesFolder $inputFilesFolderPath -referenceFiles $referenceFiles -localizableFiles $localizableFiles -mergeFiles $mergeFiles -mergeFileName $mergeName -pathToPerfectMatch $pathForPerfectMatch -projectDueDate $dueDate -projectDescription $description;

Write-Host "A new project creation completed.";
Write-Host "Now open project and get analyze statistics.";

# Retrieving the newly created project as a FileBasedProject instance
$project = Get-Project ($projectDestinationPath);

# Display the project statistics on the console
Get-AnalyzeStatistics $project;

Write-Host "Press any key to continue ...";
Write-Host "Now for each target language create translation package.";

# Export packages for all the project target languages
$targetLanguages = Get-Languages $targetLanguages;
foreach($targetLanguage in $targetLanguages)
{
	Export-Package $targetLanguage ("c:\Projects\PowerShellToolKit\PowerShellTest\$StudioVersion\translationpackage_"+ $targetLanguage.IsoAbbreviation +".sdlppx") $project;
}

Write-Host "Completed.";

# Removes the Toolkit Modules and the ToolkitInitializer
Remove-ToolkitModules;
Remove-Module -Name ToolkitInitializer
