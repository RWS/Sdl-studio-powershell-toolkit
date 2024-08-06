<#
.SYNOPSIS
Creates an instance of the CredentialStore class with server connection details.

.DESCRIPTION
The `Get-ProjectServer` function initializes a `CredentialStore` object with the server address, username, and password provided. This class is used to store and manage connection credentials for interacting with project servers.

.PARAMETER serverAddress
The URI of the server to connect to. This should be a valid URL pointing to the project server.

.PARAMETER userName
The username for authentication on the server. This is required to access the server.

.PARAMETER password
The password associated with the provided username. This is required for authentication.

.EXAMPLE
$projectServer = Get-ProjectServer -serverAddress "https://example.com" -userName "admin" -password "securepassword"

This example creates a `CredentialStore` object with the server address `https://example.com`, the username `admin`, and the password `securepassword`. The resulting `$projectServer` object can then be used to interact with the server in other functions.

.OUTPUTS
[CredentialStore]
Returns the CredentialStore objects which will be used for connecting the the proeject server.
#>
function Get-ProjectServer 
{
    param(
        [Parameter(Mandatory=$true)]
        [String] $serverAddress,

        [Parameter(Mandatory=$true)]
        [String] $userName,
        
        [Parameter(Mandatory=$true)]
        [String] $password)

    return New-Object DependencyResolver.CredentialStore($serverAddress, $userName, $password);
}

<#
.SYNOPSIS
Retrieves all projects from the specified organization and its suborganizations.

.DESCRIPTION
The `Show-ServerbasedProjects` function connects to a server using provided credentials and retrieves a list of all projects from a specified organization. Optionally, it can include projects from suborganizations.

.PARAMETER server
An instance of the `CredentialStore` class containing the server URI, username, and password used for authentication.

.PARAMETER organizationPath
(Optional)Represents the organization path as a string. If this value is not provided the function will return the info for all the projects.

.PARAMETER includeSubOrganizations
A boolean value indicating whether to include projects from suborganizations. By default, this is set to `false`.

.EXAMPLE
$credential = Get-ProjectServer -serverAddress "https://example.com" -userName "admin" -password "securepassword"
$projects = Show-ServerbasedProjects -server $credential -organizationPath "/" -includeSubOrganizations $true

This example shows how to retrieve all projects from the Root organization and its suborganizations. The `$projects` variable will contain the list of project infos.

.OUTPUTS
[ServerProjectInfo[]]
Returns an array of serverprojectinfo, representing information about the found projects.
#>
function Show-ServerbasedProjects
{
      param(
        [Parameter(Mandatory=$true)]
        [DependencyResolver.CredentialStore] $server,


        [String] $organizationPath = "/",
        [Bool] $includeSubOrganizations = $false)

    try {
        $projectServer = New-Object Sdl.ProjectAutomation.FileBased.ProjectServer(
            $server.ServerUri, $false, $server.UserName, $server.Password);
    
        return $projectServer.GetServerProjects($organizationPath, $includeSubOrganizations, $true);        
    }
    catch 
    {
        Write-Host "Invalid ProjectServer instance" -ForegroundColor Green;
    }
}

<#
.SYNOPSIS
Downloads and copies a server-based project to a specified local folder and all the target and source files

.DESCRIPTION
The `Get-ServerbasedProject` function connects to a server using provided credentials and retrieves a specified project from the server. It then downloads and copies the project to a local folder.

.PARAMETER server
An instance of the `CredentialStore` class containing the server URI, username, and password used for authentication.

.PARAMETER organizationPath
Represents the path location as a string of the project.

.PARAMETER projectName
The name of the project to be downloaded from the server.

.PARAMETER outputProjectFolder
The local directory path where the project will be copied. The project will be saved in this folder with its original name.

.EXAMPLE
$credential = Get-ProjectServer -serverAddress "https://example.com" -userName "admin" -password "securepassword"
$outputFolder = "D:\LocalProjects"
Get-ServerbasedProject -server $credential -organization "/" -projectName "ProjectX" -outputProjectFolder $outputFolder

This example downloads the project named "ProjectX" from the Root organization and copies it to the local folder "D:\LocalProjects".

.OUTPUTS
[FileBasedProject]
Returns the FileBasedPreoject instance representing the downloaded project.
#>
function Get-ServerbasedProject
{
    param (
        [Parameter(Mandatory=$true)]
        [DependencyResolver.CredentialStore] $server,

        [Parameter(Mandatory=$true)]
        [String] $organizationPath,
 
        [Parameter(Mandatory=$true)]
        [String] $projectName,

        [Parameter(Mandatory=$true)]
        [String] $outputProjectFolder
    )

    $projectServer = New-Object Sdl.ProjectAutomation.FileBased.ProjectServer(
        $server.ServerUri, $false, $server.UserName, $server.Password);

    # Validates the ProjectCredential objects
    try 
    {
        $projectInfo = $projectServer.GetServerProject("$organizationPath/$projectName");
    }
    catch 
    {
        Write-Host "Invalid ProjectServer" -ForegroundColor Green;
        return;
    }

    # Validates the Project existence
    if ($null -eq $projectInfo)
    {
        Write-Host "Project does not exist" -ForegroundColor Green;
        return;
    }
    
    
    $outputProjectFolder += "\$($projectInfo.Name)"

    # Validates the provided output folder to be an empty directory or a non-existing one
    if (Test-Path $outputProjectFolder) 
	{
		$items = Get-ChildItem -Path $outputProjectFolder

		if ($items) 
		{
			Write-Host "The path should be an empty directory" -ForegroundColor Green
			return;
		} 
	}

    $project = $ProjectServer.OpenProject($projectInfo.ProjectId, $outputProjectFolder);
    if ($project)
    {
        Write-Host "Downloading the source files..." -ForegroundColor Green
        Get-LatestSourceFiles $project
        Write-Host "Downlloading the target files..." -ForegroundColor Green
        Get-LatestTargetFiles $project
    }
}

