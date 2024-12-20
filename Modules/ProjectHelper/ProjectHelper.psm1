param ($StudioVersion) 

<#
    .SYNOPSIS
    Gets the task files of the given target language from an existing file based project.

    .DESCRIPTION
    Retrieves the task files from an existing file-based project based on the specified target language.

    .PARAMETER language
    The target language to be used to get the task files. This parameter can be retrieved from the Get-Language or Get-Languages functions.

    For further documentation:
    Get-Help Get-Language
    Get-Help Get-Languages

    .PARAMETER project
    An existing file-based project. This parameter can be retrieved from the Get-Project function.

    For further documentation:
    Get-Help Get-Project

    .EXAMPLE
    Get-TaskFileInfoFiles -language ([Sdl.Core.Globalization.Language] $targetLanguage) `
        -project ([Sdl.ProjectAutomation.FileBased.FileBasedProject] $existingProject)
    
    Retrieves the task files for the specified target language from the provided file-based project.

	.OUTPUTS
	[Sdl.ProjectAutomation.Core.TaskFileInfo[]]
	Returns an array of taskfilesinfo objects retrieved from the project.
#>
function Get-TaskFileInfoFiles
{
	param(
		[Parameter(Mandatory=$true)]
		[Sdl.Core.Globalization.Language] $language,

		[Parameter(Mandatory=$true)]
		[Sdl.ProjectAutomation.FileBased.FileBasedProject] $project)

	[Sdl.ProjectAutomation.Core.TaskFileInfo[]]$taskFilesList = @();
	try 
	{
		foreach($taskfile in $project.GetTargetLanguageFiles($language))
		{
			$fileInfo = New-Object Sdl.ProjectAutomation.Core.TaskFileInfo;
			$fileInfo.ProjectFileId = $taskfile.Id;
			$fileInfo.ReadOnly = $false;
			$taskFilesList = $taskFilesList + $fileInfo;
		}	
	}
	catch 
	{
		Write-Host "Target language $language does not exist in the project" -ForegroundColor Green
		return $null;
	}

	return $taskFilesList;
}

<#
	.SYNOPSIS
	Returns the target languages of an existing project.

	.PARAMETER projectPath
	Represents the physical path to the project's parent directory

	.EXAMPLE
	Get-ProjectTargetLanguages -projectPath "C:\Path\To\Project\"
#>
function Get-ProjectTargetLanguages 
{
	param (
		[Parameter(Mandatory=$true)]
		[String] $projectPath)

	$project = Get-Project $projectPath

	try {
		$pi = $project.GetProjectInfo()
		return $pi.TargetLanguages;
	}
	catch 
	{
		Write-Host "Project does not exist" -ForegroundColor Green;
	}
}

<#
    .SYNOPSIS
    Removes an existing file based project.

    .DESCRIPTION
    Removes an existing file based project based on the project provided.

    .PARAMETER projectToDelete
    The project to be removed. This parameter can be retrieved from the Get-Project function.

    For further documentation:
    Get-Help Get-Project

    .EXAMPLE
    Remove-Project -projectToDelete ([Sdl.ProjectAutomation.FileBased.FileBasedProject] $projectToDelete)
    Removes the specified project.
#>
function Remove-Project
{
	param (
		[Parameter(Mandatory=$true)]
		[Sdl.ProjectAutomation.FileBased.FileBasedProject] $projectToDelete)
		
	# Simply remove the existing Project object.
	$projectToDelete.Delete();
}

<#
    .SYNOPSIS
    Creates a new file-based project.

    .DESCRIPTION
    Creates a new file-based project. 
    Translation Memories and\or Translation Providers can be specified for the target-source pair or for all the language pairs.
    The project tasks can be predefined tasks or custom tasks.
    The predefined task sequence aligns with the Trados Studio UI task sequences.
    Custom tasks can be also provided, and only the provided tasks will be run.

    .PARAMETER projectName
    Represents the name of the project.

    .PARAMETER projectDestination
    Represents the destination where the project will be stored.

    .PARAMETER sourceLanguage
    Represents the source language code of the project.

    Example: de-DE, fr-FR

    .PARAMETER targetLanguages
    Represents the target language code(s) of the project.

    Example: de-DE, fr-FR

    .PARAMETER sourceFilesFolder
    Represents the directory where the translatable files are located.

    .PARAMETER referenceFiles
    (Optional) Specifies the files within the folder for the project that will be set as references.

    .PARAMETER localizableFiles
    (Optional) Specifies the files within the folder for the project that will be set as localizable.

    .PARAMETER mergeFiles
    (Optional) Specifies the files within the folder for the project that will be merged.

    MergeFileName and mergeFiles should be both provided.

    .PARAMETER mergeFileName
    (Optional) Specifies the name for the merged file.

    MergeFileName and mergeFiles should be both provided.

    .PARAMETER mergeFilePathInFolder
    (Optional) Specifies the path in the folder for the merged file.

    .PARAMETER pathToPerfectMatch
    (Optional) Specifies the path to the perfect match files.
	The files should be in the same structure as the source files and each of them should be into a folder representing the target language.
	Example:
	 Source file structure: C:\Users\aflorescu\Documents\windowspowershell\Samples\SampleFiles\Translatable\nameoffile
	 PathToPerfectMatch: C:\Users\aflorescu\Documents\windowspowershell\Samples\ForPerfectMatch\de-DE\Translatable\nameoffile

	.PARAMETER pathToTms
	(Optional) Specifies the path to the file based translation memories.
	IF this parameter is provided the provided tms will be added for all target languages for the project.

    .PARAMETER pathToTermbases
    (Optional) Specifies the path to the termbases.

    .PARAMETER projectReference
    (Optional) Specifies the project reference template. Defaults to the result of `Get-DefaultProjectTemplate`.

    .PARAMETER projectDueDate
    (Optional) Specifies the due date for the project.

    .PARAMETER projectDescription
    (Optional) Specifies the description for the project.

    .PARAMETER taskSequenceName
    (Optional) Specifies the name of the task sequence. Defaults to "Prepare Without Project TM".
    This value can be:
        "Prepare Without Project TM" (Default)
        "Prepare"
        "Analyze Only"
        "Pseudo-Translate Round Trip"

    .PARAMETER customTasks
    (Optional) Specifies custom tasks to run.
    This parameter should contain one or more of the following values:
        Scan
        Conversion
        Split
        PerfectMatch
        Analysis
        Translate
        GenerateTargetTranslation
        ExportFiles
        GenerateTargetFileLC
        Feedback
        WordCount
        TranslationCount
        UpdateProjectTm
        UpdateMasterTm
        Verification
        PseudoTranslate
        ExportToBilingualFile
        UpdateFromBilingualFile
        Retrofit
        TranslateAndAnalysis

    .EXAMPLE
    New-Project -projectName "Sample Project" -projectDestination "D:\Destination\To\Project" `
        -sourceLanguage "en-US" `
        -targetLanguages @("fr-FR", "de-DE") `
        -sourceFilesFolder "D:\Location\To\Source\Files" `
        -referenceFiles @("D:\Path\To\ReferenceFile1", "D:\Path\To\ReferenceFile2") `
        -localizableFiles @("D:\Path\To\LocalizableFile1", "D:\Path\To\LocalizableFile2") `
        -mergeFiles @("D:\Path\To\MergeFile1", "D:\Path\To\MergeFile2") `
        -mergeFileName "MergedFileName" `
        -mergeFilePathInFolder "D:\Merge\File\Path" `
        -pathToPerfectMatch "D:\Path\To\PerfectMatch" `
        -pathToTermbases @("D:\Path\To\Termbase1", "D:\Path\To\Termbase2") `
        -projectReference "DefaultTemplate" `
        -projectDueDate "2024-12-31" `
        -projectDescription "This is a sample project description." `
        -taskSequenceName "Prepare"
#>
function New-Project
{
	param(
		[Parameter(Mandatory=$true)]
		[String] $projectName,

		[Parameter(Mandatory=$true)]
		[String] $projectDestination,

		[Parameter(Mandatory=$true)]
		[String] $sourceFilesFolder,
		
		[String] $sourceLanguage, 
		[String[]] $targetLanguages,
		[String[]] $referenceFiles,
		[String[]] $localizableFiles,
		[String[]] $mergeFiles,
		[String] $mergeFileName,
		[String] $mergeFilePathInFolder,
		[String] $pathToPerfectMatch,
		[string[]] $pathToTms,
		[String[]] $pathToTermbases,
		[String] $projectReference = $(Get-DefaultProjectTemplate),
		[String] $projectDueDate,
		[String] $projectDescription,
		[String] $taskSequenceName = "Prepare Without Project TM",
		[String[]] $customTasks = $null)
	
	# Validate the parameters for project creation.
	if ($(Test-CanCreateProject $projectDestination $sourceLanguage $targetLanguages $sourceFilesFolder $referenceFiles $localizableFiles) -eq $false)
	{
		return;
	}

	#create project info object
	$projectInfo = New-ProjectInfo -Name $projectName -description $projectDescription -dueDate $projectDueDate -sourceLanguage $sourceLanguage -targetLanguages $targetLanguages -localProjectFolder $projectDestination
	
	#create file based project object
	$fileBasedProject = Get-ProjectObject $projectInfo $projectReference;

	$null = Add-Providers $fileBasedProject $projectReference 

	$projectInfo = $fileBasedProject.GetProjectInfo();
	$targetLanguages = $projectInfo.TargetLanguages;

    # Adds the files to the proejct
	$projectFiles = $fileBasedProject.AddFolderWithFiles($sourceFilesFolder, $true); # Work here

	#Set the file roles
	Update-FileRoles $fileBasedProject $referenceFiles $localizableFiles $projectInfo

	#Merge files
	Merge-Files $fileBasedProject $mergeFiles $mergeFileName $mergeFilePathInFolder $projectInfo

	# Add simple filebased translation memories
	Add-FileBasedTMS $fileBasedProject $pathToTms

	# Add FileBased Termbases
	Add-Termbases $fileBasedProject $pathToTermbases

	# Add files for perfect match
	Add-FilesForPerfectMatch $fileBasedProject $projectInfo $projectFiles $pathToPerfectMatch;

	# Run Project Tasks
	Confirm-ProjectTasks $fileBasedProject $targetLanguages $taskSequenceName $customTasks

	#save whole project
	$fileBasedProject.Save(); 
}

<#
    .SYNOPSIS
    Opens a project located at the specified path.

    .DESCRIPTION
    The Get-Project function opens a file-based project from the given directory path. It searches for the project file within the specified path and returns the project object.

    .PARAMETER projectDestinationPath
    Specifies the directory path where the file-based project's directory is located.

    .EXAMPLE
    Get-Project -projectDestinationPath "D:\Path\To\Project"
    Opens the project located at "D:\Path\To\Project" and returns the project object.

	.OUTPUTS
	[Sdl.ProjectAutomation.FileBased.FileBasedProject]
	Returns a filebasedproject instance representing the provided project or $null if no project was found.
#>
function Get-Project
{
	param(		
		[Parameter(Mandatory=$true)]
		[String] $projectDestinationPath)

	# Checks if the provided path is a directory/folder
	if ($(Test-Path -Path $projectDestinationPath -PathType Container) -eq $false) {
        Write-Output "The path must be an existing directory."
        return;
    }

    $projectFilePath = Get-ChildItem $projectDestinationPath -Filter *.sdlproj -Recurse | ForEach-Object { $_.FullName };

	# Checks if the provided path contains any file based project.
	if ($null -eq $projectFilePath)
	{
		Write-Host "The provided folder does not contain an existing project";
		return;
	}

	return New-Object Sdl.ProjectAutomation.FileBased.FileBasedProject($projectFilePath.ToString());
}

<#
    .SYNOPSIS
    Gets the given file based project's statistics.

    .DESCRIPTION
    Gets the following statistics from the provided project:
    - Exact Matches (characters)
    - Exact Matches (words)
    - New Matches (characters)
    - New Matches (words)
    - New Matches (segments)
    - New Matches (placeable)
    - New Matches (tags)

    .PARAMETER project
    Represents the existing file-based project. This parameter can be retrieved from the Get-Project function.

    For further documentation:
    Get-Help Get-Project

    .EXAMPLE
    Get-AnalyzeStatistics -project ([Sdl.ProjectAutomation.FileBased.FileBasedProject] $existingProject)
    Retrieves and displays the analysis statistics for the specified project.
#>
function Get-AnalyzeStatistics
{
	param(
		[Parameter(Mandatory=$true)]
		[Sdl.ProjectAutomation.FileBased.FileBasedProject] $project)
	
	$projectStatistics = $project.GetProjectStatistics();
	
	$targetLanguagesStatistics = $projectStatistics.TargetLanguageStatistics;
	
	foreach($targetLanguageStatistic in  $targetLanguagesStatistics)
	{
		Write-Host ("Exact Matches (characters): " + $targetLanguageStatistic.AnalysisStatistics.Exact.Characters);
		Write-Host ("Exact Matches (words): " + $targetLanguageStatistic.AnalysisStatistics.Exact.Words);
		Write-Host ("New Matches (characters): " + $targetLanguageStatistic.AnalysisStatistics.New.Characters);
		Write-Host ("New Matches (words): " + $targetLanguageStatistic.AnalysisStatistics.New.Words);
		Write-Host ("New Matches (segments): " + $targetLanguageStatistic.AnalysisStatistics.New.Segments);
		Write-Host ("New Matches (placeables): " + $targetLanguageStatistic.AnalysisStatistics.New.Placeables);
		Write-Host ("New Matches (tags): " + $targetLanguageStatistic.AnalysisStatistics.New.Tags);
	}
}

function Confirm-Task
{
	param ([Sdl.ProjectAutomation.Core.AutomaticTask] $taskToValidate)

	if($taskToValidate.Status -eq [Sdl.ProjectAutomation.Core.TaskStatus]::Failed)
	{
		Write-Host "Task "$taskToValidate.Name"was not completed.";  
		foreach($message in $taskToValidate.Messages)
		{
			Write-Host $message.Message -ForegroundColor red ;
		}
	}
	if($taskToValidate.Status -eq [Sdl.ProjectAutomation.Core.TaskStatus]::Invalid)
	{
		Write-Host "Task "$taskToValidate.Name"was not completed.";  
		foreach($message in $taskToValidate.Messages)
		{
			Write-Host $message.Message -ForegroundColor red ;
		}
	}
	if($taskToValidate.Status -eq [Sdl.ProjectAutomation.Core.TaskStatus]::Rejected)
	{
		Write-Host "Task "$taskToValidate.Name"was not completed.";  
		foreach($message in $taskToValidate.Messages)
		{
			Write-Host $message.Message -ForegroundColor red ;
		}
	}
	if($taskToValidate.Status -eq [Sdl.ProjectAutomation.Core.TaskStatus]::Cancelled)
	{
		Write-Host "Task "$taskToValidate.Name"was not completed.";  
		foreach($message in $taskToValidate.Messages)
		{
			Write-Host $message.Message -ForegroundColor red ;
		}
	}
	if($taskToValidate.Status -eq [Sdl.ProjectAutomation.Core.TaskStatus]::Completed)
	{
		Write-Host "Task "$taskToValidate.Name"was completed." -ForegroundColor green;  
	}
}

function New-ProjectInfo 
{
	param (
		[String] $name,
		[String] $description,
		[String] $dueDate,
		[String] $localProjectFolder,		
		[String] $sourceLanguage, 
		[String[]] $targetLanguages
	)

	$projectInfo = New-Object Sdl.ProjectAutomation.Core.ProjectInfo;
	$projectInfo.Name = $name;
	$projectInfo.Description = $description;
	$projectInfo.LocalProjectFolder = $localProjectFolder ;
	if ($sourceLanguage -ne "")
	{
		$projectInfo.SourceLanguage = Get-Language $sourceLanguage;
	}
	if ($null -ne $targetLanguages)
	{
		[Sdl.Core.Globalization.Language[]] $targetLanguages = Get-Languages $targetLanguages;
		$projectInfo.TargetLanguages = $targetLanguages;
	}

	$validDate = Convert-StringToDateTime $dueDate;
	if ($validDate)
	{
		$projectInfo.DueDate = $validDate;
	}

	return $projectInfo;
}

function Get-ProjectObject 
{
	param (
		[Sdl.ProjectAutomation.Core.ProjectInfo] $projectInfo,
		[String] $referencePath)

	if ($referencePath.EndsWith(".sdltpl"))
	{
		$referencePath = (Resolve-Path -LiteralPath $referencePath).ProviderPath
		$reference = New-Object Sdl.ProjectAutomation.Core.ProjectTemplateReference ($referencePath);
	}

	if ($referencePath.EndsWith(".sdlproj"))
	{
		$referencePath = (Resolve-Path -LiteralPath $referencePath).ProviderPath
		$reference = New-Object Sdl.ProjectAutomation.Core.ProjectReference ($referencePath);
	}

	if ($null -eq $reference)
	{
		Write-Host "Reference path invalid" -ForegroundColor Red
		try 
		{
			return New-Object Sdl.ProjectAutomation.FileBased.FileBasedProject ($projectInfo);
		}
		catch 
		{
			Write-Host "Project does not have valid source and\or target language" -ForegroundColor Green;
		}
	}

	try {
		return New-Object Sdl.ProjectAutomation.FileBased.FileBasedProject ($projectInfo, $reference)
	}
	catch 
	{
		Write-Host "Project does not have valid source and\or target language" -ForegroundColor Green;
	}
}

function Convert-StringToDateTime {
    param (
        [string]$dateString
    )

	try {
		return [datetime] $dateString;
	}
	catch 
	{
		return $null;
	}
}

function Update-FilesRole 
{
	param (
		[SDL.ProjectAutomation.FileBased.FileBasedProject] $project,
		[guid[]] $guids,
		[SDL.ProjectAutomation.Core.FileRole] $newRole
	)

	if ($guids)
	{
		$project.SetFileRole($guids, $newRole) 
	}
}

function Update-FileRoles 
{
	param (
		[SDL.ProjectAutomation.FileBased.FileBasedProject] $project,
		[String[]] $referenceFiles,
		[String[]] $localizableFiles,
		[Sdl.ProjectAutomation.Core.ProjectInfo] $projectInfo
	)
	
	$projectFiles = $project.GetSourceLanguageFiles();

	# Change given files to reference files if referenceFiles exists
	if ($referenceFiles)
	{
		$references = $projectFiles | Where-Object { $_.Name -in $referenceFiles}
		$guids = Get-Guids $references;
		$roleEnum = [Sdl.ProjectAutomation.Core.FileRole]::Reference

		Update-FilesRole $fileBasedProject $guids $roleEnum
	}

	# Change the given files to localizable if localizableFiles exists
	if ($localizableFiles)
	{
		$localizables = $projectFiles | Where-Object { $_.Name -in $localizableFiles }
		$localizableGuids = Get-Guids $localizables
		$roleEnum = [Sdl.ProjectAutomation.Core.FileRole]::Localizable
		Update-FilesRole $fileBasedProject $localizableGuids $roleEnum
	}
}

function Merge-Files 
{
	param (
		[SDL.ProjectAutomation.FileBased.FileBasedProject] $project,
		[String[]] $mergeFiles,
		[String] $mergeFileName,
		[String] $mergeFilePathInFolder,
		[Sdl.ProjectAutomation.Core.ProjectInfo] $projectInfo
 	)

	$projectFiles = $project.GetSourceLanguageFiles();
	$fileExtension = ".sdlxliff"

	if ($mergeFileName.EndsWith($fileExtension) -eq $false)
	{
		$mergeFileName += $fileExtension
	}

	if ($mergeFiles -and $mergeFileName)
	 {
		$merges = $projectFiles | Where-Object { $_.Name -in $mergeFiles }
		$mergeGuids = Get-Guids $merges;
		$translatableEnum = [Sdl.ProjectAutomation.Core.FileRole]::Translatable
		Update-FilesRole $fileBasedProject $mergeGuids $translatableEnum
		$mergedFileResult = $fileBasedProject.CreateMergedProjectFile($mergeFileName, $mergeFilePathInFolder, $mergeGuids)

		$fileTypeManager = [Sdl.FileTypeSupport.Framework.Core.Utilities.IntegrationApi.DefaultFileTypeManager]::CreateInstance($true)
		$fileTypeManager.SettingsBundle = $fileBasedProject.GetSettings() 
		
		$filesPaths = $mergedFileResult.ChildFiles | ForEach-Object { $_.LocalFilePath }

		$converter = $fileTypeManager.GetConverterToDefaultBilingual($filesPaths, $mergedFileResult.LocalFilePath, $projectInfo.SourceLanguage.CultureInfo, $null, $null);
		$converter.Parse()

		$fileBasedProject.AddNewFileVersion($mergedFileResult.Id, $mergedFileResult.LocalFilePath)
	 }
}

function Add-FileBasedTMS 
{
	param (
		[SDL.ProjectAutomation.FileBased.FileBasedProject] $project,
		[String[]] $tmPaths
	)	

	if ($null -eq $tmPaths)
	{
		return;
	}

	foreach ($tm in $tmPaths)
	{
		$filebasedtm = Open-FileBasedTM $tm
		if ($filebasedtm)
		{
			$tmConfig = $project.GetTranslationProviderConfiguration()	
			$entry = New-Object Sdl.ProjectAutomation.Core.TranslationProviderCascadeEntry ($tm, $true, $true, $true)
			
			$tmConfig.Entries.Add($entry)
			$tmConfig.OverrideParent = $true

			$project.UpdateTranslationProviderConfiguration($tmConfig)
		}
	}
}

function Add-Termbases {
	param (
		[SDL.ProjectAutomation.FileBased.FileBasedProject] $project,
		[String[]] $pathToTermbases
	)

	if ($pathToTermbases)
	{
		$termbasesConfig = $project.GetTermbaseConfiguration()
		foreach ($path in $pathToTermbases)
		{
			$tb = New-Object Sdl.ProjectAutomation.Core.LocalTermbase($path)
			$termbasesConfig.Termbases.Add($tb);
		}
	
		$project.UpdateTermbaseConfiguration($termbasesConfig);
	}
}

function Get-BilingualFileMappings {
	param (
		[Sdl.Core.Globalization.Language[]] $LanguagesList,
		[Sdl.ProjectAutomation.Core.ProjectFile[]] $TranslatableFilesList,
		[String] $BilingualsPath
	)

	[Sdl.ProjectAutomation.Core.BilingualFileMapping[]] $mappings = @()
	ForEach ($Language in $LanguagesList) {
		Write-Host "Processing $Language" -ForegroundColor Yellow
		$BilingualsCount = 0
		$SearchPath = Join-Path -Path $BilingualsPath -ChildPath $Language.IsoAbbreviation
		foreach ($file in $TranslatableFilesList) {
			if ($file.Name.EndsWith(".sdlxliff")) {
				$suffix = ""
			}
			else {
				$suffix = ".sdlxliff"
			}
			$BilingualFile = $(Join-Path -Path $SearchPath -ChildPath $file.Folder | Join-Path -ChildPath $file.Name) + $suffix
			if (Test-Path $BilingualFile) {
				$mapping = New-Object Sdl.ProjectAutomation.Core.BilingualFileMapping
				$mapping.BilingualFilePath = $BilingualFile
				$mapping.Language = $Language
				$mapping.FileId = $file.Id
				$mappings += $mapping
				$BilingualsCount += 1
			}
		}

 		Write-Host "Assigned $BilingualsCount of $($TranslatableFilesList.Count) files"
	}

	return $mappings | Where-Object { $null -ne $_ }
}

function Add-FilesForPerfectMatch 
{
	param (
		[SDL.ProjectAutomation.FileBased.FileBasedProject] $project,
		[Sdl.ProjectAutomation.Core.ProjectInfo] $projectInfo,
		[Sdl.ProjectAutomation.Core.ProjectFile[]] $projectFiles,
		[String] $pathToPerfectMatch
	)

	if ($pathToPerfectMatch)
	{
		$BilingualsPath = (Resolve-Path -LiteralPath $pathToPerfectMatch).ProviderPath
		Write-Host "`nAssigning bilingual files for PerfectMatch..." -ForegroundColor White
		$BilingualFileMappings = Get-BilingualFileMappings -LanguagesList $projectInfo.TargetLanguages -TranslatableFilesList $ProjectFiles -BilingualsPath $BilingualsPath
		if ($BilingualFileMappings)
		{
			$project.AddBilingualReferenceFiles($BilingualFileMappings)
		}

		Write-Host "Done"
	}
}

