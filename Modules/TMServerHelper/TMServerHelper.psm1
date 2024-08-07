param ($StudioVersion)

<#
.SYNOPSIS
Connects to a TM Server using provided server address and credentials.

.DESCRIPTION
The `Get-TMServer` function establishes a connection to a Translation Memory (TM) Server using the specified server address, username, and password. It creates and returns a `TranslationProviderServer` object that can be used to interact with the TM Server.

.PARAMETER serverAddress
The URL of the TM Server. This should be the base address where the TM Server is hosted.

.PARAMETER userName
The username used to authenticate with the TM Server.

.PARAMETER password
The password used to authenticate with the TM Server.

.EXAMPLE
PS C:\> $tmServer = Get-TMServer "http://localhost/" "sa" "sa"

This example connects to a TM Server hosted at "http://localhost/" using the username "sa" and password "sa", and stores the resulting `TranslationProviderServer` object in the `$tmServer` variable.

.NOTES
If the provided credentials are not valid, the functions that are dependent on this returned instance will throw an unauthorized error.

.OUTPUTS
[Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer]
The TranslationProviderServer instance responsible for manipulating TM related resources.
#>
function Get-TMServer
{
	param(
        [Parameter(Mandatory=$true)]
		[String] $serverAddress,

        [Parameter(Mandatory=$true)]
		[String] $userName,

		[Parameter(Mandatory=$true)]
		[String] $password)
		
	$uri = New-Object System.Uri ($serverAddress);

	try {
		$tmServer = New-Object Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer ($uri,$false,$userName,$password);
		$null = $tmServer.GetDatabaseServers();
		return $tmServer
	}
	catch 
	{
		write-host "Invalid server or credentials" -ForegroundColor Green
	}
}

<#
.SYNOPSIS
Returns all database servers associated with a TM Server.

.DESCRIPTION
The `Get-DbServers` function retrieves a list of all database servers that are associated with a given TM Server. It returns these database servers as a collection of `DatabaseServer` objects.

.PARAMETER server
The `TranslationProviderServer` object representing the TM Server. This object is used to query and retrieve associated database servers.

.EXAMPLE
PS C:\> $tmServer = Get-TMServer "http://localhost/" "sa" "sa"
PS C:\> $dbServers = Get-DbServers -server $tmServer

This example first connects to a TM Server at "http://localhost/" using the username "sa" and password "sa", and then retrieves all database servers associated with this TM Server. The result is stored in the `$dbServers` variable.

.OUTPUTS
[DatabaseServer[]]
Returns an array of DatabaseServer instances representing the existing Database servers form the Groupshare.
#>
function Get-DbServers
{
	param(
		[Parameter(Mandatory=$true)]
		[Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer] $server)

	return $server.GetDatabaseServers();
}

<#
.SYNOPSIS
Returns all containers associated with a TM Server.

.DESCRIPTION
The `Get-Containers` function retrieves a list of all containers associated with the specified TM Server. The containers represent organizational units within the TM Server where translation memories and other resources are stored.

.PARAMETER server
The `TranslationProviderServer` object representing the TM Server. This object is used to query and retrieve the associated containers.

.PARAMETER organizationPath
(Optional) The organization path can be provided to only return the containers that are within the provided organization.

.PARAMETER includeSubOrganizations
(Optional) A boolean value indicating whether to include the containers that exists within the suborganization. 
This parameter can be applied when the path parameter is provided.
The Default value is false.

.EXAMPLE
PS C:\> $tmServer = Get-TMServer "http://localhost/" "sa" "sa"
PS C:\> $containers = Get-Containers -server $tmServer

This example first connects to a TM Server at "http://localhost/" using the username "sa" and password "sa", and then retrieves all containers associated with this TM Server. The result is stored in the `$containers` variable.

