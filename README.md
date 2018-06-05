﻿PowerShell Toolkit
==================

## Introduction
The SDL PowerShell Toolkit allows to script the [Project Automation API](http://producthelp.sdl.com/SDK/ProjectAutomationApi/3.0/html/b986e77a-82d2-4049-8610-5159c55fddd3.htm) that is available with SDL Trados Studio Professional.  In order to use the Project Automation API via the SDL PowerShell Toolkit , a Professional license for SDL Trados Studio is required.
PowerShell 2.0 comes pre-installed on Windows 7. On Windows XP, you may need to manually install PowerShell if it is not already installed.

## Structure
The PowerShell Toolkit consists of 4 modules
- `GetGuids`
- `PackageHelper`
- `ProjectHelper`
- `TMHelper`

and a `Sample_Roundtrip.ps1` sample script which contains examples to create translation memories, projects and packages.

## Installation
1. Ensure SDL Trados Studio with a professional license is installed.
2. Create the following 2 folders:
    - `C:\users\{your_user_name}\Documents\windowspowershell`
    - `C:\users\{your_user_name}\Documents\windowspowershell\modules`
3. Copy the `Sample_Roundtrip.ps1` into `windowspowershell` folder
4. Copy the four PowerShell module folders into `modules` folder:
    - `....\windowspowershell\modules\GetGuids`
    - `....\windowspowershell\modules\PackageHelper`
    - `....\windowspowershell\modules\ProjectHelper`
    - `....\windowspowershell\modules\TMHelper`
5. Open the PowerShell **(x86)** command prompt (since SDL Trados Studio is a 32-bit application) 
6. Before running script make sure the `$StudioVersion` parameter in the modules corresponds to version of Studio you are using *("Studio4" for Studio 2015, "Studio5" for Studio 2017)* 

## Sample script usage
1. In the script, ensure the paths to the files to be processed match your directory structure.
2. Open a PowerShell command prompt as Administrator
3. Change to the directory where your script is located:
e.g. `C:\users\{your_user_name}\Documents\windowspowershell`
4. Ensure you have rights to run the script. You may first need to enter the following command:
`Set-ExecutionPolicy remotesigned`
5. Run your script: type `.\Sample_Roundtrip` and press enter

## Contribution
If you want to add a new functionality or you spot a bug please fill free to create a [pull request](http://www.codenewbie.org/blogs/how-to-make-a-pull-request) with your changes.

## Issues
If you find an issue you report it [here](https://github.com/sdl/Sdl-studio-powershell-toolkit/issues).

## Changes
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