$taskConstants = @{
	Scan = "Sdl.ProjectApi.AutomaticTasks.Scan"
	Conversion = "Sdl.ProjectApi.AutomaticTasks.Conversion"
	Split = "Sdl.ProjectApi.AutomaticTasks.Split"
	PerfectMatch = "Sdl.ProjectApi.AutomaticTasks.PerfectMatch"
	Analysis = "Sdl.ProjectApi.AutomaticTasks.Analysis"
	Translate = "Sdl.ProjectApi.AutomaticTasks.Translate"
	GenerateTargetTranslation = "Sdl.ProjectApi.AutomaticTasks.GenerateTargetTranslation"
	ExportFiles = "Sdl.ProjectApi.AutomaticTasks.GenerateTargetTranslation.ExportFiles"
	GenerateTargetFileLC = "Sdl.ProjectApi.AutomaticTasks.GenerateTargetFileLC"
	Feedback = "Sdl.ProjectApi.AutomaticTasks.Feedback"
	WordCount = "Sdl.ProjectApi.AutomaticTasks.WordCount"
	TranslationCount = "Sdl.ProjectApi.AutomaticTasks.TranslationCount"
	UpdateProjectTm = "Sdl.ProjectApi.AutomaticTasks.UpdateProjectTm"
	UpdateMasterTm = "Sdl.ProjectApi.AutomaticTasks.UpdateMasterTm"
	Verification = "Sdl.ProjectApi.AutomaticTasks.Verification"
	PseudoTranslate = "Sdl.ProjectApi.AutomaticTasks.PseudoTranslate"
	ExportToBilingualFile = "Sdl.ProjectApi.AutomaticTasks.ExportForReview"
	UpdateFromBilingualFile = "Sdl.ProjectApi.AutomaticTasks.ImportFromReview"
	Retrofit = "Sdl.ProjectApi.AutomaticTasks.Retrofit"
	TranslateAndAnalysis = "Sdl.ProjectApi.AutomaticTasks.TranslateAndAnalysis"
}

