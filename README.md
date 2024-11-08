Trados PowerShell Toolkit
==================

## Introduction
The Trados PowerShell Toolkit allows scripting the [Project Automation API](https://developers.rws.com/studio-api-docs/apiconcepts/projectautomation/overview.html) that is available with Trados Studio Professional. A Professional license for Trados Studio is required to use the API via this toolkit.

## Toolkit Overview
  - **Modules:** `GetGuids`, `PackageHelper`, `ProjectHelper`, `ProjectServerHelper`, `ProvidersHelper`, `TMHelper`, `TMServerHelper`, `ToolkitInitializer`, `UserManagerHelper`
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
    - Ensure you have downloaded all necessary files for the toolkit, including the sample roundtrip scripts and PowerShell modules. These files are available at the [official releases page](https://github.com/RWS/Sdl-studio-powershell-toolkit/releases). Be sure to download the latest release to ensure you have the most up-to-date version of the toolkit.
    - After downloading, you may need to **unblock the zip file**. For instructions on how to unblock files, see [Ensuring File Permissions for Toolkit File](#ensuring-file-permissions-for-toolkit-files).
2. **Create Required Folders:**
    - First, create the following folders if they do not already exist:
      - `C:\users\{your_user_name}\Documents\WindowsPowerShell`
      - `C:\users\{your_user_name}\Documents\WindowsPowerShell\Modules`
3. **Copy Sample Roundtrip Scripts**
      - Copy the sample roundtrip scripts into the `WindowsPowerShell` folder:
        - `FileBasedProject_Roundtrip.ps1`
        - `ServerBasedProject_Roundtrip.ps1`
        - `TMServer_Roundtrip.ps1`
        - `UserManager_Roundtrip.ps1`
      - Ensure these files are placed directly in the `C:\Users\{your_user_name}\Documents\WindowsPowerShell` directory.
4. **Copy PowerShell Modules:**
    - Next, copy the PowerShell modules into the `modules` folder:
      - `....\WindowsPowerShell\Modules\GetGuids`
      - `....\WindowsPowerShell\Modules\PackageHelper`
      - `....\WindowsPowerShell\Modules\ProjectHelper`
      - `....\WindowsPowerShell\Modules\ProjectServerHelper`
      - `....\WindowsPowerShell\Modules\ProvidersHelper`
      - `....\WindowsPowerShell\Modules\TMHelper`
      - `....\WindowsPowerShell\Modules\TMServerHelper`
      - `....\WindowsPowerShell\Modules\ToolkitInitializer`
      - `....\WindowsPowerShell\Modules\UserManagerHelper`
    - Ensure each module folder contains its respective `.psd1` and `.psm1` files.
5. **Verify File Locations**
    - Confirm that the files are located in the correct directories:
      - Scripts should be in `C:\Users\{your_user_name}\Documents\WindowsPowerShell`
      - Modules should be in `C:\Users\{your_user_name}\Documents\WindowsPowerShell\Modules` with appropriate subfolders for each module.

Following these steps will ensure that the PowerShell toolkit is set up correctly and ready for use.

## Configuring the scripts
The `ToolkitInitializer` module includes the `Import-ToolkitModules` function, which is responsible for importing the toolkit, ensuring that all necessary dependencies are included, and resolving any dependency conflicts.

The `Import-ToolkitModules` function takes two parameters:
  - `StudioVersion`: Specifies the version of Trados Studio to be used, such as Studio 2022 or Studio 2024.
  - `VaultName`: Represents the name of the secure vault where credentials for translation providers (e.g., Amazon, Google) are stored. These credentials are used during project creation when the project includes such providers.
    - If `VaultName` is provided, the toolkit will check if the `Microsoft.PowerShell.SecretManagement` and `Microsoft.PowerShell.SecretStore` modules are installed. If these modules are not already present, the toolkit will install them automatically, as they are required for secure credential storage.

### Configuration Instructions
1. Setting the Trados Studio Version and/or Vault Name
    - Configuring the toolkit with specific values for `StudioVersion` and `VaultName` allows you to call Import-ToolkitModules without needing to specify these arguments every time. Set these variables directly in the ToolkitInitializer.psm1 file located at:
      - `....\WindowsPowerShell\Modules\ToolkitInitializer\ToolkitInitializer.psm1`
    - **Note**: The `VaultName` parameter is optional and only necessary if you plan to use translation providers (e.g., Amazon, Google). If you don’t intend to use providers, you can omit this parameter.
    - This configuration simplifies the toolkit initialization process by letting you call the function parameterless.
    - Example Configuration
      ```powershell
      [String] $StudioVersion = "Studio18"  # Replace "Studio18" with the correct Trados Studio version
      [String] $vaultName = "MySecureVault"  # Replace "MySecureVault" with your vault name for credential storage
      ```
      After setting these variables, you can simply call:
        ```powershell
        Import-ToolkitModules
        ```
      without needing to specify the parameters each time.

2. Dynamic Version and Vault Assignment
    - For dynamic assignment, users can specify the StudioVersion and VaultName parameters directly when calling Import-ToolkitModules. This method is useful if you prefer to set these values at runtime instead of configuring them in advance.
      - Example Command:
        ```powershell
        Import-ToolkitModules -StudioVersion "Studio18" -VaultName "MySecureVault"
        ```
      - Here, replace `"Studio18"` with the Trados Studio version you are using and `"MySecureVault"` with the name of your vault if you are using translation providers.
      
For details on locating the correct Trados Studio version, refer to the [Finding the Studio Version](#finding-the-studio-version) section.

### Configuring the Translation Providers.
This section assumes that you are providing the `VaultName` with the intent to include translation providers at project creation.

As the project creation process in the Project Automation API requires that the translation provider credentials be available during project creation, this toolkit provides a module called `ProvidersHelper`. The `ProvidersHelper` module is responsible for storing credentials for these translation providers (Amazon, Google, DeepL). This module allows you to **create**, **update**, **read**, and **delete** these translation provider credentials from the secure credential store.
  1. Why Secure Credential Storage is Important
      - It is essential to store the credentials of translation providers securely to ensure the protection of sensitive information, such as API keys and access tokens. By using the `VaultName`, the toolkit securely manages these credentials during project creation and throughout the workflow.
  2. Setting Up the Credential Store
      - When the VaultName is provided, the toolkit automatically checks if the `Microsoft.PowerShell.SecretManagement` and `Microsoft.PowerShell.SecretStore` modules are installed. If these modules are not found, they will be installed as part of the configuration process, enabling secure storage for the provider credentials.
      - Example: Initializing Credential Storage with a Vault Name
      - If you intend to use translation providers, initialize the credential storage by specifying a `VaultName`:
        ```powershell
        Import-ToolkitModules -StudioVersion "Studio18" -VaultName "MySecureVault"
        ```
        Replace `"Studio18"` with the version of Trados Studio you are using (e.g., `"Studio2024"`) and `"MySecureVault"` with the name of your chosen vault for secure credential storage.
  3. Adding Translation Provider Credentials
      - Once your vault is initialized, you can add credentials for your translation providers using the `ProvidersHelper` module. The module provides the `Set-MTCredential`, `Get-MTCredential`, and `Remove-MTCredential` cmdlets to manage translation provider credentials.
      - When using the `Set-MTCredential` cmdlet to add credentials, you will be prompted to securely input the required secrets for each provider.
      - Example: Adding Credentials for Amazon Translate 
        ```powershell
        Set-MTCredential -Type "Amazon"
        ```
        After running this command, you will be prompted to enter the necessary API key or other required credentials for Amazon Translate. The credentials will be securely stored in your vault.

      - Example: Adding Credentials for Google
        ```powershell
        Set-MTCredential -Type "Google"
        ``` 
        You will be prompted to provide the API key or credentials for Google Cloud Translate. Once entered, the credentials will be securely stored in your vault.
  4. Managing Credentials
      - The `ProvidersHelper` module offers the following cmdlets to manage the stored credentials:
        - `Get-MTCredential`: Retrieve stored credentials for a specific provider.
        - `Set-MTCredential`: Add or update credentials for a translation provider.
        - `Remove-MTCredential`: Delete credentials for a specific provider.
        - Example: Retrieving Stored Credentials for DeepL
          ```powershell
          Get-MTCredential -Type "DeepL"
          ```
        - Example: Deleting Stored Credentials for Amazon
          ```powershell
          Remove-MTCredential -Type "Amazon"
          ```
  5. Using Translation Providers During Project Creation
      - With the translation providers configured and credentials securely stored, the toolkit will automatically search for these credentials when a new project is created. During the project creation process, the toolkit will retrieve the appropriate credentials from the secure vault and associate them with the project. This ensures that translation providers (such as Amazon, Google, or DeepL) are seamlessly integrated into the project without requiring manual intervention.
  6. Supported Translation Providers
      - The following translation providers are currently supported:
        - Amazon
        - DeepL
        - Microsoft
        - Language Weaver
        - Google
  
**Important Note**: The **Language Cloud Translation Engine** will also be available once **Trados Studio 2024 CU2** is released. Stay tuned for updates on its availability.

### Roundtrip Script Configuration
To properly run the various roundtrip scripts, you must configure the parameters specific to each script. Here’s how to set up each type:

#### 1. File-Based Roundtrip (`FileBasedProject_Roundtrip.ps1`)
1. Set Studio Version:
    - Configure the `$StudioVersion` parameter to match the version of Trados Studio you are using.
    - Example: `$StudioVersion = "Studio18"`
2. Set Project Source Files:
    - Configure the `$ProjectSourceFiles` parameter to point to the location of the `Sample` folder.
    - Example: `$ProjectSourceFiles = "C:\Path\To\Samples"`

#### 2. Server-Based Roundtrips (`ServerBasedProject_Roundtrip.ps1`, `TMServerHelper_Roundtrip.ps1`, `UserManager_Roundtrip.ps1`, `UserManager_Roundtrip.ps1`)
(Optional: Only if you are using GroupShare server functionalities).

These configurations apply to all the server-based roundtrip scripts listed above.

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
This section assumes that all the Roundtrip files have been configured as described in the [Roundtrips configuration](#roundtrip-script-configuration) section. Follow the steps below to run the scripts for file-based and server-based operations:

1. Open PowerShell as an Administrator:
    - Right-click on the PowerShell icon and select *"Run as Administrator."*
2. Set the Execution Policy (If Needed):
    - If you have not unblocked the files as described in the [Ensuring File Permissions for Toolkit Files](#ensuring-file-permissions-for-toolkit-files) section, you might need to allow script execution by setting the execution policy. To do this, execute:
      - `Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser`
    - This command allows PowerShell script execution without requiring local Windows admin privileges and needs to be executed once per machine and per user profile.
    - **Note:** If you have already unblocked all the files (see [Ensuring File Permissions for Toolkit Files](#ensuring-file-permissions-for-toolkit-files)), you may not need to set the execution policy. Unblocking the files can sometimes resolve script execution issues without changing the execution policy.
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
| Get-ServerbasedProject    | Downloads and copies a server-based project including the source and target language files to a specified local folder.    | ProjectServerHelper |
| Set-CheckOutFiles | Performs checkout for the provided projects. | ProjectServerHelper |
| Set-CheckOutFiles | Performs checkout for the provided projects. | ProjectServerHelper |
| Publish-Project           | Publishes an existing project to the GroupShare server.                    | ProjectServerHelper |
| UnPublish-Project         | Removes the specified project from the GroupShare server.                   | ProjectServerHelper |
| Get-MTCredential | Retrieves stored credentials for a specific translation provider.	 | ProvidersHelper |
| Remove-MTCredential | Deletes stored credentials for a specific translation provider.	 | ProvidersHelper |
| Set-MTCredential | Adds or updates credentials for a specific translation provider.	 | ProvidersHelper |
| New-FileBasedTM              | Creates a new file based TM.                                                    | TMHelper           |
| Open-FileBasedTM             | Opens an existing file based TM.                                                | TMHelper           |
| Get-TargetTMLanguage         | Gets the target language of a TM.                                               | TMHelper           |
| Get-Language                 | Gets a language as a Trados Language.                                           | TMHelper           |
| Get-Languages                | Gets a list of languages as Trados Languages                                    | TMHelper           |
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
Each function in this module has been documented with the `Get-Help` cmdlet, which provides detailed information about its usage and parameters. To view the documentation for a specific function, ensure that the modules are imported into your PowerShell session.

### Steps to View Documentation:
1. **Check if the Module is Loaded:** Execute the following command to check if the module has been loaded
    ```powershell
    Get-Module  
    ```
    - This command will display all the available modules that are imported into your session

2. **Retrieve Help Information:** If the modules are loaded, you can retrieve the help information for a specific function by executing
    ```powershell
    Get-Help {function_name}
    ```
  - Replace `{function_name}` with the name of the function you are looking for.

## Ensuring File Permissions for Toolkit Files

Windows may block files downloaded from the internet for security reasons. To ensure the toolkit functions properly, unblock the downloaded zip file.

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
### v3.0.1.0
- Implemented `ProvidersHelper` module for managing translation provider credentials.
- Updated `ToolkitInitializer` to include the `ProvidersHelper` module.

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