<#
.SYNOPSIS
Publishes an existing project to the GroupShare server.

.DESCRIPTION
The `Publish-Project` function takes an instance of an existing project and publishes it to the GroupShare server using provided credentials. The project is uploaded to the specified organization within the server.

.PARAMETER server
An instance of the `CredentialStore` class containing the server URI, username, and password used for authentication.

.PARAMETER project
An instance of the `FileBasedProject` class representing the project to be published. This project should be loaded and ready for publishing.

.PARAMETER organizationPath
Represents the organization path to the project

.EXAMPLE
$credential = Get-ProjectServer -serverAddress "https://example.com" -userName "admin" -password "securepassword"
Publish-Project -server $credential -project $project -organizationPath "/"

This example publishes a local project named "MyProject" to the Root organization on the GroupShare server.
#>
function Publish-Project 
{
    param(
        [Parameter(Mandatory=$true)]
        [DependencyResolver.CredentialStore] $server,

        [Parameter(Mandatory=$true)]
        [Sdl.ProjectAutomation.FileBased.FileBasedProject] $project,

        [Parameter(Mandatory=$true)]
        [String] $organizationPath)

    $null = $project.PublishProject(
        $server.ServerUri, $false, $server.UserName, $server.Password, $organizationPath, {
            param ($obj, $evt)
            Write-Host -NoNewline "`r$($evt.StatusMessage) $($evt.PercentComplete)% complete"

            if ($cancelledByUser) {
                $evt.Cancel = $true
            }
        }); 

        Write-Host $null;
}

<#
.SYNOPSIS
Removes the specified project from the GroupShare server.

.DESCRIPTION
The `UnPublish-Project` function removes a project from the GroupShare server. This action deletes the project from the server, making it no longer available.

.PARAMETER project
An instance of the `FileBasedProject` class representing the project to be removed from the server. This project should be loaded and must exist on the server.

.EXAMPLE
$project = Get-Project -path "D:\LocalProjects\MyProject"
UnPublish-Project -project $project

This example removes the project located at "D:\LocalProjects\MyProject" from the GroupShare server.
#>
function UnPublish-Project
{
    param(
        [Parameter(Mandatory=$true)]
        [Sdl.ProjectAutomation.FileBased.FileBasedProject] $project)

    try {
        $project.DeleteFromServer();
    }
    catch {
        Write-Host "The provided project is not published" -ForegroundColor Green
    }
}

<#
    .SYNOPSIS
    Performs checkout for the provided projects.

    .DESCRIPTION
    This function is doing the checkout for all the files or only for the requested files that are existing in a project.

    .PARAMETER project
    A filebasedproject instance that should represent a file-based project that has been downloaded form the Groupshare server.
    Or published.
    
    .PARAMETER fileType
    Represents the target of the checkout. This value can be one of the following:
    All
    Source
    Target

    .PARAMETER targetLanguageCodes
    Represents one language code that should be used for doing the checkout for the given language codes.
    If the $fileType parameter is Target, this value should be provided if only specific target languages should be checked out,
    otherwise the checkout will be done for all target files.

    .PARAMETER fileNames
    An array of strings representing specific filenames that should be checkeout.

    .EXAMPLE
    $project = Get-Project -Path "C:\Projects\SampleProject"
    Set-CheckOutFiles -project $project -fileType "All"
