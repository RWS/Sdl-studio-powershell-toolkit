<#
.SYNOPSIS
Connects to the User Management Server.

.DESCRIPTION
The Get-UMServer function connects to a specified User Management Server and returns an IdentityInfoCache object. 
This object can be used to retrieve the user manager object and manage user-related information.

.PARAMETER serverAddress
Specifies the address of the GroupShare server to connect to.

Example: http://HOST.com

.PARAMETER userName
Specifies the username used to log in to the server.

.PARAMETER password
Specifies the password used to log in to the server.

.EXAMPLE
PS C:\> $cache = Get-UMServer -serverAddress "http://HOST.com" -userName "sa" -password "sa"

This example connects to the User Management Server at http://HOST.com using the username "sa" and password "sa". It returns an IdentityInfoCache object.
#>
function Get-UMServer
{
	param(
		[Parameter(Mandatory=$true)]
		[String] $serverAddress,

		[Parameter(Mandatory=$true)]
		[String] $userName,

		[Parameter(Mandatory=$true)]
		[String] $password)
	
	[Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.IdentityInfoCache] $cache =
		[Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.IdentityInfoCache]::Default; 

	if($cache.Count -gt 1)
	{
		$cache.ClearAllIdentities();
	}

	$cache.SetCustomIdentity($serverAddress, $userName, $password);
	return $cache;
}

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
#>
function Get-UserManager
{
	param(
		[Parameter(Mandatory=$true)]
		[Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.IdentityInfoCache] $cache)

	return New-Object Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.UserManagerClient($cache.DefaultKey);	
}

<#
.SYNOPSIS
Retrieves all existing users from the server.

.DESCRIPTION
The Get-AllUsers function uses a UserManagerClient object to retrieve a list of all users from the server. This function returns the complete set of users currently managed by the server.

.PARAMETER manager
Specifies the UserManagerClient object used to retrieve the list of users. This object can be obtained from the Get-UserManager function.

.EXAMPLE
PS C:\> $cache = Get-UMServer -serverAddress "http://HOST.com" -userName "admin" -password "password123"
PS C:\> $userManager = Get-UserManager -cache $cache
PS C:\> $users = Get-AllUsers -manager $userManager

This example first connects to the User Management Server to retrieve an IdentityInfoCache object, then uses that object to retrieve a UserManagerClient object, and finally retrieves a list of all users from the server.
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
PS C:\> $cache = Get-UMServer -serverAddress "http://HOST.com" -userName "admin" -password "password123"
PS C:\> $userManager = Get-UserManager -cache $cache
PS C:\> $user = Get-User -manager $userManager -userName "john.doe"
#>
function Get-User 
{
	param (
		[Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.UserManagerClient] $manager,
		[String] $userName
	)

	try 
	{
		return $manager.GetUserByUserName($userName);
	}
	catch 
	{
		Write-Host "User Not found" -ForegroundColor Red;
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

.PARAMETER organization
Specifies the ResourceGroup object representing the user's organization. This object is necessary for associating the user with the appropriate organization.

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
PS C:\> $cache = Get-UMServer -serverAddress "http://HOST.com" -userName "admin" -password "password123"
PS C:\> $userManager = Get-UserManager -cache $cache
PS C:\> $organization = Get-AllOrganizations -manager $userManager | Where-Object { $_.Name -eq "HR" }
PS C:\> $newUser = New-User -manager $userManager -organization $organization -userName "jane.doe" -userDisplayName "Jane Doe" -userPassword "password123" -userEmailAddress "jane.doe@example.com" -userDescription "HR Manager"

This example connects to the User Management Server, retrieves a UserManagerClient object, gets the HR organization, and then creates a new user "jane.doe" with the specified details.
#>
function New-User 
{
	param (
		[Parameter(Mandatory=$true)]
		[Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.UserManagerClient] $manager,

		[Parameter(Mandatory=$true)]
		[SDL.ApiClientSDK.GS.Models.ResourceGroup] $organization,

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
	$user.OrganizationId = $organization.UniqueId;
	$user.EmailAddress = $userEmailAddress;
	
	try {
		$manager.AddUser($user, $userPassword);
		return $manager.GetUserByUserName($userName);		
	}
	catch 
	{
		Write-Host "Error creating the user" -ForegroundColor Red
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
PS C:\> $cache = Get-UMServer -serverAddress "http://HOST.com" -userName "admin" -password "password123"
PS C:\> $userManager = Get-UserManager -cache $cache
PS C:\> Remove-User -manager $userManager -userName "john.doe"

This example connects to the User Management Server, retrieves a UserManagerClient object, and then removes the user with the username "john.doe" from the server.
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
PS C:\> $cache = Get-UMServer -serverAddress "http://HOST.com" -userName "admin" -password "password123"
PS C:\> $userManager = Get-UserManager -cache $cache
PS C:\> $organizations = Get-AllOrganizations -manager $userManager

This example connects to the User Management Server to retrieve an IdentityInfoCache object, uses that object to get a UserManagerClient object, and then retrieves all organizations from the server.
#>
function Get-AllOrganizations {
    param(
        [Parameter(Mandatory=$true)]
        [Sdl.Desktop.Platform.ServerConnectionPlugin.Client.IdentityModel.UserManagerClient] $manager
    )

    # Get all resource groups
    $allResources = $manager.GetResourceGroupHierarchy()
    
    # Filter out the organization resource groups
    $allOrganizations = @()
    foreach ($resource in $allResources) {
        if ($resource.ResourceGroupType -eq 'ORG') {
            $allOrganizations += $resource
        }
    }

	return Traverse-ResourceGroups $allOrganizations;
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
PS C:\> $cache = Get-UMServer -serverAddress "http://HOST.com" -userName "admin" -password "password123"
PS C:\> $userManager = Get-UserManager -cache $cache
PS C:\> $organization = Get-Organization -manager $userManager -organizationPath "/"

This example connects to the User Management Server, retrieves a UserManagerClient object, and then retrieves the organization located at the path "/".
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
		Write-Host "Orgnaization does not exist" -ForegroundColor Red
		return $null;
	}

	return $manager.GetResourceGroup($id);
}

function Traverse-ResourceGroups {
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

Export-ModuleMember Get-UMServer; 
Export-ModuleMember Get-UserManager;
Export-ModuleMember Get-AllUsers;
Export-ModuleMember Get-AllOrganizations;
Export-ModuleMember Get-Organization;
Export-ModuleMember Get-User;
Export-ModuleMember New-User;
Export-ModuleMember Remove-User;