function Confirm-ProjectTasks
{
	param (
		[SDL.ProjectAutomation.FileBased.FileBasedProject] $project,
		[String[]] $targetLanguages,
		[String] $taskSequenceName,
		[String[]] $taskNames
	)

	$sourceFiles = $project.GetSourceLanguageFiles()
	$sourceGuids = Get-Guids $sourceFiles

	if ($taskNames)
	{
		$tasks = Get-TasksDefinitions $taskNames
	}
	else 
	{
		$tasks = Get-TaskSequence $taskSequenceName
	}

	if ($null -eq $tasks)
	{
		return $null;
	}

	foreach ($task in $tasks)
	{
		if (Test-TaskForTarget $task)
		{
			foreach ($targetLanguage in $targetLanguages)
			{
				$targetFiles = $project.GetTargetLanguageFiles($targetLanguage);
				$targetGuids = Get-Guids $targetFiles
				Confirm-Task $project.RunAutomaticTask($targetGuids, $task)
			}
		}
		else 
		{
			Confirm-Task $project.RunAutomaticTask($sourceGuids, $task)
		}
	}
}

function Get-TaskSequence # predefined Task Sequences
{
	param ([String] $name)

	$tasks = @(
		$taskConstants.Scan
		$taskConstants.Conversion
		$taskConstants.Split
	)

	switch ($name) {
		"Prepare without project TM" { 
			$tasks += $taskConstants.PerfectMatch
			$tasks += $taskConstants.Analysis
			$tasks += $taskConstants.Translate
		 }

		"Prepare" {
			$tasks += $taskConstants.PerfectMatch
			$tasks += $taskConstants.Analysis
			$tasks += $taskConstants.Translate
			$tasks += $taskConstants.UpdateProjectTm
		}

		"Analyze Only" {
			$tasks += $taskConstants.Analysis
			$tasks += $taskConstants.UpdateProjectTm
			$tasks += $taskConstants.TranslationCount
		}

		"Pseudo-Translate Round Trip" {
			$tasks += $taskConstants.PseudoTranslate
			$tasks += $taskConstants.GenerateTargetTranslation
		}

		Default {
			return $null
		}
	}

	return $tasks;
}