.OUTPUTS
[TranslationMemoryContainer[]]
This function returns an array of TranslationMemoryContainer instances representing existing containers found.
#>
function Get-Containers
{
	param(
		[Parameter(Mandatory=$true)]
		[Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer] $server,
		
		[String] $organizationPath,
		[Bool] $includeSubOrganizations = $false)

	$containers = $server.GetContainers()

	if ($organizationPath -ne "")
	{
		if ($includeSubOrganizations)
		{
			$containers = $containers | Where-Object {$_.ParentResourceGroupPath -like "$organizationPath*"}
		}
		else 
		{
			$containers = $containers | Where-Object {$_.ParentResourceGroupPath -eq $organizationPath }
		}
	}

	return $containers;
}

<#
.SYNOPSIS
Retrieves server-based Translation Memories (TMs) from a specified TM Server.

.DESCRIPTION
The `Get-ServerbasedTMs` function queries a TM Server for Translation Memories (TMs). It allows filtering TMs based on the specified organization and optionally includes TMs from sub-organizations. Additionally, it supports limiting the number of TMs returned.

.PARAMETER server
The `TranslationProviderServer` object representing the TM Server to query. This object is used to interact with the TM Server and retrieve the Translation Memories.

.PARAMETER organizationPath
(Optional) Represents the path as a string for the translatino memory. If this parameter is not provided the function will return all the existing server-based translation memories.

.PARAMETER includeSubOrganizations
(Optional) A Boolean value indicating whether to include TMs from sub-organizations of the specified organization. The default value is `$false`. Set to `$true` to include TMs from sub-organizations.

.PARAMETER limit
(Optional) An integer specifying the maximum number of TMs to return. The default value is `20`. Use this parameter to limit the number of TMs retrieved.

.EXAMPLE
# Connect to a TM Server
$tmServer = Get-TMServer "http://localhost/" "sa" "sa"


# Retrieve all TMs within the organization and its sub-organizations, with a limit of 50
$tms = Get-ServerbasedTMs -server $tmServer -organizationPath "/" -includeSubOrganizations $false -limit 50

This example demonstrates how to connect to a TM Server, retrieve a specified organization, and then get up to 50 TMs within the root organization only.

.OUTPUTS
[ServerBasedTranslationMemory[]]
This function returns an array of ServerBasedTranslationMemory instances representing the found Server based translation memories.
#>
function Get-ServerbasedTMs
{
	param(
		[Parameter(Mandatory=$true)]
		[Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer] $server,

		[String] $organizationPath,
		[Bool] $includeSubOrganizations = $false,
		[int] $limit = 20)
	
	if ($organizationPath)
	{
		$query = New-Object Sdl.LanguagePlatform.TranslationMemoryApi.TranslationMemoryQuery;
		$query.Size = $limit;
		$query.ResourceGroupPath = $organizationPath;
		$query.IncludeChildResourceGroups = $includeSubOrganizations;

		$pagedTMs = $server.GetTranslationMemoriesByQuery($query);
		return $pagedTMs.TranslationMemories;
	}

	return $server.GetTranslationMemories();
}

<#
.SYNOPSIS
Retrieves a container from a TM Server by its path and name.

.DESCRIPTION
The `Get-Container` function queries a Translation Provider Server to retrieve a container based on the specified container path and name. If the container is not found, it handles the error gracefully and returns `$null`.

.PARAMETER server
The `TranslationProviderServer` object that represents the TM Server. This object is used to interact with the TM Server and retrieve the container.

.PARAMETER organizationPath
The path to the container within the TM Server. This is a string that specifies the organizat hierarchy location leading up to the container.

.PARAMETER containerName
The name of the container to retrieve. This string specifies the name of the container you are looking for.

.EXAMPLE
# Connect to a TM Server
$tmServer = Get-TMServer "http://localhost/" "sa" "sa"

# Retrieve a container named "MyContainer" from the specified path
$container = Get-Container -server $tmServer -organizationPath "/MyOrganization/" -containerName "MyContainer"

This example demonstrates how to connect to a TM Server hosted at "http://localhost/" using the username "sa" and password "sa". It then retrieves the container named "MyContainer" from the path "/MyOrganization/". The resulting container object is stored in the `$container` variable.

