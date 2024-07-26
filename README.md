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
  - [Sample Script Usage](#sample-script-usage)
  - [Modules Usage](#modules-usage)
  - [Functions Available](#functions-available)
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


## Structure
The PowerShell Toolkit consists of 5 modules
- `GetGuids`
- `PackageHelper`
- `ProjectHelper`
- `TMHelper`
- `ToolkitInitializer`

The toolkit also includes:
- `Sample_Roundtrip.ps1`: A sample script which contains examples to create translation memories, projects and packages
- `Samples`: A folder used by the `Sample_Roundtrip.ps1` file for toolkit demonstration purposes

## Configuring the scripts
The `ToolkitInitializer` module includes the `Import-ToolkitModules` method, responsible for importing all other modules, resolving dependencies, and addressing version conflicts. This function can be called with or without the `$StudioVersion` parameter.

### Configuration Instructions
To configure this module for your Trados Studio, set the `$StudioVersion` parameter in the  `....\windowspowershell\modules\ToolkitInitializer\ToolkitInitializer.psm1` file.
- Example: `[String] $StudioVersion = "{Studio_Version}"`

### Dynamic Assignment
To dynamically assign the Trados Studio version, provide the version when calling `Import-ToolkitModules`.
- Example `Import-ToolkitModules -StudioVersion "Studio18"`

For detailed instructions on finding the Trados Studio version, refer to the [Finding the Studio Version](#finding-the-studio-version) section.

### Sample Roundtrip configuration.
To run the `Sample_Roundtrip.ps1` script:
    - Set the `$StudioVersion` parameter to match the Studio version you are using
        - Example: `$StudioVersion = "Studio18"`
    - Set the `$ProjectSourceFiles` parameter to location of the `Sample` folder.
        - Example: `$ProjectSourceFiles = "C:\Path\To\Samples"`

## Installation
1. Create the following 2 folders:
    - `C:\users\{your_user_name}\Documents\WindowsPowerShell`
    - `C:\users\{your_user_name}\Documents\WindowsPowerShell\modules`
2. Copy the `Sample_Roundtrip.ps1` into `WindowsPowerShell` folder.
3. Copy the five PowerShell modules into `modules` folder:
    - `....\WindowsPowerShell\modules\GetGuids`
    - `....\WindowsPowerShell\modules\ProjectHelper`
    - `....\WindowsPowerShell\modules\PackageHelper`
    - `....\WindowsPowerShell\modules\TMHelper`
    - `....\WindowsPowerShell\modules\ToolkitInitializer`

## Finding the Studio Version
The Trados Studio version that you are using can be found in one of the following locations:
- `C:\Program Files (x86)\Trados\Trados Studio`
- `C:\Program Files\Trados\Trados Studio` if `Program Files (x86)` does not exist

In the above path, the folder name represents the Studio version.

## Sample script usage
1. Open the PowerShell command prompt as an Administrator
2. Change to the directory where your script is located:
- e.g. `C:\users\{your_user_name}\Documents\WindowsPowerShell`
3. Ensure you have rights to run the script. You may first need to enter the following command:
- `Set-ExecutionPolicy remotesigned`
4. Run the script bt typing `.\Sample_Roundtrip` and pressing enter

## Modules usage
1. Import the `ToolkitInitializer` module.
2. Call the `Import-ToolkitModules` method.
3. All the functions from the Trados Studio Toolkit will be available for use.

## Functions Available
| Function Name                | Definition                                                                      | Module            |
|------------------------------|---------------------------------------------------------------------------------|-------------------|
| Import-ToolkitModules        | Imports all modules or specified modules from the toolkit.                      | ToolkitInitializer |
| Remove-ToolkitModules        | Removes all the loaded modules.                                                 | ToolkitInitializer |
| Get-Guids                    | Gets the file ids of the given project files.                                   | GetGuids           |
| Import-Package               | Imports a return package into the provided file based project                   | PackageHelper      |
| Export-Package               | Creates a package from the provided file based project                          | PackageHelper      |
| New-Project                  | Creates a new file based project.                                               | ProjectHelper      |
| Remove-Project               | Removes a file based project.                                                   | ProjectHelper      |
| Get-Project                  | Opens a file based project.                                                     | ProjectHelper      |
| Get-AnalyzeStatistics        | Gets the given file based project's statistics.                                 | ProjectHelper      |
| Get-TaskFileInfoFiles        | Gets the task files of the given target language from an existing file based project. | ProjectHelper     |
| New-FileBasedTM              | Creates a new file based TM.                                                    | TMHelper           |
| Open-FileBasedTM             | Opens an existing file based TM.                                                | TMHelper           |
| Get-TargetTMLanguage         | Gets the target language of a TM.                                               | TMHelper           |
| Get-Language                 | Gets a language as a Trados Language.                                           | TMHelper           |
| Get-Languages                | Gets a list of languages as Trados Languages                                    | TMHelper           |
| Get-TranslationProvider      | Returns an object to be used as a translation provider for project creation.    | TMHelper           |
| Import-TMXToFileBasedTM      | Imports a TMX file into an existing file-based Translation Memory                | TMHelper           |
| Export-TMXFromFileBasedTM    | Exports a TMX file from an existing file-based Translation Memory               | TMHelper           |


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
  - `TMHelper.psd1` and `TMHelper.psm1`
  - `ToolkitInitializer.psd1` and `ToolkitInitializer.psm1`
- **ToolkitInitializer:**
  - `DependencyResolver.dll`
- **Sample Script:**
  - `Sample_Roundtrip.ps1`

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