function Get-TasksDefinitions 
{
	
	param ([String[]] $taskNames)
	
	$taskNames = $taskNames | Where-Object {$_ -ne "Scan"}
	$tasks = @([Sdl.ProjectApi.AutomaticTaskIds]::Scan);
	foreach ($task in $taskNames)
	{
		try {
			$tasks += $taskConstants.$task 
		}
		catch
		{
			return $null;
		}
	}

	return $tasks;
}

function Test-TaskForTarget
{
	param (
		[String] $task
	)

	$targetTasks = @(
		$taskConstants.GenerateTargetTranslation,
		$taskConstants.ExportFiles,
		$taskConstants.Verification,
		$taskConstants.PseudoTranslate,
		$taskConstants.Translate,
		$taskConstants.PerfectMatch,
		$taskConstants.Analysis,
		$taskConstants.UpdateProjectTm,
		$taskConstants.UpdateMasterTm,
		$taskConstants.WordCount,
		$taskConstants.TranslationCount)

	return $task -in $targetTasks;
}

$StudioVersionsMap = @{
	Studio17 = "Studio17"
	Studio18 = "Studio18"
}

function Get-DefaultProjectTemplate {
	$StudioVersionAppData = $StudioVersionsMap[$StudioVersion]

	[DependencyResolver.ReflectionHelper]::CallEnsurePluginRegistryIsCreated([Sdl.ProjectAutomation.FileBased.FileBasedProject])
	$UserSettingsFilePath = "${Env:AppData}\Trados\Trados Studio\$StudioVersionAppData\UserSettings.xml"
	$DefaultProjectTemplateGuid = (Select-Xml -Path $UserSettingsFilePath -XPath "//Setting[@Id='DefaultProjectTemplateGuid']").Node.InnerText
	$application = [Sdl.ProjectApi.ApplicationFactory]::CreateApplication();
	$provider = $application.AllProjectsProviders[0]
	$projectTemplates = $application.GetProjectsProvider($provider, $null).ProjectTemplates
	$DefaultProjectTemplate = ($ProjectTemplates | Where-Object -Property Guid -eq $DefaultProjectTemplateGuid).FilePath
	return $DefaultProjectTemplate
}