#>
function Set-CheckOutFiles 
{
    param (
        [Parameter(Mandatory=$true)]
        [Sdl.ProjectAutomation.FileBased.FileBasedProject] $project,

        [String] $fileType = "All", #source,Target, all
        [string[]] $targetLanguageCodes,
        [string[]] $fileNames
    )

    $projectInfo = $project.GetProjectInfo()
    $targetLanguages = $projectInfo.TargetLanguages;

    switch ($fileType) {
        "All" {
            $sourceFiles = $project.GetSourceLanguageFiles()
            if ($fileNames)
            {
                $sourceFiles = $project.GetSourceLanguageFiles() | Where-Object {$_.OriginalName -in $fileNames}
            }
            $sourceGuids = Get-Guids $sourceFiles
            Set-ProjectCheckout $project $sourceGuids

            foreach ($target in $targetLanguages)
            {
                $targetFiles = $project.GetTargetLanguageFiles($target);
                if ($fileNames)
                {
                    $targetFiles = $targetFiles | Where-Object {$_.OriginalName -in $fileNames}
                }

                $targetGuids = Get-Guids $targetFiles
                Set-ProjectCheckout $project $targetGuids;
            }
          }

        "Source" {
            $sourceFiles = $project.GetSourceLanguageFiles()
            if ($fileNames)
            {
                $sourceFiles = $project.GetSourceLanguageFiles() | Where-Object {$_.OriginalName -in $fileNames}
            }
            $sourceGuids = Get-Guids $sourceFiles
            Set-ProjectCheckout $project $sourceGuids
        }

        "Target" {
            if ($targetLanguageCodes)
            {
                $isValid = Get-Languages $targetLanguageCodes
                if ($null -eq $isValid)
                {
                    Write-Host "Invalid Target languages" -ForegroundColor Green;
                    return;
                }

                foreach ($code in $targetLanguageCodes)
                {
                    if ($code -notin $targetLanguages)
                    {
                        Write-Host "Language $code does not exist in the project" -ForegroundColor Green;
                        return;
                    }
                }
            }

            $targetLanguages = $targetLanguageCodes;
            foreach ($target in $targetLanguages)
            {
                $targetFiles = $project.GetTargetLanguageFiles($target);
                if ($fileNames)
                {
                    $targetFiles = $targetFiles | Where-Object {$_.OriginalName -in $fileNames}
                }

                $targetGuids = Get-Guids $targetFiles
                Set-ProjectCheckout $project $targetGuids;
            }
        }
        Default {
            Write-Host "Invalid File Type" -ForegroundColor Green;
            return;
        }
    }
}

<#
    .SYNOPSIS
    Performs the check in for all the files from the project.

    .PARAMETER project
    Represents a filebasedproject instance that should represent a file-based project that has been downloaded form the Groupshare server.
    Or published.

    .EXAMPLE
    $project = Get-Project -Path "C:\Projects\SampleProject"
    Set-CheckInFiles -project $project
#>
function Set-CheckInFiles
{
    param (
        [Parameter(Mandatory=$true)]
        [Sdl.ProjectAutomation.FileBased.FileBasedProject] $project
    )

    $sourceGuids = Get-Guids $project.GetSourceLanguageFiles()
    $project.CheckinFiles($sourceGuids, $null, $null)
    $projectInfo = $project.GetProjectInfo()
    $targetLanguages = $projectInfo.TargetLanguages;
    foreach ($target in $targetLanguages)
    {
        $targetGuids = Get-Guids $project.GetTargetLanguageFiles($target);
        $project.CheckinFiles($targetGuids, $null, $null)
    }
}

function Get-LatestSourceFiles
{
    param (
        [Parameter(Mandatory=$true)]
        [Sdl.ProjectAutomation.FileBased.FileBasedProject] $project
    )

    $sourceFiles = $project.GetSourceLanguageFiles()
    $mergedFiles = $sourceFiles | Where-Object { $_.ChildFiles } | ForEach-Object {$_.ChildFiles } 
    $sourceFiles += $mergedFiles;
    $sourceGuids = Get-Guids $sourceFiles;
    foreach ($id in $sourceGuids)
    {
        $null = $project.DownloadLatestServerVersion($id, $null, $true);
    }
}

function Get-LatestTargetFiles 
{
    param (
        [Parameter(Mandatory=$true)]
        [Sdl.ProjectAutomation.FileBased.FileBasedProject] $project
    )

    $projectInfo = $project.GetProjectInfo()
    $targetLanguages = $projectInfo.TargetLanguages;
    foreach($target in $targetLanguages)
    {
        $targetFiles = $project.GetTargetLanguageFiles($target);
        $targetMergedFiles = $targetFiles | Where-Object { $_.ChildFiles } | ForEach-Object {$_.ChildFiles } 
        $targetFiles += $targetMergedFiles
        $targetGuids = Get-Guids $targetFiles;

        foreach ($targetGuid in $targetGuids)
        {
            $null = $project.DownloadLatestServerVersion($targetGuid, $null, $true);
        }
    }

}

function Get-FileStatus {
    param ($obj, $evt)

    Write-Host $evt
    Write-Host $obj
    Write-Host "$($evt.FileName), $($evt.FileBytesTransferred) of $($evt.FileBytesTransferred) transferred"
    
    if ($cancelledByUser) {
        $evt.Cancel = $true
    }
}

function Set-ProjectCheckout
{
    param (
        [Sdl.ProjectAutomation.FileBased.FileBasedProject] $project,
        [System.Guid[]] $guids
    )

    try 
    {
        $project.CheckoutFiles($guids, $false, $null);
    }
    catch 
    {
        Write-Host "One of the files is already checked out" -ForegroundColor Green
        return $null;
    }
}

Export-ModuleMember Get-ProjectServer;
Export-ModuleMember Show-ServerbasedProjects;
Export-ModuleMember Get-ServerbasedProject;
Export-ModuleMember Publish-Project;  
Export-ModuleMember UnPublish-Project;
Export-ModuleMember Set-CheckInFiles;
Export-ModuleMember Set-CheckOutFiles;