.EXAMPLE
# Connect to a TM Server
$tmServer = Get-TMServer "http://localhost/" "sa" "sa"

# Attempt to retrieve a container that does not exist
$container = Get-Container -server $tmServer -organizationPath "/MyOrganization/" -containerName "NonExistingContainer"

In this example, the function attempts to retrieve a container named "NonExistingContainer" from the TM Server at the path "/MyOrganization/". Since the container does not exist, the function returns `$null`.

.OUTPUTS
[TranslationMemoryContainer]
Returns the found TranslationMemoryContainer instance or null if it was not found.
#>
function Get-Container
{
	param(
		[Parameter(Mandatory=$true)]
		[Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer] $server,

		[Parameter(Mandatory=$true)]
		[String] $organizationPath,

		[Parameter(Mandatory=$true)]
		[String] $containerName)
	
	try 
	{
		return $server.GetContainer($($organizationPath + $containerName))
	}
	catch 
	{
		Write-Host "Container Not found" -ForegroundColor Green;
		return $null;
	}
}

<#
.SYNOPSIS
Creates a new container in the TM Server with specified parameters.

.DESCRIPTION
The `New-Container` function creates a new translation memory container in the TM Server using the provided server, database server, container name, and database name. If the container cannot be created due to invalid parameters or if it already exists, an error message is displayed.

.PARAMETER server
The `TranslationProviderServer` object that represents the TM Server. This object is used to create and save the new container.

.PARAMETER dbServer
The `DatabaseServer` object that represents the database server where the container will be stored. This object is used to specify the database for the new container.

.PARAMETER containerName
The name of the container to create. This string specifies the name that the new container will have.

.PARAMETER databaseName
The name of the database where the container will be created. This string specifies the database to associate with the new container.
This string must not include whitespaces.

.EXAMPLE
# Connect to a TM Server and a Database Server
$tmServer = Get-TMServer "http://localhost/" "sa" "sa"
$dbServers = Get-DBServer $tmServer
$dbServer = $dbServers[0]

# Create a new container named "MyNewContainer" in the specified database
$newContainer = New-Container -server $tmServer -dbServer $dbServer -containerName "MyNewContainer" -databaseName "MyDatabase"

This example demonstrates how to connect to a TM Server and a Database Server, then create a new container named "MyNewContainer" in the database "MyDatabase". The resulting container object is retrieved and stored in the `$newContainer` variable.

.EXAMPLE
# Connect to a TM Server and a Database Server
$tmServer = Get-TMServer "http://localhost/" "sa" "sa"
$dbServers = Get-DBServer $tmServer
$dbServer = $dbServers[0]

# Attempt to create a container that already exists
$newContainer = New-Container -server $tmServer -dbServer $dbServer -containerName "ExistingContainer" -databaseName "MyDatabase"

In this example, the function attempts to create a container named "ExistingContainer" in the database "MyDatabase". If a container with this name already exists or if there are invalid parameters, the function will display an error message and will not create the container.

.OUTPUTS
[TranslationMemoryContainer]
This function returns the TranslationMemoryContainer representing the newly created container or null if a container already exists or if the provided parameters are invalid.
#>
function New-Container 
{
	param(
		[Parameter(Mandatory=$true)]
		[Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer] $server,

		[Parameter(Mandatory=$true)]
		[Sdl.LanguagePlatform.TranslationMemoryApi.DatabaseServer] $dbServer,

		[Parameter(Mandatory=$true)]
		[String] $containerName,

		[Parameter(Mandatory=$true)]
		[String] $databaseName)

	$container = New-Object Sdl.LanguagePlatform.TranslationMemoryApi.TranslationMemoryContainer ($server);
	$container.DatabaseServer = $dbServer;
	$container.DatabaseName = $databaseName;
	$container.Name = $containerName
	$container.ParentResourceGroupPath = $dbServer.ParentResourceGroupPath;

	try {
		$container.Save()
		return $container;
	}
	catch {
		Write-Host "Invalid parameters or container already exists" -ForegroundColor Green;
	}
}