function Test-CanCreateProject {
	param (
		[String] $projectPath,
		[String] $sourceLanguage,
		[String[]] $targetLanguages,
		[String] $sourceFilesPath,
		[String[]] $referenceFiles,
		[String[]] $localizableFiles
	)

	if (Test-Path $projectPath) 
	{
		$items = Get-ChildItem -Path $projectPath

		if ($items) 
		{
			Write-Host "The path should be an empty directory" -ForegroundColor Green
			return $false;
		} 
	}

	if ($sourceLanguage -ne "")
	{
		if ($null -eq $(Get-Language $sourceLanguage))
		{
			Write-Host "Invalid source language" -ForegroundColor Green;
			return $false;
		}
	}

	if ($targetLanguages)
	{
		if ($targetLanguages -eq "")
		{
			Write-Host "Invalid target languages" -ForegroundColor Green;
			return $false;
		}

		if ($targetLanguages.IndexOf("") -ge 0)
		{
			Write-Host "Invalid target languages" -ForegroundColor Green;
			return $false;
		}

		if ($null -eq $(Get-Languages $targetLanguages))
		{
			Write-Host "Invalid target languages" -ForegroundColor Green;
			return $false;
		}
	}

	if (-Not (Test-Path -Path $sourceFilesPath -PathType Container)) {
        Write-Host "The source folder should be an existing directory" -ForegroundColor Green
        return $false
    }

	$files = Get-ChildItem -Path $sourceFilesPath -Recurse -File
	if ($files.Count -eq 0) {
        Write-Host "The source folder should contain at least one file." -ForegroundColor Green
        return $false
	}

	$fileNames = $files | ForEach-Object { $_.Name }
	$nonTranslatableFiles = @($referenceFiles | Where-Object {$_ -in $fileNames})
	$nonTranslatableFiles += $($localizableFiles | Where-Object {$_ -in $fileNames})
	$nonTranslatableFiles = $nonTranslatableFiles | Sort-Object -Unique
	if ($nonTranslatableFiles.Count -eq $files.Count)
	{
		Write-Host "Project should contain at least one translatable or localizable file" -ForegroundColor Green
		return $false;
	}

	return $true;
}

