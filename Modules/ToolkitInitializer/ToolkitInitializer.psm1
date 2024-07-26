$scriptPath = $MyInvocation.MyCommand.Path
$scriptParentDiv = Split-Path $scriptPath -Parent;
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
    param ([String] $StudioVersion = "Studio18",
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
        Import-Module -Name $moduleName -ArgumentList $StudioVersion -Scope Global
    }
}

<#
    .SYNOPSIS
    Remove all the used modules

    .DESCRIPTION
    Removes all the modules the user has loaded that are part of the Trados Powershell Toolkit except the ToolkitInitializer

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

    $assemblyResolverPath = $scriptParentDiv + "\DependencyResolver.dll"
    if ("${Env:ProgramFiles(x86)}") {
        $ProgramFilesDir = "${Env:ProgramFiles(x86)}"
    }
    else {
        $ProgramFilesDir = "${Env:ProgramFiles}"
    }

    $appPath = "$ProgramFilesDir\Trados\Trados Studio\$StudioVersion\"

    Add-CustomTypes
    # Solve dependency conficts
    Add-Type -Path $assemblyResolverPath;
    $assemblyResolver = New-Object DependencyResolver.AssemblyResolver("$appPath\");
    $assemblyResolver.Resolve();

    Add-Type -Path "$appPath\Sdl.ProjectAutomation.FileBased.dll"
    Add-Type -Path "$appPath\Sdl.ProjectAutomation.Core.dll"
    Add-Type -Path "$appPath\Sdl.LanguagePlatform.TranslationMemory.dll"
    Add-Type -Path "$appPath\Sdl.FileTypeSupport.Framework.Core.Utilities.dll"
    Add-Type -Path "$appPath\Sdl.ProjectAutomation.Settings.dll"
}

function Add-CustomTypes {
    Add-Type -TypeDefinition @'
	using System;
	using System.Reflection;

    public static class ReflectionHelper
    {
        public static void CallEnsurePluginRegistryIsCreated(Type fileBasedProjectType)
        {
            // Get the MethodInfo object for the private static method using BindingFlags
            MethodInfo methodInfo = fileBasedProjectType.GetMethod(
                "EnsurePluginRegistryIsCreated",
                BindingFlags.NonPublic | BindingFlags.Static);
 
            // Ensure the method has been found
            if (methodInfo == null)
            {
                throw new InvalidOperationException("Could not find the method EnsurePluginRegistryIsCreated");
            }
 
            // Invoke the private static method
            methodInfo.Invoke(null, null);
        }
    }
'@
Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Management.Automation.Runspaces;

public class RunspacedDelegateFactory
{
    public static Delegate NewRunspacedDelegate(Delegate _delegate, Runspace runspace)
    {
        Action setRunspace = () => Runspace.DefaultRunspace = runspace;

        return ConcatActionToDelegate(setRunspace, _delegate);
    }

    private static Expression ExpressionInvoke(Delegate _delegate, params Expression[] arguments)
    {
        var invokeMethod = _delegate.GetType().GetMethod("Invoke");

        return Expression.Call(Expression.Constant(_delegate), invokeMethod, arguments);
    }

    public static Delegate ConcatActionToDelegate(Action a, Delegate d)
    {
        var parameters =
            d.GetType().GetMethod("Invoke").GetParameters()
            .Select(p => Expression.Parameter(p.ParameterType, p.Name))
            .ToArray();

        Expression body = Expression.Block(ExpressionInvoke(a), ExpressionInvoke(d, parameters));

        var lambda = Expression.Lambda(d.GetType(), body, parameters);

        var compiled = lambda.Compile();

        return compiled;
    }
}
'@

Add-Type -TypeDefinition @'
using System;

namespace TMProvider
{
	public class MemoryResource
	{
		public string Path { get; set; }

		public Uri Uri { get; set; }

		public Uri UriSchema { get; set; }

		public string UserNameOrClientId { get; set; }

		public string UserPasswordOrClientSecret { get; set; }

		public bool IsWindowsUser { get; set; }

		public string TargetLanguageCode { get; set; }
	}
}
'@
}

Export-ModuleMember Import-ToolkitModules
Export-ModuleMember Remove-ToolkitModules