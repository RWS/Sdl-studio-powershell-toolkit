param ([String] $studioVersion)

<#
    .SYNOPSIS
    Returns an array of GUIDs corresponding to the specified project files.

    .DESCRIPTION
    Takes an array of project files and extracts their GUIDs. The function returns an array of GUIDs, where each GUID represents the identifier of a project file.

    .PARAMETER files
    An array of project files for which the GUIDs are to be retrieved. The files must be of type `[Sdl.ProjectAutomation.Core.ProjectFile]`.

    .EXAMPLE
    Get-Guids -files ([Sdl.ProjectAutomation.Core.ProjectFile[]] filesToGetGuids)
    
    Retrieves the GUIDs of the specified project files in the `filesToGetGuids` array and returns them as an array of GUIDs.

    .OUTPUTS
    [System.Guid[]]
    An array of GUIDs representing the identifiers of the specified project files.
#>
function Get-Guids
{
	param(
        [Parameter(Mandatory=$true)]
        [Sdl.ProjectAutomation.Core.ProjectFile[]] $files)

	[System.Guid[]] $guids = New-Object System.Guid[] ($files.Count);
	$i = 0;
	foreach($file in $files)
	{
		$guids.Set($i,$file.Id);
		$i++;
	}
	
	return $guids
}
 
Export-ModuleMember Get-Guids 