function Add-Providers {
	param (
		[SDL.ProjectAutomation.FileBased.FileBasedProject] $project,
		[string] $referencePath
	)

	[Xml] $xmlDoc  = Get-Content -Path $referencePath;
	$translationProviderItems = $xmlDoc.SelectNodes("//MainTranslationProviderItem")

	# Loop through each provider and check the schema
    foreach ($provider in $translationProviderItems) {
        # Get the URI of the provider
        $uri = $provider.Uri.ToString()
		$credential = $null;

        # Check the URI schema and call the appropriate method
        switch -regex ($uri) {
            "^languageweaveredge:///" {
                $credential = Get-LanguageWeaverEdge
                break
            }
            "^languageweavercloud:///" {
                $credential = Get-LanguageWeaverCloud
                break
            }
            "^amazontranslateprovider:///" {
                $credential = Get-AmazonProvider
                break
            }
            "^deepltranslationprovider:///" {
                $credential = Get-DeepL
                break
            }
			"^googletranslationprovider:///" {
				$credential = Get-GoogleProvider
				break
			}
			"^microsofttranslatorprovider:///" {
				$credential = Get-MicrosoftProvider;
				break;
			}
            default {
				break
            }
        }

		if ($null -ne $credential)
		{
			Add-ProjectCredential $fileBasedProject $credential;
		}
    }
}

