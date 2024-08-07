<#
.SYNOPSIS
Retrieves the user manager object.

.DESCRIPTION
The Get-UserManager function takes an IdentityInfoCache object and returns a UserManagerClient object. This object can be used to access user-related information, such as users and organizations.

.PARAMETER cache
Specifies the IdentityInfoCache object used to access the UserManager.

.EXAMPLE
PS C:\> $cache = Get-UMServer -serverAddress "http://HOST.com" -userName "admin" -password "password123"
PS C:\> $userManager = Get-UserManager -cache $cache

This example first connects to the User Management Server to retrieve an IdentityInfoCache object and then uses that object to retrieve a UserManagerClient object.

.OUTPUTS
[UserManagerClient]
The UserManagerClient instance representing an object that will be used for connecting to the user managamenet related resources (users, organizations)
#>
function Get-UserManager
{
	param(
		[Parameter(Mandatory=$true)]
		[String] $serverAddress,

		[Parameter(Mandatory=$true)]
		[String] $userName,

		[Parameter(Mandatory=$true)]
		[String] $password)

	$credentials = New-Object Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.UserCredentials($userName, $password,[Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.UserManagerTokenType]::CustomUser)
	$manager = New-Object Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.UserManagerClient($serverAddress, $credentials)

	try {
		$manager.Ping()
		return $manager;
	}
	catch 
	{
		Write-Host "Invalid server or credentials" -ForegroundColor Green;
		return;
	}
}

<#
.SYNOPSIS
Retrieves all existing users from the server.

.DESCRIPTION
The Get-AllUsers function uses a UserManagerClient object to retrieve a list of all users from the server. This function returns the complete set of users currently managed by the server.

.PARAMETER manager
Specifies the UserManagerClient object used to retrieve the list of users. This object can be obtained from the Get-UserManager function.

.EXAMPLE
PS C:\> $userManager = Get-UserManager -serverAddress "http://HOST.com" -userName "admin" -password "password123"
PS C:\> $users = Get-AllUsers -manager $userManager

This example first creates the UserManager instance and then retrieve the users by providing the $userManager object.

.OUTPUTS
[UserDetails[]]
An Array of UserDetails object representing all the retrieved users
#>
function Get-AllUsers
{
	param (
		[Parameter(Mandatory=$true)]
		[Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.UserManagerClient] $manager)

	return $manager.GetAllUsers();
}

<#
.SYNOPSIS
Retrieves a specific user by username.

.DESCRIPTION
The Get-User function uses a UserManagerClient object to retrieve detailed information about a specific user identified by their username. If the user is not found, an error message is displayed, and the function returns `$null`.

.PARAMETER manager
Specifies the UserManagerClient object used to retrieve the user information. This object can be obtained from the Get-UserManager function.

.PARAMETER userName
Specifies the username of the user to retrieve.

.EXAMPLE
PS C:\> $userManager = Get-UserManager -serverAddress "http://HOST.com" -userName "admin" -password "password123"
PS C:\> $user = Get-User -manager $userManager -userName "john.doe"

This examples first creates the usermanager object, then retrieves the user with the username "john.doe"

.OUTPUTS
[UserDetails]
A UserDetails instance representing the found user or null if not found
#>
function Get-User 
{
	
	param (
		[Parameter(Mandatory=$true)]
		[Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.UserManagerClient] $manager,

		[Parameter(Mandatory=$true)]
		[String] $userName
	)

	try 
	{
		return $manager.GetUserByUserName($userName);
	}
	catch 
	{
		Write-Host "User Not found" -ForegroundColor Green;
		return $null;
	}
}

<#
.SYNOPSIS
Creates a new user in the User Management Server.

.DESCRIPTION
The New-User function creates a new user on the User Management Server using the provided user details. This function requires a UserManagerClient object to perform the user creation operation. 
It also requires the user's organization, username, display name, password, and optionally their email address and description.

.PARAMETER manager
Specifies the UserManagerClient object used to create the new user. This object can be obtained from the Get-UserManager function.

.PARAMETER organizationPath
Specifies the organization path as a string.

.PARAMETER userName
Specifies the username for the new user.

.PARAMETER userDisplayName
Specifies the display name for the new user.

.PARAMETER userPassword
Specifies the password for the new user.

.PARAMETER userEmailAddress
(Optional) Specifies the email address for the new user.

.PARAMETER userDescription
(Optional) Provides a description for the new user.

.EXAMPLE
PS C:\> $userManager = Get-UserManager -serverAddress "http://HOST.com" -userName "admin" -password "password123"
PS C:\> $newUser = New-User -manager $userManager -organizationPath "/" -userName "jane.doe" -userDisplayName "Jane Doe" -userPassword "password123" -userEmailAddress "jane.doe@example.com" -userDescription "HR Manager"

This example first creates the usermanager instance and then creates a new user with the above information.

.OUTPUTS
[UserDetails]
An UserDetails instance representing the newly created user or null if a user already exists or if the provided values are not sufficient.
#>
function New-User 
{
	param (
		[Parameter(Mandatory=$true)]
		[Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.UserManagerClient] $manager,

		[Parameter(Mandatory=$true)]
		[String] $organizationPath,

		[Parameter(Mandatory=$true)]
		[String] $userName,

		[Parameter(Mandatory=$true)]
		[String] $userDisplayName,

		[Parameter(Mandatory=$true)]
		[String] $userPassword,

		[String] $userEmailAddress,
		[String] $userDescription
	)

	$user = New-Object SDL.ApiClientSDK.GS.Models.UserDetails($null);
	$user.Name = $userName;
	$user.DisplayName = $userDisplayName;
	$user.Description = $userDescription;

	$organization = Get-Organization $manager $organizationPath;
	if ($null -eq $organization)
	{
		return;
	}

	$user.OrganizationId = $organization.UniqueId;
	$user.EmailAddress = $userEmailAddress;
	
	try {
		$null = $manager.AddUser($user, $userPassword);
		return $manager.GetUserByUserName($userName);		
	}
	catch 
	{
		Write-Host "Error creating the user" -ForegroundColor Green
		return $null;
	}
}

