Trados PowerShell Toolkit
==================

## Introduction
The Trados Powershell Toolkit allows to script the [Project Automation API](http://producthelp.sdl.com/SDK/ProjectAutomationApi/3.0/html/b986e77a-82d2-4049-8610-5159c55fddd3.htm) that is available with Trados Studio Professional.  In order to use the Project Automation API via the Trados PowerShell Toolkit , a Professional license for Trados Studio is required.
PowerShell 2.0 comes pre-installed on Windows 7. On Windows XP, you may need to manually install PowerShell if it is not already installed.

## Structure
The PowerShell Toolkit consists of 5 modules
- `GetGuids`
- `PackageHelper`
- `ProjectHelper`
- `TMHelper`
- `ToolkitInitializer`
used to load all of the other four modules and the required dependencies that enables their funcionality.

and a `Sample_Roundtrip.ps1` sample script which contains examples to create translation memories, projects and packages.

## Installation

1. **Ensure File Permissions for Toolkit Files**
   - Before proceeding with the installation, unblock the downloaded toolkit files to prevent any potential issues.
   - Follow the steps in the "Ensuring File Permissions for Toolkit Files" section below.

2. **Ensure Trados Studio with a professional license is installed.**
   
3. **Create Required Folders:**
   - Create the following two folders if they do not already exist:
     - `C:\users\{your_user_name}\Documents\windowspowershell`
     - `C:\users\{your_user_name}\Documents\windowspowershell\modules`

4. **Copy Files:**
   - Copy `Sample_Roundtrip.ps1` into the `windowspowershell` folder.
   - Copy the five PowerShell modules into the `modules` folder:
     - `....\windowspowershell\modules\GetGuids`
     - `....\windowspowershell\modules\ProjectHelper`
     - `....\windowspowershell\modules\PackageHelper`
     - `....\windowspowershell\modules\TMHelper`
     - `....\windowspowershell\modules\ToolkitInitializer`

5. **Open PowerShell (x86) Command Prompt:**
   - Since Trados Studio is a 32-bit application, use the PowerShell (x86) command prompt.

6. **Configure Script:**
   - Before running the script (`Sample_Roundtrip.ps1`), ensure the `$StudioVersion` parameter corresponds to your Trados Studio version (e.g., "Studio16" for Studio 2021, "Studio17" for Studio 2022).

7. **Run the Script:**
   - Execute the script by navigating to `C:\users\{your_user_name}\Documents\windowspowershell` and running `.\Sample_Roundtrip.ps1`.

## Ensuring File Permissions for Toolkit Files

When you download files from the internet, Windows may block them for security reasons. To ensure the toolkit functions properly, you need to unblock these files. Follow the steps below to unblock downloaded files:

### Step-by-Step Instructions

#### Locate the Downloaded File:
- Open File Explorer and navigate to the folder containing the downloaded file.

#### Right-Click on the File:
- Find the file you need to unblock.
- Right-click on the file to open the context menu.

#### Open File Properties:
- From the context menu, select "Properties." This will open the Properties dialog for the file.

#### Unblock the File:
- In the Properties dialog, go to the "General" tab.
- At the bottom of the dialog, look for a security section with the message: "This file came from another computer and might be blocked to help protect this computer."
- If you see this message, check the box next to "Unblock."

#### Apply and Close:
- Click "Apply" to save the changes.
- Click "OK" to close the Properties dialog.

### Files to Unblock

After downloading, ensure the following files are unblocked for proper toolkit functionality:

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
  
## Finding the Studio Version
The Trados Studio version that you are using can be found in one of the following locations:
- `C:\Program Files (x86)\Trados\Trados Studio` for Trados Studio 2022 and 2024
- `C:\Program Files (x86)\SDL\SDL Trados Studio` for older versions, including Trados Studio 2021. 

If the above paths does not contain `Program Files (x86)` does not exist, you can replace that with `Program Files`
    - e.g `C:\Program Files\Trados\Trados Studio`

At the above path there is a folder whose name represents the Studio Version.

## Sample script usage
1. Open a PowerShell command prompt as Administrator
2. Change to the directory where your script is located:
e.g. `C:\users\{your_user_name}\Documents\windowspowershell`
3. Ensure you have rights to run the script. You may first need to enter the following command:
`Set-ExecutionPolicy remotesigned`
4. Ensure the StudioVersion from the `Sample_Roundtrip` file matches the Trados Studio version you are using
4. Run your script: type `.\Sample_Roundtrip` and press enter

## Modules usage
1. Ensure that the default StudioVersion from the `Import-ToolkitModules` function in the `ToolkitInitializer.psm1` is set to the Trados Studio version you are using
2. Import the `ToolkitInitializer` module
3. If you have followed the first step, you can call the `Import-ToolkitModules` without any parameters, otherwise you can call it using the StudioVersion you are using. e.g `Import-Toolkit Studio18`.
4. All the functions from the Trados Studio Toolkit are available to use.

## Functions Available
| Command | Definition | Module |
|---------|------------| ------ |
|Import-ToolkitModules| Imports globally all the modules or the given modules from the toolkit.| ToolkitInitializer |
|Remove-ToolkitModules| Removes all the loaded modules. | ToolkitInitializer |
|Get-Guids|     Gets the files id of the given project files. | GetGuids | 
|New-Package|	Creates a new package based on an existing filebased project.| PackageHelper |
|New-Project| 	Creates a new file based project.| ProjectHelper |
|Remove-Project| Removes a file based project. | ProjectHelper |
|Get-Project| Opens a file based project. | ProjectHelper |
|Get-AnalyzeStatistics| Gets the given file based project's statistics. | ProjectHelper |
|Get-TaskFileInfoFiles | Gets the task files of the given target language from an existing file based project.| ProjectHelper |
|New-FileBasedTM | Creates a new file based TM. | TMHelper |
|Open-FileBasedTM| Opens an existing file based TM. | TMHelper |
|Get-TargetTMLanguage| Gets the target language of a TM. | TMHelper |
|Get-Language | Gets a language as a Trados Language. | TMHelper |
|Get-Languages | Gets a list of languages as Trados Languages| TMHelper |

## Contribution
If you want to add a new functionality or you spot a bug please fill free to create a [pull request](http://www.codenewbie.org/blogs/how-to-make-a-pull-request) with your changes.

## Issues
If you find an issue you report it [here](https://github.com/sdl/Sdl-studio-powershell-toolkit/issues).

## Changes
### v3.0.0.0
- Updated script to be compatible with newer versions (Studio 2021, Studio 2022 and Studio 2024)
- Added the ToolkitInitializer Module to load all the modules in one function
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