function Add-ProjectCredential {
	param (
		[SDL.ProjectAutomation.FileBased.FileBasedProject] $project,
		[psobject] $credential
	)

	if ([string]::IsNullOrEmpty($credential.Uri)){
		return;
	}

	if ($credential.ClientID -and $credential.ClientSecret)
	{
		$project.Credentials.AddCredential([System.Uri]::New($credential.Uri), $false, $credential.ClientID, $credential.ClientSecret);
	}
	elseif ($credential.ClientID)
	{
		$project.Credentials.AddCredential([System.Uri]::New($credential.Uri), [System.String]::New($credential.ClientID));
	}
}


function Get-LanguageWeaverEdge
{
    $credentials = Get-MTCredential LanguageWeaverEdge;
    if ($null -eq $credentials)
    {
        return;
    }

    $json = @{
        AccountRegion = $credentials.AccountRegion
        Host = $credentials.Host
        ApiKey = $credentials.ApiKey
    } | ConvertTo-Json -Depth 2;

    return @{
        Uri = $credentials.Uri
        ClientId = $json
    }
}

function Get-MicrosoftProvider {
    $credentials = Get-MTCredential Microsoft;
    $json = @{
        ApiKey = $credentials.ApiKey
        Region = $credentials.Region 
    } | ConvertTo-Json -Depth 2;

    return @{
        Uri = $credentials.Uri
        ClientId = $json }
}