<#
.SYNOPSIS
Removes a specified user from the User Management Server.

.DESCRIPTION
The Remove-User function deletes a user from the User Management Server based on their username. It uses a UserManagerClient object to perform the deletion. The function retrieves the user by their username and then removes the user from the server.

.PARAMETER manager
Specifies the UserManagerClient object used to delete the user. This object can be obtained from the Get-UserManager function.

.PARAMETER userName
Specifies the username of the user to be removed.

.EXAMPLE
PS C:\> $userManager = Get-UserManager -serverAddress "http://HOST.com" -userName "admin" -password "password123"
PS C:\> Remove-User -manager $userManager -userName "john.doe"

This example first create the instance of the UserManager object, then remove the user with the username "john.doe".
#>
function Remove-User
{
	param(
		[Parameter(Mandatory=$true)]
		[Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.UserManagerClient] $manager,

		[Parameter(Mandatory=$true)]
		[String] $userName)

		$user = Get-User $manager $userName
		if ($user)
		{
			$userIds = @($user.UniqueId);
			$manager.DeleteUsers($userIds);
		}

}

<#
.SYNOPSIS
Retrieves all existing organizations from the User Management Server.

.DESCRIPTION
The Get-AllOrganizations function retrieves a list of all organizations from the User Management Server using a UserManagerClient object. It returns only those resources classified as organizations.

.PARAMETER manager
Specifies the UserManagerClient object used to retrieve the list of organizations. This object can be obtained from the Get-UserManager function.

.EXAMPLE
PS C:\> $userManager = Get-UserManager -serverAddress "http://HOST.com" -userName "admin" -password "password123"
PS C:\> $organizations = Get-AllOrganizations -manager $userManager

This example first creates the UserManager instance, then use it to retrieve all the organizations.

.OUTPUTS
[ResourceGroup[]]
An array of ResourceGroup instances representing all the existing organizations on the server.
#>
function Get-AllOrganizations {
    param(
        [Parameter(Mandatory=$true)]
        [Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.UserManagerClient] $manager
    )

	$allResources = $manager.GetResourceGroupHierarchy()
    
    # Filter out the organization resource groups
    $allOrganizations = @()
    foreach ($resource in $allResources) {
        if ($resource.ResourceGroupType -eq 'ORG') {
            $allOrganizations += $resource
        }
    }

	return Get-TraversedResourceGroups $allOrganizations;
}

<#
.SYNOPSIS
Retrieves a specific organization from the User Management Server.

.DESCRIPTION
The Get-Organization function retrieves detailed information about a specific organization based on its path. It uses a UserManagerClient object to fetch the organization's details. If the organization does not exist, an error message is displayed, and the function returns `$null`.

.PARAMETER manager
Specifies the UserManagerClient object used to retrieve the organization's details. This object can be obtained from the Get-UserManager function.

.PARAMETER organizationPath
Specifies the path of the organization to be retrieved.

.EXAMPLE
PS C:\> $userManager = Get-UserManager -serverAddress "http://HOST.com" -userName "admin" -password "password123"
PS C:\> $organization = Get-Organization -manager $userManager -organizationPath "/"

This example first creates the UserManager instance then retrieves the organization with the "/" path
#>
function Get-Organization 
{
	param (
		[Parameter(Mandatory=$true)]
		[Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.UserManagerClient] $manager,

		[Parameter(Mandatory=$true)]
		[String] $organizationPath
	)

	try 
	{
		$id = $manager.GetResourceGroupId($organizationPath)
	}
	catch 
	{
		Write-Host "Orgnaization does not exist" -ForegroundColor Green
		return $null;
	}

	return $manager.GetResourceGroup($id);
}

function Get-TraversedResourceGroups {
    param (
        [Parameter(Mandatory=$true)]
        [System.Collections.Generic.List[SDL.ApiClientSDK.GS.Models.ResourceGroup]]$initialGroups
    )

    $resultList = [System.Collections.Generic.List[SDL.ApiClientSDK.GS.Models.ResourceGroup]]::new()
    $queue = [System.Collections.Generic.Queue[SDL.ApiClientSDK.GS.Models.ResourceGroup]]::new()

    foreach ($group in $initialGroups) {
        $queue.Enqueue($group)
    }

    while ($queue.Count -gt 0) {
        $currentGroup = $queue.Dequeue()

        if ($currentGroup.ResourceGroupType -eq "ORG") {
            $resultList.Add($currentGroup)
        }

        foreach ($childGroup in $currentGroup.ChildResourceGroups) {
            $queue.Enqueue($childGroup)
        }
    }

    return $resultList
}

Export-ModuleMember Get-UserManager;
Export-ModuleMember Get-AllUsers;
Export-ModuleMember Get-AllOrganizations;
Export-ModuleMember Get-Organization;
Export-ModuleMember Get-User;
Export-ModuleMember New-User;
Export-ModuleMember Remove-User;