<#
.SYNOPSIS
Retrieves a server-based Translation Memory (TM) from a specified TM server.

.DESCRIPTION
The `Get-ServerBasedTM` function connects to a Translation Provider Server and retrieves a server-based Translation Memory (TM) based on the provided path and name. It uses the `GetTranslationMemory` method to fetch the TM object, specifying `TranslationMemoryProperties.None` to optimize the retrieval process.

.PARAMETER server
The `TranslationProviderServer` object representing the TM server from which to retrieve the TM. This object is used to access the TM server's methods and properties.

.PARAMETER tmPath
The path within the TM server where the TM is located. This string specifies the directory or location of the TM on the server.

.PARAMETER tmName
The name of the Translation Memory to retrieve. This string specifies the name of the TM within the specified path.

.RETURN
Returns a `ServerBasedTranslationMemory` object representing the Translation Memory retrieved from the server. This object provides access to the TM's data and methods.

.EXAMPLE
# Assume $server is a valid TranslationProviderServer object
$tm = Get-ServerBasedTM -server $server -tmPath "/MyTMs" -tmName "MyTranslationMemory"

This example retrieves the Translation Memory named "MyTranslationMemory" located at "/MyTMs" on the TM server represented by `$server`, and stores the resulting TM object in the `$tm` variable.

.OUTPUTS
[ServerBasedTranslationMemory]
Returns the ServerBasedTranslationMemory instance representing the found Server-based translation memory or null if not found.
#>
function Get-ServerBasedTM
{
	param(
		[Parameter(Mandatory=$true)]
		[Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer] $server,

		[Parameter(Mandatory=$true)]
		[String] $tmPath,

		[Parameter(Mandatory=$true)]
		[System.String] $tmName)

	#consider using TranslationMemoryProperties enum properly to speed up the processing, you would like to avoid getting properties one by one
	[Sdl.LanguagePlatform.TranslationMemoryApi.ServerBasedTranslationMemory]$tm = $server.GetTranslationMemory($tmPath + "/" + $tmName,
	[Sdl.LanguagePlatform.TranslationMemoryApi.TranslationMemoryProperties]::None);
	
	return $tm;
}

<#
.SYNOPSIS
Creates a new server-based Translation Memory (TM) on a specified Translation Provider Server.

.DESCRIPTION
The `New-ServerBasedTM` function initializes and saves a new server-based Translation Memory (TM) on the specified TM server. It requires a `TranslationProviderServer` object, a `TranslationMemoryContainer`, and various TM properties such as name, source language, and target language. The function also sets up the language direction for the TM and attempts to save it to the server.

.PARAMETER server
The `TranslationProviderServer` object representing the TM server where the new TM will be created. This object provides access to server operations and methods.

.PARAMETER container
The `TranslationMemoryContainer` object representing the container in which the new TM will be created. The container provides context and organizational structure for the TM.

.PARAMETER tmName
The name of the new Translation Memory to be created. This string specifies the name that will be assigned to the TM.

.PARAMETER sourceLanguage
The language code representing the source language of the Translation Memory. This string specifies the source language from which translations will be made.

.PARAMETER targetLanguages
The language code representing the target languages of the Translation Memory. This string specifies the target languages into which translations will be made.

.RETURN
This function does not return a value directly. Instead, it creates and saves a new server-based Translation Memory on the specified server. If the operation fails, an error message is printed.

.EXAMPLE
# Assume $server is a valid TranslationProviderServer object and $container is a valid TranslationMemoryContainer object
New-ServerBasedTM -server $server -container $container -tmName "MyNewTranslationMemory" -sourceLanguage "en-EN" -targetLanguage "fr-FR"

This example creates a new Translation Memory named "MyNewTranslationMemory" in the specified container, with "en-US" (English - United States) as the source language and "de-DE" (Ger,am) as the target language. The TM is created on the server represented by `$server`.

