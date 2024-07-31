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

.PARAMETER organization
The `ResourceGroup` object representing the organization from which projects will be retrieved. This object should be obtained from the SDL.ApiClientSDK.

.PARAMETER includeSubOrganizations
A boolean value indicating whether to include projects from suborganizations. By default, this is set to `false`.

.EXAMPLE
$credential = Get-ProjectServer -serverAddress "https://example.com" -userName "admin" -password "securepassword"
$organization = Get-OrganizationResourceGroup -name "MainOrg"
$projects = Show-ServerbasedProjects -server $credential -organization $organization -includeSubOrganizations $true

This example shows how to retrieve all projects from the "MainOrg" organization and its suborganizations. The `$projects` variable will contain the list of projects.
#>
function Show-ServerbasedProjects
{
      param(
        [Parameter(Mandatory=$true)]
        [DependencyResolver.CredentialStore] $server,

        [Parameter(Mandatory=$true)]
        [SDL.ApiClientSDK.GS.Models.ResourceGroup] $organization,

        [Bool] $includeSubOrganizations = $false)

    $projectServer = New-Object Sdl.ProjectAutomation.FileBased.ProjectServer(
        $server.ServerUri, $false, $server.UserName, $server.Password);

    return $projectServer.GetServerProjects($organization.Path, $includeSubOrganizations, $true);
}

<#
.SYNOPSIS
Downloads and copies a server-based project to a specified local folder.

.DESCRIPTION
The `Get-ServerbasedProject` function connects to a server using provided credentials and retrieves a specified project from the server. It then downloads and copies the project to a local folder.

.PARAMETER server
An instance of the `CredentialStore` class containing the server URI, username, and password used for authentication.

.PARAMETER organization
The `ResourceGroup` object representing the organization where the project is hosted. This object should be obtained from the SDL.ApiClientSDK.

.PARAMETER projectName
The name of the project to be downloaded from the server.

.PARAMETER outputProjectFolder
The local directory path where the project will be copied. The project will be saved in this folder with its original name.

.EXAMPLE
$credential = Get-ProjectServer -serverAddress "https://example.com" -userName "admin" -password "securepassword"
$organization = Get-OrganizationResourceGroup -name "MainOrg"
$outputFolder = "D:\LocalProjects"
Get-ServerbasedProject -server $credential -organization $organization -projectName "ProjectX" -outputProjectFolder $outputFolder

This example downloads the project named "ProjectX" from the "MainOrg" organization and copies it to the local folder "D:\LocalProjects".
#>
function Get-ServerbasedProject
{
    param (
        [Parameter(Mandatory=$true)]
        [DependencyResolver.CredentialStore] $server,

        [Parameter(Mandatory=$true)]
        [SDL.ApiClientSDK.GS.Models.ResourceGroup] $organization,
 
        [Parameter(Mandatory=$true)]
        [String] $projectName,

        [Parameter(Mandatory=$true)]
        [String] $outputProjectFolder
    )

    $projectServer = New-Object Sdl.ProjectAutomation.FileBased.ProjectServer(
        $server.ServerUri, $false, $server.UserName, $server.Password);
    $projectInfo = $projectServer.GetServerProject("$($organization.Path)/$projectName");
    return $ProjectServer.OpenProject($projectInfo.ProjectId, $outputProjectFolder + "\" + $projectInfo.Name);
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

.PARAMETER organization
The `ResourceGroup` object representing the organization on the GroupShare server where the project will be published. This object should be obtained from the SDL.ApiClientSDK.

.EXAMPLE
$credential = Get-ProjectServer -serverAddress "https://example.com" -userName "admin" -password "securepassword"
$project = Open-Project -path "D:\LocalProjects\MyProject"
$organization = Get-OrganizationResourceGroup -name "MainOrg"
Publish-Project -server $credential -project $project -organization $organization

This example publishes a local project named "MyProject" to the "MainOrg" organization on the GroupShare server.
#>
function Publish-Project 
{
    param(
        [Parameter(Mandatory=$true)]
        [DependencyResolver.CredentialStore] $server,

        [Parameter(Mandatory=$true)]
        [Sdl.ProjectAutomation.FileBased.FileBasedProject] $project,

        [Parameter(Mandatory=$true)]
        [SDL.ApiClientSDK.GS.Models.ResourceGroup] $organization)

    $null = $project.PublishProject(
        $server.ServerUri, $false, $server.UserName, $server.Password, $organization.Path, $null); # maybe add a delegate here to display
}

<#
.SYNOPSIS
Removes the specified project from the GroupShare server.

.DESCRIPTION
The `UnPublish-Project` function removes a project from the GroupShare server. This action deletes the project from the server, making it no longer available.

.PARAMETER project
An instance of the `FileBasedProject` class representing the project to be removed from the server. This project should be loaded and must exist on the server.

.EXAMPLE
$project = Open-Project -path "D:\LocalProjects\MyProject"
UnPublish-Project -project $project

This example removes the project located at "D:\LocalProjects\MyProject" from the GroupShare server.
#>
function UnPublish-Project
{
    param(
        [Parameter(Mandatory=$true)]
        [Sdl.ProjectAutomation.FileBased.FileBasedProject] $project)

    $project.DeleteFromServer();
}

Export-ModuleMember Get-ProjectServer;
Export-ModuleMember Show-ServerbasedProjects;
Export-ModuleMember Get-ServerbasedProject; 
Export-ModuleMember Publish-Project; 
Export-ModuleMember UnPublish-Project;
