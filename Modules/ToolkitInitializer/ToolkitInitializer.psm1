$scriptPath = $MyInvocation.MyCommand.Path
$scriptParentDiv = Split-Path $scriptPath -Parent;
$scriptParentDiv = Split-Path $scriptParentDiv -Parent;
$global:moduleNames = @()
$defaultModules = @(
    "TMHelper",
    "ProjectHelper",
    "PackageHelper",
    "GetGuids"
)

<#
    .SYNOPSIS
    Import all the necessary or given modules from the Modules folder.

    .DESCRIPTION
    Loads all the types and dependencies together with the modules and export their functions globally.
    Additionally it can load only the given modules

    .PARAMETER StudioVersion
    Represents the Version of the Studio the user is using | Studio17 for Studio 2022, Studio18 for Studio 2024
    The User can change its default value to the Trados Studio version he/she is using.

    .PARAMETER Modules
    Optional. Represents the module names to load into the powershell session.

    .EXAMPLE
    Import-ToolkitModules

    Loads all the modules and the depedencies on the default version. User can change this to the used Trados Studio version

    Import-ToolkitModules -StudioVersion "Studio16"

    Loads all the modules and the dependencies for the Studio 2021 (Studio16 version name).

    Import-ToolkitModules -StudioVersion "Studio16" -Modules @("GetGuids")

    Loads all the dependencies and only the GetGuids modules for the Studio 2021 (STudio16 version name).

    Import-ToolkitModules -Modules@("GetGuids")

    Loads all the dependencies only for the GetGuids module for the default Studio Version.
#>
function Import-ToolkitModules {
    param ([String] $StudioVersion = "Studio18Beta",
    [String[]] $Modules = @())

    Add-Dependencies $StudioVersion

    if ($Modules.Count -ne 0)
    {
        $global:moduleNames = $Modules;
    }
    else {
        $global:moduleNames = $defaultModules;
    }

    foreach ($moduleName in $global:moduleNames)
    {
        Import-Module "$scriptParentDiv\$moduleName" -Scope Global
    }
}

<#
    .SYNOPSIS
    Remove all the used modules

    .DESCRIPTION
    Removes all the modules the user has loaded that are part of the SDL Toolkit

    .EXAMPLE
    Remove-ToolkitModules
#>
function Remove-ToolkitModules {
    foreach ($moduleName in $global:moduleNames)
    {
        Remove-Module -Name $moduleName;
    }

    $global:moduleNames = @();
}

function Add-Dependencies {
    param([String] $StudioVersion)

    $assemblyResolverPath = $scriptParentDiv + "\ToolkitInitializer\DependencyResolver.dll"
    $versionNumber = [regex]::Match($StudioVersion, "\d+").Value;

    if ("${Env:ProgramFiles(x86)}") {
        $ProgramFilesDir = "${Env:ProgramFiles(x86)}"
    }
    else {
        $ProgramFilesDir = "${Env:ProgramFiles}"
    }

    if ($versionNumber -le 16)
    {
        $appPath = "$ProgramFilesDir\Sdl\Sdl Trados Studio\$StudioVersion\"
    }
    else {
        $appPath = "$ProgramFilesDir\Trados\Trados Studio\$StudioVersion\"
    }

    # Solve dependency conficts
    Add-Type -Path $assemblyResolverPath;
    $assemblyResolver = New-Object DependencyResolver.AssemblyResolver("$appPath\");
    $assemblyResolver.Resolve();

    Add-Type -Path "$appPath\Sdl.ProjectAutomation.FileBased.dll"
    Add-Type -Path "$appPath\Sdl.ProjectAutomation.Core.dll"
    Add-Type -Path "$appPath\Sdl.LanguagePlatform.TranslationMemory.dll"
}

Export-ModuleMember Import-ToolkitModules
Export-ModuleMember Remove-ToolkitModules