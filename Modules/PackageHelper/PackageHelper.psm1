param ([String] $studioVersion)

<#
    .SYNOPSIS
    Creates a new package based on an existing file-based project.

    .DESCRIPTION
    Creates a package from the provided file-based project using the specified target language. The package is saved at the location provided in the `packagePath` parameter. The path will be adjusted to include the correct file extension if it is not already specified.

    .PARAMETER language
    Represents the target language from the project to be used for creating the package. This parameter can be retrieved from the `Get-Language` or `Get-Languages` functions.

    For further documentation:
    Get-Help Get-Language
    Get-Help Get-Languages

    .PARAMETER packagePath
    Represents the location where the package should be saved. If the path does not have the correct extension, it will be adjusted to include the `.sdlppx` extension.

    .PARAMETER projectToProcess
    The existing file-based project to create the package from. This parameter can be retrieved from the `Get-Project` function.

    For further documentation:
    Get-Help Get-Project

    .EXAMPLE
    Export-Package -language ([Sdl.Core.Globalization.Language] $targetLanguage) `
        -packagePath ("C:\Path\To\Package\test.sdlppx") `
        -projectToProcess ([Sdl.ProjectAutomation.FileBased.FileBasedProject] $project)
    
    Creates a package from the specified file-based project for the target language and saves it to the specified path with the `.sdlppx` extension.

    .EXAMPLE
    Export-Package -language ([Sdl.Core.Globalization.Language] $targetLanguage) `
        -packagePath ("C:\Path\To\Package\test") `
        -projectToProcess ([Sdl.ProjectAutomation.FileBased.FileBasedProject] $project)
    
    Creates a package from the specified file-based project for the target language. If the provided `packagePath` does not end with `.sdlppx`, the function will automatically add the correct extension.

	.NOTES
	If the path provided is an existing file, this function will override it.
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


	# Validates the file extension if not provided
	$exportExtension = ".sdlppx";
	$packagePath = Get-PackageExtension $packagePath $exportExtension

	# Creates the export parameters
	$today = Get-Date;
	[Sdl.ProjectAutomation.Core.TaskFileInfo[]] $taskFiles =  Get-TaskFileInfoFiles $language $projectToProcess;
	if ($null -eq $taskFiles)
	{
		return;
	}

	[Sdl.ProjectAutomation.Core.ManualTask] $task = $projectToProcess.CreateManualTask("Translate", "API translator", $today +1 ,$taskFiles);
	[Sdl.ProjectAutomation.Core.ProjectPackageCreationOptions] $packageOptions = Get-PackageOptions
	[Sdl.ProjectAutomation.Core.ProjectPackageCreation] $package = $projectToProcess.CreateProjectPackage($task.Id, "mypackage",
	"A package created by the API", $packageOptions, ${function:Write-PackageProgress}, ${function:Write-PackageMessage});

	# Creates the export package
	$projectToProcess.SavePackageAs($package.PackageId, $packagePath);
}

<#
    .SYNOPSIS
    Imports a return package into an existing file-based project.

    .DESCRIPTION
    Imports a package from the specified path into the provided file-based project. If the `importPath` does not include the correct return package extension (`.sdlrpx`), the function will automatically adjust the path to include this extension.

    .PARAMETER projectToProcess
    Represents the existing file-based project into which the return package will be imported. This parameter can be retrieved from the `Get-Project` function.

    For further documentation:
    Get-Help Get-Project

    .PARAMETER importPath
    Represents the path to the return package that will be used for the import process. If this path does not contain the `.sdlrpx` extension, it will be updated to include it.

    .EXAMPLE
    Import-Package -projectToProcess ([Sdl.ProjectAutomation.FileBased.FileBasedProject] $project) `
        -importPath "D:\Path\To\Import.sdlrpx"
    
    Imports the return package located at `"D:\Path\To\Import.sdlrpx"` into the specified file-based project.

    .EXAMPLE
    Import-Package -projectToProcess ([Sdl.ProjectAutomation.FileBased.FileBasedProject] $project) `
        -importPath "D:\Path\To\Import"
    
    Imports the return package located at `"D:\Path\To\Import"` into the specified file-based project. The function will automatically append the `.sdlrpx` extension to the path if it is not present.
#>
function Import-Package 
{
	param(
		[Parameter(Mandatory=$true)]
		[Sdl.ProjectAutomation.FileBased.FileBasedProject] $projectToProcess,

		[Parameter(Mandatory=$true)]
		[String] $importPath
	)

	# Apply import package extension if not provided
	$importExtension = ".sdlrpx"
	$importPath = Get-PackageExtension $importPath $importExtension;

	# Checks the existence of the file
	if ($(Test-Path -Path $importPath -PathType Leaf) -eq $false)
	{
		Write-Host "File does not exist"
		return;
	}

	# Imports the return package
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