.OUTPUTS
[ServerBasedTranslationMemory]
Returns the newly created Server based translation memory represente as a ServerBasedTranslationMemory instance.
#>
function New-ServerBasedTM 
{
	param(
		[Parameter(Mandatory=$true)]
		[Sdl.LanguagePlatform.TranslationMemoryApi.TranslationProviderServer] $server,

		[Parameter(Mandatory=$true)]
		[Sdl.LanguagePlatform.TranslationMemoryApi.TranslationMemoryContainer] $container,

		[Parameter(Mandatory=$true)]
		[System.String] $tmName,

		[Parameter(Mandatory=$true)]
		[String] $sourceLanguage,

		[Parameter(Mandatory=$true)]
		[String[]] $targetLanguages) 

	$tm = New-Object Sdl.LanguagePlatform.TranslationMemoryApi.ServerBasedTranslationMemory($server);

	$tm.Container = $container;
	$tm.Name = $tmName;
	$tm.ParentResourceGroupPath = $container.ParentResourceGroupPath;

	$tmDirection = New-Object Sdl.LanguagePlatform.TranslationMemoryApi.ServerBasedTranslationMemoryLanguageDirection($null);

	$cultureSource = Get-Language $sourceLanguage;

	if ($null -eq $cultureSource)
	{
		Write-Host "Invalid source language" -ForegroundColor Green
		return;
	}

	$cultureTargets = Get-Languages $targetLanguages;
	if ($null -eq $cultureTargets)
	{
		Write-Host "Invalid target languages" -ForegroundColor Green
		return;
	}

	foreach ($target in $cultureTargets)
	{
		$tmDirection = New-Object Sdl.LanguagePlatform.TranslationMemoryApi.ServerBasedTranslationMemoryLanguageDirection($null);
		$tmDirection.SourceLanguage = $cultureSource
		$tmDirection.TargetLanguage = $target;
		$tm.LanguageDirections.Add($tmDirection)
	}

	$tm.Save();
	return $tm;
}

<#
.SYNOPSIS
Deletes a specified server-based Translation Memory (TM).

.DESCRIPTION
The `Remove-TM` function deletes a server-based Translation Memory (TM) from the Translation Provider Server. It requires an existing `ServerBasedTranslationMemory` object representing the TM to be deleted. Once the function is executed, the specified TM is removed from the server.

.PARAMETER tmToDelete
A `ServerBasedTranslationMemory` object representing the TM that you want to delete. This object must be an existing TM on the server that you wish to remove.

.EXAMPLE
# Assume $tm is a valid ServerBasedTranslationMemory object that you want to delete
Remove-TM -tmToDelete $tm

This example deletes the Translation Memory represented by the `$tm` object from the server.
#>
function Remove-ServerBasedTM
{
	param(
		[Parameter(Mandatory=$true)]
		[Sdl.LanguagePlatform.TranslationMemoryApi.ServerBasedTranslationMemory] $tmToDelete)

	try 
	{
		$tmToDelete.Delete();
	}
	catch 
	{
		Write-Host "Translation Memory has been removed already" -ForegroundColor Green;
	}
}

<#
.SYNOPSIS
Deletes a specified Translation Memory container. Optionally, the associated database can be deleted if specified.

.DESCRIPTION
The `Remove-Container` function deletes a Translation Memory container from the server. It requires a `TranslationMemoryContainer` object representing the container you want to delete. This function calls the `Delete()` method on the container, which removes the container from the server. Note that this action does not automatically delete the associated database unless explicitly handled in other parts of your script or system.

.PARAMETER containerToDelete
A `TranslationMemoryContainer` object representing the container that you want to delete. This object must be an existing container on the server.

.EXAMPLE
# Assume $container is a valid TranslationMemoryContainer object that you want to delete
Remove-Container -containerToDelete $container

