param ([String] $studioVersion)

<#
	.SYNOPSIS
	Creates a new package based on an existing filebased project.

	.DESCRIPTION
	Creates a package from the given filebased project based upon the provided target language.

	.PARAMETER language
	Represents the target language from the project to be used for creating the package.

	Can be retrieved from
		Get-Language
		Get-Languages

	For further documentation:
		Get-Help Get-Language
		Get-Help Get-Languages

	.PARAMETER packagePath
	Represents the location where the package should be saved at.

	.PARAMETER projectToProcess
	The Existing filebased project to create the package from.

	Can be retrieved from
		Get-Project
		
	For further documentation:
		Get-Help Get-Project

	.EXAMPLE
	Export-Package -language ([Sdl.Core.Globalization.Language] $targetLanguage) -packagePath ("C\Path\To\Package\test.sdlppx")
		-projectToProcess ([Sdl.ProjectAutomation.FileBased.FileBasedProject] $project)

	.EXAMPLE
	Export-Package -language ([Sdl.Core.Globalization.Language] $targetLanguage) -packagePath ("C\Path\To\Package\test")
	-projectToProcess ([Sdl.ProjectAutomation.FileBased.FileBasedProject] $project)

	If the packagePath does not contain the right extension, the path will be changed with the correct extension.
#>
function Export-Package
{
	param(
		[Parameter(Mandatory=$true)]
		[Sdl.Core.Globalization.Language] $language,

		[Parameter(Mandatory=$true)]
		[String] $packagePath,

		[Parameter(Mandatory=$true)]
		[Sdl.ProjectAutomation.FileBased.FileBasedProject] $projectToProcess)
	
	$today = Get-Date;
	$exportExtension = ".sdlppx";
	$packagePath = Get-PackageExtension $packagePath $exportExtension
	[Sdl.ProjectAutomation.Core.TaskFileInfo[]] $taskFiles =  Get-TaskFileInfoFiles $language $projectToProcess;
	[Sdl.ProjectAutomation.Core.ManualTask] $task = $projectToProcess.CreateManualTask("Translate", "API translator", $today +1 ,$taskFiles);
	[Sdl.ProjectAutomation.Core.ProjectPackageCreationOptions] $packageOptions = Get-PackageOptions
	[Sdl.ProjectAutomation.Core.ProjectPackageCreation] $package = $projectToProcess.CreateProjectPackage($task.Id, "mypackage",
                "A package created by the API", $packageOptions, ${function:Write-PackageProgress}, ${function:Write-PackageMessage}); # Status - Failed -> Repair from here..
	$projectToProcess.SavePackageAs($package.PackageId, $packagePath);
}

<#
	.SYNOPSIS
	Imports a return package into an existing filebased project

	.PARAMETER projectToProcess
	Represents an existing file based project.

	Can be retrieved from
		Get-Project
		
	For further documentation:
		Get-Help Get-Project

	.PARAMETER importPath
	Represents the path to the package that will be used for the import process

	.EXAMPLE
	Import-Package -projectToProcess ([Sdl.ProjectAutomation.FileBased.FileBasedProject] $project) -importPath "D:\Path\To\Import.sdlrpx"

	.EXAMPLE
	Import-Package -projectToProcess ([Sdl.ProjectAutomation.FileBased.FileBasedProject] $project) -importPath "D:\Path\To\Import"

	If the path does not contain the return package extension, the path will be changed to match the return package extension.
#>
function Import-Package 
{
	param(
		[Parameter(Mandatory=$true)]
		[Sdl.ProjectAutomation.FileBased.FileBasedProject] $projectToProcess,

		[Parameter(Mandatory=$true)]
		[String] $importPath
	)

	$importExtension = ".sdlrpx"
	$importPath = Get-PackageExtension $importPath $importExtension;
	$projectToProcess.ImportReturnPackage($importPath, ${function:Write-PackageProgress}, ${function:Write-PackageMessage});
}

function Get-PackageOptions
{
	[Sdl.ProjectAutomation.Core.ProjectPackageCreationOptions] $packageOptions = New-Object Sdl.ProjectAutomation.Core.ProjectPackageCreationOptions;
	$packageOptions.IncludeAutoSuggestDictionaries = $false;
	$packageOptions.IncludeMainTranslationMemories = $false;
    $packageOptions.IncludeTermbases = $false;
    $packageOptions.ProjectTranslationMemoryOptions = [Sdl.ProjectAutomation.Core.ProjectTranslationMemoryPackageOptions]::UseExisting;
    $packageOptions.RecomputeAnalysisStatistics = $false;
    $packageOptions.RemoveAutomatedTranslationProviders = $true;
    return $packageOptions;
}

function Get-PackageExtension
{
	param (
		[String] $path,
		[String] $extension)

	if ($path.EndsWith($extension))
	{
		return $path
	}

	return $path + $extension;
}

function Write-PackageProgress {
	param(
	$Caller,
	$ProgressEventArgs
	)

	$Message = $ProgressEventArgs.StatusMessage

	if ($null -ne $Message -and $Message -ne "") {
		$Percent = $ProgressEventArgs.PercentComplete
		if ($Percent -eq 100) {
			$Message = "Completed"
		}

		# write textual progress percentage in console
		if ($host.name -eq 'ConsoleHost') {
			Write-Host "$($Percent.ToString().PadLeft(5))%	$Message"
			Start-Sleep -Seconds 1
		}
		# use PowerShell progress bar in PowerShell environment since it does not support writing on the same line using `r
		else {
			Write-Progress -Activity "Processing task" -PercentComplete $Percent -Status $Message
			# when all is done, remove the progress bar
			if ($Percent -eq 100 -and $Message -eq "Completed") {
				Write-Progress -Activity "Processing task" -Completed
			}
		}
	}
}

function Write-PackageMessage {
	param(
	$Caller,
	$MessageEventArgs
	)

	$Message = $MessageEventArgs.Message

	if ($Message.Source -ne "Package import") {
		Write-Host "$($Message.Source)" -ForegroundColor DarkYellow
	}
	Write-Host "$($Message.Level): $($Message.Message)" -ForegroundColor Magenta
	if ($Message.Exception) {
		Write-Host "$($Message.Exception)" -ForegroundColor Magenta
	}
}

Export-ModuleMember Export-Package;
Export-ModuleMember Import-Package;