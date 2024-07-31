Trados PowerShell Toolkit
==================

## Introduction
The Trados PowerShell Toolkit allows scripting the [Project Automation API](https://developers.rws.com/studio-api-docs/apiconcepts/projectautomation/overview.html) that is available with Trados Studio Professional. To use the Project Automation API via this toolkit, a Professional license for Trados Studio is required.

## Table of contents
<details>
  <summary>Expand</summary>
  
  - [Prerequisites](#prerequisites)
  - [Structure](#structure)
  - [Configuring the Scripts](#configuring-the-scripts)
  - [Installation](#installation)
  - [Finding the Studio Version](#finding-the-studio-version)
  - [Running Toolkit Sample Scripts](#running-toolkit-sample-scripts)
  - [Module Usage](#modules-usage)
  - [Function Documentation](#function-documentation)
  - [How to Access Help for Functions](#how-to-access-help-for-functions)
  - [Ensuring File Permissions for Toolkit Files](#ensuring-file-permissions-for-toolkit-files)
  - [Known issues](#known-issues)
  - [Contribution](#contribution)
  - [Issues](#issues)
  - [Changes](#changes)
</details>

## Prerequisites
Ensure the following requirements are met before using this toolkit:
1. Trados Studio License
    - A Trados Studio license is mandatory for the operation of this toolkit.
2. PowerShell Version
    - Ensure that PowerShell 5 (x86) is installed and configured on your system. PowerShell 5.1 is included by default in Windows 10 (version 1607 and later) and Windows 11. For other versions of Windows, you may need to manually install or upgrade to PowerShell 5.0 or 5.1.
3. File Permissions
    - Verify and adjust file permissions for the toolkit files as necessary. Detailed instructions can be found in the [File Permissions](#ensuring-file-permissions-for-toolkit-files) section.
4. Script Configuration
    - Properly configure the script according to the provided guidelines to ensure smooth functionality. Detailed instructions can be found in the [Configuring the scripts](#configuring-the-scripts) section.
5. (Optional) GroupShare Server
  - If you wish to use the GroupShare extension, ensure you have access to an existing GroupShare server. The toolkit can interact with GroupShare to enhance project management and translation processes.


## Structure
The PowerShell Toolkit consists of 9 modules
- `GetGuids`
- `PackageHelper`
- `ProjectHelper`
- `ProjectServerHelper`
- `TMHelper`
- `TMServerHelper`
- `ToolkitInitializer`
- `UserManagerHelper`

The toolkit also includes:
- `FileBasedProject_Roundtrip.ps1`: Demonstrates how to create file-based translation memories, projects, and packages
- `ServerBasedProject_Roundtrip.ps1`: Shows how to publish a file-based project to a GroupShare server and download it
- `UserManager_Roundtrip.ps1`: Provides examples for creating and managing users on a GroupShare server
- `TMServerHelper_Roundtrip.ps1`: Illustrates how to create and manage server-based translation memories and containers
- `Samples`: A directory containing demonstration files used by the `FileBasedProject_Roundtrip.ps1` script to showcase toolkit functionalities

## Configuring the scripts
The `ToolkitInitializer` module includes the `Import-ToolkitModules` method, responsible for importing all other modules, resolving dependencies, and addressing version conflicts. This function can be called with or without the `$StudioVersion` parameter.

### Configuration Instructions
To configure this module for your Trados Studio, set the `$StudioVersion` parameter in the  `....\windowspowershell\modules\ToolkitInitializer\ToolkitInitializer.psm1` file.
- Example: `[String] $StudioVersion = "{Studio_Version}"`

### Dynamic Assignment
To dynamically assign the Trados Studio version, provide the version when calling `Import-ToolkitModules`.
- Example `Import-ToolkitModules -StudioVersion "Studio18"`

For detailed instructions on finding the Trados Studio version, refer to the [Finding the Studio Version](#finding-the-studio-version) section.

### Roundtrips configuration.
To run the various roundtrip scripts, you need to configure the parameters appropriately. Below are the steps for configuring each type of roundtrip script:
#### 1. File-Based Roundtrip (`FileBasedProject_Roundtrip.ps1`)
1. Set Studio Version:
  - Configure the `$StudioVersion` parameter to match the version of Trados Studio you are using.
  - Example: `$StudioVersion = "Studio18"`
2. Set Project Source Files:
  - Configure the `$ProjectSourceFiles` parameter to point to the location of the `Sample` folder.
  - Example: `$ProjectSourceFiles = "C:\Path\To\Samples"`

#### 2. Server-Based Project Roundtrip (`ServerBasedProject_Roundtrip.ps1`)
(Optional: Only if you are using GroupShare server functionalities)
1. Set Studio Version:
  - Configure the `$StudioVersion` parameter similarly as for the file-based roundtrip.
  - Example: `$StudioVersion = "Studio18"`
2. Set GroupShare Server Details:
  - **Server URL**:
    - Configure the `$ServerUrl` parameter with the URL of your GroupShare server.
    - Example: `$ServerUrl = "http://your-group-share-server-url"`
  - **Authentication**:
    - Set the `$UserName` and `$Password` parameters with your GroupShare credentials.
    - Example: 
      - `$UserName = "your-username"`
      - `$Password = "your-password"`

#### 3. TM Server Roundtrip (`TMServerHelper_Roundtrip.ps1`)
(Optional: Only if you are using GroupShare server functionalities)
1. Set Studio Version:
  - Configure the `$StudioVersion` parameter similarly as for the file-based roundtrip.
  - Example: `$StudioVersion = "Studio18"`
2. Set GroupShare Server Details:
  - **Server URL**:
    - Configure the `$ServerUrl` parameter with the URL of your GroupShare server.
    - Example: `$ServerUrl = "http://your-group-share-server-url"`
  - **Authentication**:
    - Set the `$UserName` and `$Password` parameters with your GroupShare credentials.
    - Example: 
      - `$UserName = "your-username"`
      - `$Password = "your-password"`

#### 4. User Manager Roundtrip (`UserManager_Roundtrip.ps1`)
(Optional: Only if you are using GroupShare server functionalities)
1. Set Studio Version:
  - Configure the `$StudioVersion` parameter similarly as for the file-based roundtrip.
  - Example: `$StudioVersion = "Studio18"`
2. Set GroupShare Server Details:
  - **Server URL**:
    - Configure the `$ServerUrl` parameter with the URL of your GroupShare server.
    - Example: `$ServerUrl = "http://your-group-share-server-url"`
  - **Authentication**:
    - Set the `$UserName` and `$Password` parameters with your GroupShare credentials.
    - Example: 
      - `$UserName = "your-username"`
      - `$Password = "your-password"`

## Installation
1. Create the following 2 folders:
    - `C:\users\{your_user_name}\Documents\WindowsPowerShell`
    - `C:\users\{your_user_name}\Documents\WindowsPowerShell\modules`
2. Copy the `Sample_Roundtrip.ps1` into `WindowsPowerShell` folder.
3. Copy the five PowerShell modules into `modules` folder:
    - `....\WindowsPowerShell\modules\GetGuids`
    - `....\WindowsPowerShell\modules\PackageHelper`
    - `....\WindowsPowerShell\modules\ProjectHelper`
    - `....\WindowsPowerShell\modules\ProjectServerHelper`
    - `....\WindowsPowerShell\modules\TMHelper`
    - `....\WindowsPowerShell\modules\TMServerHelper`
    - `....\WindowsPowerShell\modules\ToolkitInitializer`
    - `....\WindowsPowerShell\modules\UserManagerHelper`

## Finding the Studio Version
The Trados Studio version that you are using can be found in one of the following locations:
- `C:\Program Files (x86)\Trados\Trados Studio`
- `C:\Program Files\Trados\Trados Studio` if `Program Files (x86)` does not exist

In the above path, the folder name represents the Studio version.

## Running Toolkit Sample Scripts
This section assumes that all the Roundtrip files have been configured as described in the [Roundtrips configuration](#roundtrips-configuration) section. Follow the steps below to run the scripts for file-based and server-based operations:

1. Open the PowerShell Command Prompt as an Administrator:
  - Right-click on the PowerShell icon and select *"Run as Administrator."*
2. Change to the Directory Where Your Script Is Located:
  - Navigate to the directory containing your script.
  - Example: `cd C:\users\{your_user_name}\Documents\WindowsPowerShell`
3. Ensure You Have Rights to Run the Script:
  - You may need to configure the execution policy to allow running scripts. Execute: `Set-ExecutionPolicy remotesigned`
4. Run the File-Based Roundtrip Script:
  - To execute the `FileBasedProject_Roundtrip.ps1` script, type `.\FileBasedProject_Roundtrip.ps1`
  - This script creates and processes file-based translation memories, projects, and packages.
5. Optional: Run the Server-Based Project Roundtrip Script (If Using GroupShare Server):
  - If you are using GroupShare functionalities, execute the `ServerBasedProject_Roundtrip.ps1` script after the file-based roundtrip script.
6. Optional: Run the TM Server Roundtrip Script (If Using GroupShare Server):
  - To execute the `TMServer_Roundtrip.ps1` script, type `.\TMServer_Roundtrip.ps1`
7. Optional: Run the User Manager Roundtrip Script (If Using GroupShare Server):
  - To execute the `UserManager_Roundtrip.ps1` script, type `.\UserManager_Roundtrip.ps1`

## Modules usage
1. Import the `ToolkitInitializer` module.
2. Call the `Import-ToolkitModules` method.
3. All the functions from the Trados Studio Toolkit will be available for use.

## Function Documentation
| Function Name                | Definition                                                                      | Module            |
|------------------------------|---------------------------------------------------------------------------------|-------------------|
| Import-ToolkitModules        | Imports all modules from the toolkit.                                           | ToolkitInitializer |
| Remove-ToolkitModules        | Removes all the loaded modules.                                                 | ToolkitInitializer |
| Get-Guids                    | Gets the file ids of the given project files returning a collection of **Guids**                    | GetGuids           |
| Import-Package               | Imports a return package into the provided file based project                   | PackageHelper      |
| Export-Package               | Creates a package from the provided file based project                          | PackageHelper      |
| New-Project                  | Creates a new file based project.                                               | ProjectHelper      |
| Remove-Project               | Removes a file based project.                                                   | ProjectHelper      |
| Get-Project                  | Opens a file based project returning **FileBasedProject** object.                   | ProjectHelper      |
| Get-AnalyzeStatistics        | Gets the given file based project's statistics.                                 | ProjectHelper      |
| Get-TaskFileInfoFiles        | Gets the task files of the given target language from an existing file based project. | ProjectHelper     |
| Get-ProjectServer         | Creates an instance of the CredentialStore class with server connection details. | ProjectServerHelper |
| Show-ServerbasedProjects  | Retrieves all projects information from the specified organization and optionally the projects info within the suborganizations. | ProjectServerHelper |
| Get-ServerbasedProject    | Downloads and copies a server-based project to a specified local folder.    | ProjectServerHelper |
| Publish-Project           | Publishes an existing project to the GroupShare server.                    | ProjectServerHelper |
| UnPublish-Project         | Removes the specified project from the GroupShare server.                   | ProjectServerHelper |
| New-FileBasedTM              | Creates a new file based TM.                                                    | TMHelper           |
| Open-FileBasedTM             | Opens an existing file based TM.                                                | TMHelper           |
| Get-TargetTMLanguage         | Gets the target language of a TM.                                               | TMHelper           |
| Get-Language                 | Gets a language as a Trados Language.                                           | TMHelper           |
| Get-Languages                | Gets a list of languages as Trados Languages                                    | TMHelper           |
| Get-TranslationProvider      | Returns a **MemoryResource** object representing a file-based Translation Memory, a server-based Translation Memory or any other Translation Provider (e.g DeepL) that can be used as a translation provider for project creation for specific language pairs or for all project language pairs.    | TMHelper           |
| Get-UMServer           | Connects to the User Management Server and returns an IdentityInfoCache object. | UserManagerHelper    |
| Get-UserManager        | Retrieves the UserManagerClient object using an IdentityInfoCache object.        | UserManagerHelper    |
| Get-AllUsers           | Retrieves a list of all users from the User Management Server.                   | UserManagerHelper    |
| Get-User               | Retrieves detailed information about a specific user by username.               | UserManagerHelper    |
| New-User               | Creates a new user in the User Management Server.                                | UserManagerHelper    |
| Remove-User            | Removes a specified user from the User Management Server.                        | UserManagerHelper    |
| Get-AllOrganizations   | Retrieves all existing organizations from the User Management Server.            | UserManagerHelper    |
| Get-Organization       | Retrieves detailed information about a specific organization by its path.       | UserManagerHelper    |
| Get-TMServer       | Establishes a connection to a Translation Memory (TM) Server using the specified server address, username, and password, returning a TranslationProviderServer object. | TMServerHelper |
| Get-DbServers     | Retrieves a list of all database servers associated with a given TM Server, returning these database servers as a collection of DatabaseServer objects.   | TMServerHelper |
| Get-Containers     | Retrieves a list of all containers associated with the specified TM Server, returning them as a collection of containers.                               | TMServerHelper |
| Get-ServerbasedTMs | Queries a TM Server for ServerBased Translation Memories (TMs), with optional filters based on organization and sub-organizations, and limits the number of TMs returned. | TMServerHelper |
| Get-Container      | Retrieves a container from a TM Server by its path and name, returning the container if found or $null if not.                                           | TMServerHelper |
| New-Container      | Creates a new translation memory container in the TM Server using provided parameters, and returns the created container object.                         | TMServerHelper |
| Get-ServerBasedTM  | Retrieves a server-based Translation Memory (TM) from a TM server based on the provided path and name, returning the TM object.                          | TMServerHelper |
| New-ServerBasedTM  | Creates a new server-based Translation Memory (TM) on the specified TM server with provided properties, and saves it to the server.                     | TMServerHelper |
| Remove-ServerBasedTM | Deletes a specified server-based Translation Memory (TM) from the server.                                                                               | TMServerHelper |
| Remove-Container   | Deletes a specified Translation Memory container from the server.                                                                                       | TMServerHelper |
| Import-Tmx         | Imports TMX data into a specified File-Based or Server-Based Translation Memory.               | TMServerHelper |
| Export-Tmx         | Exports a file-based or a server-based Translation Memory to a specified location in TMX format.                 | TMServerHelper |

## How to Access Help for Functions
Each function in this module has been documented with the `Get-Help` cmdlet, which provides detailed information about its usage and parameters. To view the documentation for a specific function, ensure that the modules are imported into your PowerShell session. You can then use the `Get-Help` cmdlet followed by the function name to access the help content.

Example: `Get-Help Get-DBServers`

## Ensuring File Permissions for Toolkit Files

Windows may block files downloaded from the internet for security reasons. To ensure the toolkit functions properly, unblock these files.

### Step-by-Step Instructions

#### Locate the Downloaded File:
- Open File Explorer and navigate to the folder containing the downloaded file.

#### Right-Click on the File:
- Right-click on the file to open the context menu.

#### Open File Properties:
- Select "Properties" from the context menu. 

#### Unblock the File:
- In the Properties dialog, go to the "General" tab.
- Look for the message: "This file came from another computer and might be blocked to help protect this computer."
- If this message is present, check the box next to "Unblock."

#### Apply and Close:
- Click "Apply" to save the changes.
- Click "OK" to close the Properties dialog.

### Files to Unblock

Ensure the following files are unblocked for proper toolkit functionality:

- **Modules:**
  - `GetGuids.psd1` and `GetGuids.psm1`
  - `PackageHelper.psd1` and `PackageHelper.psm1`
  - `ProjectHelper.psd1` and `ProjectHelper.psm1`
  - `ProjectServerHelper.psd1` and `ProjectServerHelper.psm1`
  - `TMHelper.psd1` and `TMHelper.psm1`
  - `TMServerHelepr.psd1` and `TMServerHelper.psm1`
  - `ToolkitInitializer.psd1` and `ToolkitInitializer.psm1`
  - `UserManagerHelper.psd1` and `UserManagerHelper.psm1`
- **ToolkitInitializer:**
  - `DependencyResolver.dll`
- **Sample Scripts:**
  - `FileBasedProject_Roundtrip.ps1`
  - `ServerBasedProject_Roundtrip.ps1`
  - `TMServer_Roundtrip.ps1`
  - `UserManager_Roundtrip.ps1`

## Known issues
### "log4net:ERROR: XmlConfigurator..." message displayed each time automation is started
The issue identified is a cosmetic bug in the Trados Studio API. Please be assured that it does not impact the functionality of automation processes.

## Contribution
To add functionality or report bugs, please create a [pull request](http://www.codenewbie.org/blogs/how-to-make-a-pull-request) with your changes.

## Issues
Report issues [here](https://github.com/sdl/Sdl-studio-powershell-toolkit/issues).

## Changes
### v3.0.0.0
- Updated script to be compatible with newer versions (Trados Studio 2022 and Trados Studio 2024)
- Added `ToolkitInitializer` Module to load all modules in one function
- Added help support for all the functions

### v2.0.1.0
- Fixed creation of FileBasedTM
- Updated script to include TM in Project

### v2.0.0.0
- The paths to the .dll files are now identified regardless of the operating system (32-bit of 64-bit)
- The user can select which Studio version to use (Studio4 or Studio5)
- The "Sample_Roundtrip.ps1" script now creates a sample text file with custom content
- The "Get-Project" function requires only path to the .sdlproj file as parameter
- The "New-Project" function automatically creates the source file directory
- Updated the "New-FileBasedTM" function from TMHelper module to use the new implemention from Studio
- Updated the "New-Project" function from "Sample_Roundtrip.ps1” to use the new implementation from Studio