This example deletes the Translation Memory container represented by the `$container` object from the server.
#>
function Remove-Container
{
	param(
		[Parameter(Mandatory=$true)]
		[Sdl.LanguagePlatform.TranslationMemoryApi.TranslationMemoryContainer] $containerToDelete)
	
	try {
		$containerToDelete.Delete();
	}
	catch 
	{
		Write-Host "The container has been removed already" -ForegroundColor Green;
	}
}

<#
.SYNOPSIS
Imports TMX data into a specified Translation Memory (TM).

.DESCRIPTION
The `Import-Tmx` function imports translation units from a TMX file into a specified Server-Based Translation Memory. It allows configuration of various import settings, including how new fields should be handled, the processing mode for translation units (TUs), and whether plain text is used. The function also includes event handling to display import statistics.

.PARAMETER importFilePath
The full path to the TMX file to be imported. This file should be in a valid TMX format.

.PARAMETER serverBasedTM
A `ServerBasedTranslationMemory` object representing the Translation Memory into which the TMX file will be imported. This parameter is required if importing into a server-based TM.

.PARAMETER sourceLanguage
The source language code for the translation memory. This should be a valid language code that corresponds to the source language of the TMX file.

.PARAMETER targetLanguage
The target language code for the translation memory. This should be a valid language code that corresponds to the target language of the TMX file.

.PARAMETER tmPath
The path to a file-based TM if `serverBasedTM` is not provided. This path should point to an existing file-based TM.

.PARAMETER newFieldsOption
Specifies how to handle new fields in the import. Options include `"AddToSetup"` (default) and others as defined in `NewFieldsOption`.
This value can be one of the following:
  AddToSetup,
  Ignore,
  SkipTranslationUnit,
  Error

.PARAMETER importTUProcessingMode
Defines the processing mode for translation units.
The value can be one of the following:
 ProcessCleanedTUOnly,
 ProcessRawTUOnly,
 ProcessBothTUs

.PARAMETER tuUpdateMode
Specifies how to update translation units.
The value can be one of the following:
 AddNew,
 Overwrite,
 LeaveUnchanged,
 KeepMostRecent,
 OverwriteCurrent

.PARAMETER plainText
A Boolean indicating whether the TMX file is in plain text format (`$true` or `$false`). Default is `$false`.

.PARAMETER checkMatchingSubLanguages
A Boolean indicating whether to check for matching sub-languages during import (`$true` or `$false`). Default is `$true`.

.EXAMPLE
Import-Tmx -importFilePath "D:\Location\To\File.tmx" -serverBasedTM $existingServerTM -sourceLanguage "en" -targetLanguage "fr"

