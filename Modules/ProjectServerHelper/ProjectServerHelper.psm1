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
Downloads and copies a server-based project to a specified local folder.

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

    return $ProjectServer.OpenProject($projectInfo.ProjectId, $outputProjectFolder);
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
            Write-Host "$($evt.StatusMessage) $($evt.PercentComplete)% complete"
            
            if ($cancelledByUser) {
                $evt.Cancel = $true
            }
        }); 

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

Export-ModuleMember Get-ProjectServer;
Export-ModuleMember Show-ServerbasedProjects;
Export-ModuleMember Get-ServerbasedProject;
Export-ModuleMember Publish-Project;  
Export-ModuleMember UnPublish-Project;