function Get-GoogleProvider {
    $credentials = Get-MTCredential Google;
    
    return @{
        Uri = $credentials.Uri
        ClientId = $credentials.ApiKey
    }
}

function Get-LanguageWeaverCloud {
    
    $credentials = Get-MTCredential LanguageWeaverCloud
    if ($null -eq $credentials)
    {
        return;
    }

    $json = @{
        AccountRegion = $credentials.AccountRegion
        ClientID = $credentials.ClientId
        ClientSecret = $credentials.ClientSecret
    } | ConvertTo-Json -Depth 2;
    
    return @{
        Uri = $credentials.Uri
        ClientId = $json;
    }
}

function Get-AmazonProvider {
    $credentials = Get-MTCredential Amazon
    if ($null -eq $credentials)
    {
        return;
    }

    return @{ 
        Uri = $credentials.Uri
        ClientID = $credentials.ClientId
        ClientSecret = $credentials.ClientSecret
    }
}

function Get-DeepL {
    $credentials = Get-MTCredential DeepL
    if ($null -eq $credentials)
    {
        return;
    }

    return @{
        Uri = $credentials.Uri
        ClientId = $credentials.ApiKey
    }
}

Export-ModuleMember Remove-Project;
Export-ModuleMember New-Project;
Export-ModuleMember Get-Project;
Export-ModuleMember Get-AnalyzeStatistics;
Export-ModuleMember Get-TaskFileInfoFiles;
Export-ModuleMember Get-ProjectTargetLanguages;