This example imports a TMX file located at `D:\Location\To\File.tmx` into the specified server-based translation memory `$existingServerTM`, with English as the source language and French as the target language.
#>
function Import-Tmx
{
	param(
		[Parameter(Mandatory=$true)]
		[System.String] $importFilePath,

		[Sdl.LanguagePlatform.TranslationMemoryApi.ServerBasedTranslationMemory] $serverBasedTM,
		[String] $sourceLanguage,
		[String] $targetLanguage,
		[String] $tmPath,
		[String] $newFieldsOption = "AddToSetup",
		[String] $importTUProcessingMode = "ProcessCleanedTUOnly",
		[String] $tuUpdateMode = "AddNew",
		[Bool] $plainText = $false,
		[Bool] $checkMatchingSubLanguages = $true
		)

	if ($serverBasedTM)
	{
		$languageDirections = $serverBasedTM.LanguageDirections;
		if ($sourceLanguage)
		{
			$languageDirections = $languageDirections | Where-Object { $_.SourceLanguageCode -eq $sourceLanguage }
		}
		if ($targetLanguage)
		{
			$languageDirections = $languageDirections | Where-Object {$_.TargetLanguageCode -eq $targetLanguage }
		}

		if ($languageDirections)
		{
			$languageDirection = $languageDirections[0];
		}
		else 
		{
			return;
		}
	}
	elseif ($null -ne $tmPath -and $tmPath -ne "") {
		$tm = Open-FileBasedTM $tmPath
		$languageDirection = $tm.LanguageDirection
	}
	else 
	{
		return;
	}	

	$importer = New-Object Sdl.LanguagePlatform.TranslationMemoryApi.TranslationMemoryImporter ($languageDirection);
	$settings = $importer.ImportSettings;

	try 
	{
		$fieldsOption = [Sdl.LanguagePlatform.TranslationMemory.ImportSettings+NewFieldsOption]::Parse([Sdl.LanguagePlatform.TranslationMemory.ImportSettings+NewFieldsOption], $newFieldsOption, $true)
		$processingMode = [Sdl.LanguagePlatform.TranslationMemory.ImportSettings+ImportTUProcessingMode]::Parse([Sdl.LanguagePlatform.TranslationMemory.ImportSettings+ImportTUProcessingMode], $importTUProcessingMode, $true)
		$updateMode = [Sdl.LanguagePlatform.TranslationMemory.ImportSettings+TUUpdateMode]::Parse([Sdl.LanguagePlatform.TranslationMemory.ImportSettings+TUUpdateMode], $tuUpdateMode, $true)
		$settings.NewFields = $fieldsOption
		$settings.TUProcessingMode = $processingMode
		$settings.TUProcessingMode = $updateMode
	}
	catch 
	{
		Write-Host "Invalid Fields Options, TU Processing Mode or TU Update Mode" -ForegroundColor Green
		return;
	}

	$settings.PlainText = $plainText;
	$settings.CheckMatchingSublanguages = $checkMatchingSubLanguages;

	$OnBatchImported = [System.EventHandler[Sdl.LanguagePlatform.TranslationMemoryApi.BatchImportedEventArgs]] {
		param (
			[System.Object] $sender,
			[Sdl.LanguagePlatform.TranslationMemoryApi.BatchImportedEventArgs] $e
		)

		$Stats = $e.Statistics
		$TotalRead = $Stats.TotalRead
		$TotalImported = $Stats.TotalImported
		$TotalAdded = $Stats.AddedTranslationUnits
		$TotalOverwritten = $Stats.OverwrittenTranslationUnits
		$TotalDiscarded = $Stats.DiscardedTranslationUnits
		$TotalMerged = $Stats.MergedTranslationUnits
		$TotalErrors = $Stats.Errors
		$TotalBad = $Stats.BadTranslationUnits
		$RawTUs = $Stats.RawTUs
		$Message = "TUs raw: $RawTUs, processed: $TotalRead, imported: $TotalImported (added: $TotalAdded, merged: $TotalMerged, overwritten: $TotalOverwritten), discarded: $TotalDiscarded, errors: $TotalErrors, bad: $TotalBad"
		
		# keep results of each phase on separate line
		if ($TotalRead -lt $script:LastTotal) {
			Write-Host $null
		}

		$script:LastTotal = $TotalRead
		
		# workaround for overwriting longer text with shorter text
		# (this happens because the import may consist of multiple background phases in Studio API)
		$LineLength = $Host.UI.RawUI.WindowSize.Width
		Write-Host "$($Message.PadRight($LineLength - 1))`r" -NoNewLine
	}

	$OnBatchImportedDelegate = [DependencyResolver.RunspacedDelegateFactory]::NewRunspacedDelegate($OnBatchImported, [Runspace]::DefaultRunspace)
	
	if ($serverBasedTM)
	{
		$importer.Import($importFilePath)
	}
	else 
	{
		$importer.Add_BatchImported($OnBatchImportedDelegate)
		$importer.Import($importFilePath)
		$importer.Remove_BatchImported($OnBatchImportedDelegate);		
	}

	Write-Host $null;
}

<#
.SYNOPSIS
Exports a server-based Translation Memory to the specified location.

.DESCRIPTION
The `Export-Tmx` function extracts translation units from an existing Server-Based Translation Memory and saves them to a TMX file at the given export location. The function handles both server-based and file-based translation memories, providing progress updates during the export process.

