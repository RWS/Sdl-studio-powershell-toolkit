$scriptPath = $MyInvocation.MyCommand.Path
$scriptParentDiv = Split-Path $scriptPath -Parent;
$modulesPath = Split-Path $scriptParentDiv -Parent;

$global:moduleNames = @()
$defaultModules = @(
    "GetGuids"
    "PackageHelper",
    "ProjectHelper",
    "ProjectServerHelper",
    "ProvidersHelper",
    "TMHelper",
    "TMServerHelper",
    "UserManagerHelper"
)

<#
    .SYNOPSIS
    Imports all necessary or specified modules from the Modules folder.

    .DESCRIPTION
    The `Import-ToolkitModules` function loads the required types and dependencies of the specified modules and exports their functions globally. By default, it loads all modules for the specified Trados Studio version. It also allows for loading only specified modules if provided. Additionally, it allows specifying a secret vault name to be used for certain modules requiring credential access.

    .PARAMETER StudioVersion
    Represents the version of Trados Studio that the user is using. For example, "Studio17" for Studio 2022, "Studio18" for Studio 2024 or "Studio19" for Studio 2026. The default value is "Studio18". Users can change this parameter to match the version of Trados Studio they are using.
    Trados Studio 2022 and 2024 are 32-bit applications and require PowerShell 5 (x86). Trados Studio 2026 and later are 64-bit applications and require PowerShell 5 (x64).

    .PARAMETER vaultName
    Specifies the name of the Secret Vault to be used for credentials in modules that require access to stored secrets. The default value is "LocalSecretStore". This parameter is passed to modules that handle credentials.

    .EXAMPLE
    Import-ToolkitModules

    Loads all modules and their dependencies for the default version of Trados Studio. The default version is "Studio18", and the default vault is "LocalSecretStore".

    .EXAMPLE
    Import-ToolkitModules -StudioVersion "Studio18"

    Loads all modules and their dependencies for Trados Studio 2024, identified by the version name "Studio18", using the default vault "LocalSecretStore".

    .EXAMPLE
    Import-ToolkitModules -StudioVersion "Studio17" -vaultName "CustomVault"

    Loads all modules for Trados Studio 2022 (Studio17) and uses a custom secret vault called "CustomVault" for credential-based modules.

    .EXAMPLE
    Import-ToolkitModules -StudioVersion "Studio19"

    Loads all modules and their dependencies for Trados Studio 2026 (Studio19). Must be run from PowerShell 5 (x64).

    .OUTPUTS
    None
    The function does not return any output but imports modules globally for use.
#>
function Import-ToolkitModules {
    param (
        [String] $StudioVersion = "Studio18", 
        [String] $vaultName)

    if ($(Test-PSVersion $StudioVersion) -eq $false)
    {
        if (Test-Is64BitStudio $StudioVersion)
        {
            Write-Host "Please use PowerShell 5 (x64) for Trados Studio 2026 or later ($StudioVersion)." -ForegroundColor Green
        }
        else
        {
            Write-Host "Please use PowerShell 5 (x86) for Trados Studio 2024 or earlier ($StudioVersion)." -ForegroundColor Green
        }
        exit;
    }

    Add-Dependencies $StudioVersion

    foreach ($moduleName in $defaultModules)
    {
        if ($moduleName -eq "ProvidersHelper")
        {
            if ($vaultName)
            {
                Install-SecretModules;
                Import-Module -Name "$modulesPath\$moduleName" -ArgumentList $vaultName -Scope Global
                $global:moduleNames += $moduleName;
            }
        }
        else {
            Import-Module -Name "$modulesPath\$moduleName" -ArgumentList $StudioVersion -Scope Global
            $global:moduleNames += $moduleName;
        }

    }

    $tempTM = "$scriptParentDiv\tmp.sdltm"
    $null = New-FileBasedTM "$scriptParentDiv\tmp.sdltm" "en-US" "fr-FR"
    Remove-Item $tempTM;
}

<#
    .SYNOPSIS
    Removes all the modules that were loaded as part of the Trados Powershell Toolkit, except for the ToolkitInitializer.

    .DESCRIPTION
    This function removes all modules that were imported into the PowerShell session as part of the Trados Powershell Toolkit. It will not remove the ToolkitInitializer module. The function clears the list of module names stored in the `$global:moduleNames` variable.

    .EXAMPLE
    Remove-ToolkitModules

    Removes all modules that were loaded as part of the Trados Powershell Toolkit and clears the global module names list.

    .OUTPUTS
    None
    The function does not return any output but will remove the specified modules from the PowerShell session.
