Trados PowerShell Toolkit
==================

## Introduction
The Trados PowerShell Toolkit allows scripting the [Project Automation API](https://developers.rws.com/studio-api-docs/apiconcepts/projectautomation/overview.html) that is available with Trados Studio Professional. A Professional license for Trados Studio is required to use the API via this toolkit.

## Toolkit Overview
  - **Modules:** `GetGuids`, `PackageHelper`, `ProjectHelper`, `ProjectServerHelper`, `TMHelper`, `TMServerHelper`, `ToolkitInitializer`, `UserManagerHelper`
  - **Scripts:** `FileBasedProject_Roundtrip.ps1`, `ServerBasedProject_Roundtrip.ps1`, `UserManager_Roundtrip.ps1`, `TMServer_Roundtrip.ps1`
  - **Samples:** Demonstration files for `FileBasedProject_Roundtrip.ps1`

For setup, configuration, and usage details, refer to the subsequent sections.

## Table of contents
<details>
  <summary>Expand</summary>
  
  - [Getting Started](#getting-started)
  - [Installation](#installation)
  - [Configuring the Scripts](#configuring-the-scripts)
  - [Running Toolkit Sample Scripts](#running-toolkit-sample-scripts)
  - [Finding the Studio Version](#finding-the-studio-version)
  - [Module Usage](#modules-usage)
  - [How to Access Help for Functions](#how-to-access-help-for-functions)
  - [Function Documentation](#function-documentation)
  - [Ensuring File Permissions for Toolkit Files](#ensuring-file-permissions-for-toolkit-files)
  - [Check Installed Version of PowerShell](#check-installed-version-of-powershell)
  - [Contribution](#contribution)
  - [Issues](#issues)
  - [Changes](#changes)
</details>

## Getting Started
Ensure the following requirements are met before using this toolkit:
1. Trados Studio License
    - A Trados Studio license is mandatory for the operation of this toolkit.
2. PowerShell Version
    - Ensure that PowerShell 5 (x86) is installed and configured on your system. PowerShell 5.1 is included by default in Windows 10 (version 1607 and later) and Windows 11. For other versions of Windows, you may need to manually install or upgrade to PowerShell 5.0 or 5.1.  Follow these steps if you are unsure [Check installed version of Powershell](#check-installed-version-of-powershell)
3. Installation
    - Follow the instructions in the [Installation](#installation) section to properly set up the toolkit on your system.
4. Script Configuration
    - Properly configure the script according to the provided guidelines to ensure smooth functionality. Detailed instructions can be found in the [Configuring the scripts](#configuring-the-scripts) section.
5. (Optional) GroupShare Server
    - If you wish to use the GroupShare extension, ensure you have access to an existing GroupShare server. The toolkit can interact with GroupShare to enhance project management and translation processes.

## Installation
1. **Download the Files:**
    - Ensure you have downloaded all necessary files for the toolkit, including the sample roundtrip scripts and PowerShell modules. These files should be obtained from the provided source or repository. [Download Toolkit Files](https://github.com/RWS/Sdl-studio-powershell-toolkit/releases/tag/3.0.0.0)
    - After downloading, you may need to **unblock the zip file**. For instructions on how to unblock files, see [Ensuring File Permissions for Toolkit File](#ensuring-file-permissions-for-toolkit-files).
2. **Create Required Folders:**
    - First, create the following folders if they do not already exist:
      - `C:\users\{your_user_name}\Documents\WindowsPowerShell`
      - `C:\users\{your_user_name}\Documents\WindowsPowerShell\modules`
3. **Copy Sample Roundtrip Scripts**
      - Copy the sample roundtrip scripts into the `WindowsPowerShell` folder:
        - `FileBasedProject_Roundtrip.ps1`
        - `ServerBasedProject_Roundtrip.ps1`
        - `TMServer_Roundtrip.ps1`
        - `UserManager_Roundtrip.ps1`
      - Ensure these files are placed directly in the `C:\Users\{your_user_name}\Documents\WindowsPowerShell` directory.
4. **Copy PowerShell Modules:**
    - Next, copy the PowerShell modules into the `modules` folder:
      - `....\WindowsPowerShell\modules\GetGuids`
      - `....\WindowsPowerShell\modules\PackageHelper`
      - `....\WindowsPowerShell\modules\ProjectHelper`
      - `....\WindowsPowerShell\modules\ProjectServerHelper`
      - `....\WindowsPowerShell\modules\TMHelper`
      - `....\WindowsPowerShell\modules\TMServerHelper`
      - `....\WindowsPowerShell\modules\ToolkitInitializer`
      - `....\WindowsPowerShell\modules\UserManagerHelper`
    - Ensure each module folder contains its respective `.psd1` and `.psm1` files.
5. **Verify File Locations**
    - Confirm that the files are located in the correct directories:
      - Scripts should be in `C:\Users\{your_user_name}\Documents\WindowsPowerShell`
      - Modules should be in `C:\Users\{your_user_name}\Documents\WindowsPowerShell\modules` with appropriate subfolders for each module.

Following these steps will ensure that the PowerShell toolkit is set up correctly and ready for use.

## Configuring the scripts
The `ToolkitInitializer` module includes the `Import-ToolkitModules` function, which imports all necessary modules, resolves dependencies, and handles version conflicts. This function can be called either with or without specifying the `$StudioVersion` parameter.

### Configuration Instructions
1. Setting the Trados Studio Version
    - To configure the toolkit for your specific version of Trados Studio, you need to set the `$StudioVersion` parameter in the `ToolkitInitializer.psm1` file located at:
    - `....\WindowsPowerShell\modules\ToolkitInitializer\ToolkitInitializer.psm1`
    - Example Configuration: `[String] $StudioVersion = "Studio18"`
    - Replace `$StudioVersion` with the version of Trados Studio you are using.

2. Dynamic Version Assignment
If you prefer to dynamically specify the Trados Studio version when running the script, you can do so by passing the version as a parameter to the `Import-ToolkitModules` function.
    - Example Command:
    - `Import-ToolkitModules -StudioVersion "Studio18"`
    
For details on locating the correct Trados Studio version, refer to the [Finding the Studio Version](#finding-the-studio-version) section.

### Roundtrip Script Configuration
To properly run the various roundtrip scripts, you must configure the parameters specific to each script. Here’s how to set up each type:

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

## Running Toolkit Sample Scripts
This section assumes that all the Roundtrip files have been configured as described in the [Roundtrips configuration](#roundtrips-configuration) section. Follow the steps below to run the scripts for file-based and server-based operations:

1. Open PowerShell as an Administrator:
    - Right-click on the PowerShell icon and select *"Run as Administrator."*
2. Set the Execution Policy (If Needed):
    - If you have not unblocked the files as described in the [Ensuring File Permissions for Toolkit Files](#ensuring-file-permissions-for-toolkit-files) section, you might need to allow script execution by setting the execution policy. To do this, execute:
      - `Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser`
    - This command allows PowerShell script execution without requiring local Windows admin privileges and needs to be executed once per machine and per user profile.
    - **Note:** If you have already unblocked all the files (see E[nsuring File Permissions for Toolkit Files](#ensuring-file-permissions-for-toolkit-files)), you may not need to set the execution policy. Unblocking the files can sometimes resolve script execution issues without changing the execution policy.
3. Change to the Directory Where Your Script Is Located:
    - Navigate to the directory containing your script:
      - cd C:\users\{your_user_name}\Documents\WindowsPowerShell
4. Run the File-Based Roundtrip Script:
    - To execute the `FileBasedProject_Roundtrip.ps1` script, type `.\FileBasedProject_Roundtrip.ps1`
    - This script creates and processes file-based translation memories, projects, and packages.
5. Optional: Run the Server-Based Project Roundtrip Script (If Using GroupShare Server):
    - If you are using GroupShare functionalities, execute the `ServerBasedProject_Roundtrip.ps1` script after the file-based roundtrip script.
6. Optional: Run the TM Server Roundtrip Script (If Using GroupShare Server):
    - To execute the `TMServer_Roundtrip.ps1` script, type `.\TMServer_Roundtrip.ps1`
7. Optional: Run the User Manager Roundtrip Script (If Using GroupShare Server):
    - To execute the `UserManager_Roundtrip.ps1` script, type `.\UserManager_Roundtrip.ps1`

### **Example Session**
Here’s an example of a complete session to run the file-based roundtrip script:
```powershell
# Open PowerShell as Administrator and set the execution policy if needed
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

# Navigate to the directory containing the script
cd C:\users\{your_user_name}\Documents\WindowsPowerShell

# Run the File-Based Roundtrip Script
.\FileBasedProject_Roundtrip.ps1
```

## Finding the Studio Version
To determine your Trados Studio version, follow these steps:
  1. Navigate to Installation Directory:
      - Check one of the following directories on your system to locate Trados Studio:
        - `C:\Program Files (x86)\Trados\Trados Studio`
        - `C:\Program Files\Trados\Trados Studio` (if `Program Files (x86)` does not exist)
  2. Identify the Version Folder:
    In the directory you find, the folder name typically corresponds to the version of Trados Studio installed. For example:
        - **Studio 2022** will be in a folder named  `Studio17`
        - **Studio 2024** will be in a folder named  `Studio18`

By identifying the folder name, you can determine the version of Trados Studio you are using.

## Modules usage
To utilize the Trados Studio Toolkit functions, follow these steps:
### 1. Import the `ToolkitInitializer` Module
To begin using the toolkit functions, you must first import the ToolkitInitializer module into your PowerShell session. This step assumes you have correctly placed the module in the designated `WindowsPowerShell` directory.
  - Command: 
  ```powershell
  Import-Module -Name ToolkitInitializer
  ```
**Note**:  If you receive an error indicating that the module cannot be found, ensure that the module directory is included in your PowerShell module path. You might need to update the `$env:PSModulePath` environment variable.
#### Troubleshooting:
- **Module Not Found Error**: Verify that the module is in the correct directory and that the path is included in the `$env:PSModulePath` environment variable. You can view the current paths with:
  ```powershell
  $env:PSModulePath
  ```
  - If needed, add the module directory to the path:
  ```powershell
  $env:PSModulePath += ";C:\Users\{YourUserName}\Documents\WindowsPowerShell\Modules"
  ```
  - Replace `{YourUserName}` with your actual Windows username.
- **Example for User-Specific Directory:**
  ```powershell
  $env:PSModulePath += ";C:\Users\JohnDoe\Documents\WindowsPowerShell\Modules"
  ```
- **Permanently Permanently Add the Path to `$env:PSModulePath`:** If you wish to add the path permanently so that it remains available across sessions and reboots, follow these steps:
    - Open PowerShell as Administrator
    - Add the Directory to the Environment Variable:
    ```powershell
    $modulePath = "C:\Users\{Your_username}\Documents\WindowsPowerShell\Modules"
  [System.Environment]::SetEnvironmentVariable("PSModulePath", "$env:PSModulePath;$modulePath", [System.EnvironmentVariableTarget]::User)
    ```
    - Replace `Your_username` with the actual username
    - To confirm the path has been added permanently:
    ```powershell
    $env:PSModulePath
    ```
- **Import the Toolkit Module by Specifying Its Path:** If you prefer or need to import the module by specifying its path directly, you can do so using the following command:
  ```powershell
  Import-Module "C:\Users\{YourUserName}\Documents\WindowsPowerShell\Modules\ToolkitInitializer"
  ```
    - Replace `{YourUserName}` with your actual Windows username.


### 2. Call the `Import-ToolkitModules` Method
Once the `ToolkitInitializer` module is imported, you need to call the `Import-ToolkitModules` method. This step may require parameters depending on your configuration.
  - Command: 
    ```powershell
    Import-ToolkitModules
    ```
  - Optional Parameters: If you need to specify parameters based on your configuration, include them as required:
    ```powershell
    Import-ToolkitModules -StudioVersion "Studio18"
    ```

### 3. Access Toolkit Functions
After importing the module and calling the `Import-ToolkitModules` method, all the functions from the Trados Studio Toolkit will be available for use in your PowerShell session.

### Example Session
Here’s a complete example of how to import the module and call the toolkit functions:

```powershell
# Import the ToolkitInitializer module
Import-Module -Name ToolkitInitializer

# Import toolkit modules (if parameters are needed, adjust accordingly)
Import-ToolkitModules
```

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
| Get-UserManager        | Connects to the User Management Server and retrieves the UserManagerClient object.       | UserManagerHelper    |
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

## Check installed version of Powershell
To determine which version of PowerShell is installed on your system:

1. Open the Run Dialog:
   -  Press `Windows Key + R` to open the Run dialog.

2. Launch PowerShell:
    - Type `powershell` into the Run dialog and press Enter. This will open a PowerShell window.

3. Check the PowerShell Version:
   - In the PowerShell window, enter the following command:
    ```powershell
    $PSVersionTable
    ```
4. Press Enter. This will display a table with detailed information about the PowerShell version, including the version number

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