.PARAMETER exportFilePath
The full path where the TMX file will be saved. This file will contain the exported translation units from the translation memory.

.PARAMETER serverBasedTM
A `ServerBasedTranslationMemory` object representing the translation memory from which data will be exported. This parameter is required if exporting from a server-based translation memory.

.PARAMETER sourceLanguage
The source language code for the translation memory. This field should be filled when the the translation memory used for export is server based.

.PARAMETER targetLanguage
The target language code for the translation memory. This field should be filled when the the translation memory used for export is server based.

.PARAMETER tmPath
The path to a file-based translation memory if `serverBasedTM` is not provided. This should point to an existing file-based translation memory.

.EXAMPLE
Export-Tmx -exportFilePath "D:\Location\To\File.tmx" -serverBasedTM $existingServerTM -sourceLanguage "en" -targetLanguage "fr"

This example exports translation units from the specified server-based translation memory `$existingServerTM` into a TMX file located at `D:\Location\To\File.tmx`, with English as the source language and French as the target language.
#>
function Export-Tmx
{
	param(
		[Parameter(Mandatory=$true)]
		[System.String] $exportFilePath,

		[Sdl.LanguagePlatform.TranslationMemoryApi.ServerBasedTranslationMemory] $serverBasedTM,
		[String] $sourceLanguage,
		[String] $targetLanguage,
		[String] $tmPath
	)

	if ($serverBasedTM)
	{
		$languageDirections = $serverBasedTM.LanguageDirections;
		if ($sourceLanguage)
		{
			$languageDirections = $languageDirections | Where-Object { $_.SourceLanguageCode -eq $sourceLanguage }
		}
		if ($targetLanguage)
		{
			$languageDirections = $languageDirections | Where-Object {$_.TargetLanguageCode -eq $targetLanguage }
		}

		if ($languageDirections)
		{
			$languageDirection = $languageDirections[0];
		}
		else 
		{
			return;
		}
	}
	elseif ($tmPath) {
		$tm = Open-FileBasedTM $tmPath
		$languageDirection = $tm.LanguageDirection;
	}
	else 
	{
		return;
	}

	$exporter = New-OBject Sdl.LanguagePlatform.TranslationMemoryApi.TranslationMemoryExporter($languageDirection)

	$OnBatchExported = [System.EventHandler[Sdl.LanguagePlatform.TranslationMemoryApi.BatchExportedEventArgs]] {
		param (
			[System.Object] $sender,
			[Sdl.LanguagePlatform.TranslationMemoryApi.BatchExportedEventArgs] $e
		)
		$TotalProcessed = $e.TotalProcessed
		$TotalExported = $e.TotalExported
		Write-Host "TUs processed: $TotalProcessed exported: $TotalExported`r" -NoNewLine
	}

	$OnBatchExportedDelegate = [DependencyResolver.RunspacedDelegateFactory]::NewRunspacedDelegate($OnBatchExported, [Runspace]::DefaultRunspace)
	
	if ($serverBasedTM)
	{
		$exporter.Export($exportFilePath, $true);
	}
	else 
	{
		$exporter.Add_BatchExported($OnBatchExportedDelegate)
		$exporter.Export($exportFilePath, $true);
		$exporter.Remove_BatchExported($OnBatchExportedDelegate)
	}

	Write-Host $null;
}

Export-ModuleMember Get-TMServer;
Export-ModuleMember Get-DbServers;
Export-ModuleMember Get-Containers;
Export-ModuleMember Get-Container;
Export-ModuleMember New-Container;
Export-ModuleMember Get-ServerBasedTMs;
Export-ModuleMember Get-ServerBasedTM;
Export-ModuleMember New-ServerBasedTM; 
Export-ModuleMember Remove-ServerBasedTM;
Export-ModuleMember Remove-Container;
Export-ModuleMember Import-Tmx;
Export-ModuleMember Export-Tmx;