#>
function Remove-ToolkitModules {
    foreach ($moduleName in $global:moduleNames)
    {
        Remove-Module -Name $moduleName;
    }

    $global:moduleNames = @();
}

function Install-SecretModules {
    # Define the required modules
    $requiredModules = @(
        "Microsoft.PowerShell.SecretManagement",
        "Microsoft.PowerShell.SecretStore"
    )
    
    foreach ($module in $requiredModules) {
        # Check if the module is installed
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-Host "Module $module is not installed. Installing now..." -ForegroundColor Yellow
            try {
                Install-Module -Name $module -Force -Scope CurrentUser -AllowClobber
                Write-Host "Successfully installed $module." -ForegroundColor Green
            } catch {
                Write-Host "Failed to install $module. Error: $_" -ForegroundColor Red
            }
        }
    }
}

function Add-Dependencies {
    param([String] $StudioVersion)

    $assemblyResolverPath = $scriptParentDiv + "\DependencyResolver.dll"
    # Trados Studio 2026 (Studio19) and later are 64-bit and install under Program Files; earlier versions are 32-bit
    if ((Test-Is64BitStudio $StudioVersion) -eq $false -and "${Env:ProgramFiles(x86)}") {
        $ProgramFilesDir = "${Env:ProgramFiles(x86)}"
    }
    else {
        $ProgramFilesDir = "${Env:ProgramFiles}"
    }

    $appPath = "$ProgramFilesDir\Trados\Trados Studio\$StudioVersion\"

    if ($(Test-Path -Path $appPath -PathType Container) -eq $false)
    {
        throw "Trados Studio installation folder not found: $appPath. Check the StudioVersion parameter (Studio17 = 2022, Studio18 = 2024, Studio19 = 2026)."
    }

    # Solve dependency conficts
    Add-Type -Path $assemblyResolverPath;
    $assemblyResolver = New-Object DependencyResolver.AssemblyResolver("$appPath\");
    $assemblyResolver.Resolve();

    Add-Type -Path "$appPath\Sdl.ProjectAutomation.FileBased.dll"
    Add-Type -Path "$appPath\Sdl.ProjectAutomation.Core.dll"
    Add-Type -Path "$appPath\Sdl.LanguagePlatform.TranslationMemory.dll"
    Add-Type -Path "$appPath\Sdl.FileTypeSupport.Framework.Core.Utilities.dll"
    Add-Type -Path "$appPath\Sdl.ProjectAutomation.Settings.dll"
    Add-Type -Path "$appPath\Sdl.Desktop.Platform.ServerConnectionPlugin.dll"
    Add-Type -Path "$appPath\Sdl.LanguageCloud.IdentityApi.dll";

    # Trados Studio 2026 and later use NLog and no longer ship Sdl.Desktop.Logger.dll; only the log4net based versions need this workaround
    $log4netPath = "$appPath\Sdl.Desktop.Logger.dll"
    if (Test-Path -Path $log4netPath -PathType Leaf)
    {
        Resolve-Log4Net $log4netPath
    }
}

function Resolve-Log4Net {
    param ([String] $assemblyPath)

    Add-Type -Path $assemblyPath;
    $assembly = [System.Reflection.Assembly]::LoadFrom($assemblyPath)

    $internalClassType = $assembly.GetType("Sdl.Desktop.Logger.Log4NetLogger");
    $field = $internalClassType.GetField('Log4netInitialized', 'NonPublic, Static')
    $field.SetValue($false, $true);
}

function Test-PSVersion
{
    param([String] $StudioVersion)

    $isPS5 = $Psversiontable.PSVersion.Major -eq 5
    $is86x = [System.IntPtr]::Size -eq 4

    # The PowerShell process must match the bitness of the Studio assemblies it loads
    if (Test-Is64BitStudio $StudioVersion)
    {
        return $isPS5 -and -not $is86x;
    }

    return $isPS5 -and $is86x;
}

# Extracts the numeric part of the version folder name, e.g. "Studio19" -> 19
function Get-StudioVersionNumber
{
    param([String] $StudioVersion)

    $number = $StudioVersion -replace '\D', ''
    if ($number -eq '')
    {
        return 0;
    }

    return [int] $number;
}

# Trados Studio 2026 (Studio19) is the first 64-bit version
function Test-Is64BitStudio
{
    param([String] $StudioVersion)

    return $(Get-StudioVersionNumber $StudioVersion) -ge 19;
}

Export-ModuleMember Import-ToolkitModules
Export-ModuleMember Remove-ToolkitModules