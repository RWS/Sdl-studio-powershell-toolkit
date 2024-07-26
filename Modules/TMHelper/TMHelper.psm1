param ([String] $studioVersion)

<#
	.SYNOPSIS
	Creates a new file based TM.

	.DESCRIPTION
	Creates a file based Translation Memory given the path of the file to be created, description, source and target languages with
	- Default FuzzyIndexes, Recognizers, TokenizerFlags and WordCountFlags
	- Custom FuzzyIndexes, Recognizers, TokenizerFlags and WordCountFlags

	.PARAMETER filePath
	Represents the location where the TM will be located after creation.

	Example: "D:Path\To\filebasedtm.sdltm"

	.PARAMETER description
	Represents the description of the TM

	.PARAMETER sourceLanguageName
	Represents the language code that will be used as the source language for the TM

	Example: "en-US" "de-DE"

	.PARAMETER targetLanguageName
	Represents the language code that will be used as the target language for the TM

	Example: "en-US" "de-DE"

	.PARAMETER fuzzyIndexes
	Reprezents the fuzzyIndexes options given or the default ones if paramter not provided.
	
	.PARAMETER recognizers
	Reprezents the recognizers options given or the default ones if paramter not provided.

	.PARAMETER tokenizerFlags
	Reprezents the tokenizer flags options given or the default ones if paramter not provided

	.PARAMETER wordCountFlag
	Reprezents the word count options given or the default ones if paramter not provided

	.EXAMPLE
	New-FileBasedTM -filePath "D:\Path\To\TM.sdltm" -description "TM Description" -sourceLanguageName "en-US" -targetLanguageName "de-DE";
#>
function New-FileBasedTM
{
param(
	[Parameter(Mandatory=$true)]
	[String] $filePath,

	[Parameter(Mandatory=$true)]
	[String] $description,

	[Parameter(Mandatory=$true)]
	[String] $sourceLanguageName,

	[Parameter(Mandatory=$true)]
	[String] $targetLanguageName,
	[Sdl.LanguagePlatform.TranslationMemory.FuzzyIndexes] $fuzzyIndexes = $(Get-DefaultFuzzyIndexes),
	[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers] $recognizers = $(Get-DefaultRecognizers),
	[Sdl.LanguagePlatform.Core.Tokenization.TokenizerFlags] $tokenizerFlags = $(Get-DefaultTokenizerFlags),
	[Sdl.LanguagePlatform.TranslationMemory.WordCountFlags] $wordCountFlag = $(Get-DefaultWordCountFlags)
)

$sourceLanguage = Get-CultureInfo $sourceLanguageName;
$targetLanguage = Get-CultureInfo $targetLanguageName; 

return New-Object Sdl.LanguagePlatform.TranslationMemoryApi.FileBasedTranslationMemory(
	$filePath, 
	$description,
	$sourceLanguage,
	$targetLanguage,
	$fuzzyIndexes,
	$recognizers,
	$tokenizerFlags,
	$wordCountFlag);
}

<#
	.SYNOPSIS
	Open an existing file based TM

	.DESCRIPTION
	Open and return a filse based TM based on the provided location.

	.PARAMETER filePath
	Reprezents the tm file location

	.EXAMPLE
	Open-FileBasedTM "D:\Path\To\TM.sdltm"
#>
function Open-FileBasedTM
{
	param(
		[Parameter(Mandatory=$true)]
		[String] $filePath)

	[Sdl.LanguagePlatform.TranslationMemoryApi.FileBasedTranslationMemory] $tm = 
	New-Object Sdl.LanguagePlatform.TranslationMemoryApi.FileBasedTranslationMemory ($filePath);
	
	return $tm;
}

<#
	.SYNOPSIS
	Gets the target language of a given TM

	.DESCRIPTION
	Reads the target language of an existing TM based on the provided location.

	.PARAMETER filePath
	Location of the TM file

	.EXAMPLE
	Get-TargetTMLanguage "D:\Path\To\TM.sdltm"
#>
function Get-TargetTMLanguage
{
	param(
		[Parameter(Mandatory=$true)]
		[String] $filePath)
	
	[Sdl.LanguagePlatform.TranslationMemoryApi.FileBasedTranslationMemory] $tm = Open-FileBasedTM $filePath;
	[Sdl.LanguagePlatform.TranslationMemoryApi.FileBasedTranslationMemoryLanguageDirection] $direction = $tm.LanguageDirection;
	return $direction.TargetLanguage;	
}

<#
	.SYNOPSIS
	Translates a string to a Trados Language.

	.DESCRIPTION
	Gets the [Sdl.Core.Globalization.Language] language as an object based on the provided language string

	.PARAMETER languageName
	Represents the language definition

	.EXAMPLE
	Get-Language "en-US"
#>
function Get-Language
{
	param(
		[Parameter(Mandatory=$true)]
		[String] $languageName)
	
	return New-Object Sdl.Core.Globalization.Language ($languageName)
}

<#
	.SYNOPSIS
	Translates multiple strings to a Trados Languages.

	.DESCRIPTION
	Gets [Sdl.Core.Globalization.Language] languages as an array of object based on the provided language strings

	.PARAMETER languageName
	Represents the list of language definitions

	.EXAMPLE
	Get-Languages @("en-US", "de-DE")
#>
function Get-Languages
{
	param(
		[Parameter(Mandatory=$true)]
		[String[]] $languageNames)

	[Sdl.Core.Globalization.Language[]]$languages = @();
	foreach($lang in $languageNames)
	{
		$newlang = Get-Language $lang;
		
		$languages = $languages + $newlang
	}

	return $languages
}

<#
	.SYNOPSIS
	Returns a MemoryResource object that can be used for project creation.

	.PARAMETER tmPath
	Represents the physical path to the translation memory.

	Example: "D:\Path\To\tm.sdltm"

	.PARAMETER uriSchema
	Represents the uri schema for the translation provider.

	Example: "deepltranslationprovider:///"

	.PARAMETER uri
	Represents the full uri for the translation provider.
	If no uri this value should be the same with the uriSchema

	Example: "deepltranslationprovider:///"

	.PARAMETER userNameOrClientId
	Represents the username or client id for authentication.

	If the translation provider is not a file based tm and the authentication only requires one password/ api key, this parameter shuold be provided.

	.PARAMETER userPasswordOrClientSecret
	Represents the password or the client secret.

	If the translation provider is password protected this parameter should be filled with the actual password for the TM.

	.PARAMETER targetLanguageCode
	Represents the language code that will be used for the project creation.

	If no language code is provided, this translation provider will be used for all languages, 
	otherwise it will be used for the language pair, where the source is the project source language and the target language is this parameter.

	.PARAMETER isWindowsUser
	Boolean value indicating whether this translation provider will be authenticated with windows.
#>
function Get-TranslationProvider 
{
	param (
		[String] $tmPath,
		[String] $uriSchema,
		[String] $uri,
		[String] $userNameOrClientId,
		[String] $userPasswordOrClientSecret,
		[String] $targetLanguageCode,
		[Bool] $isWindowsUser
	)

	$tmProvider = [TMProvider.MemoryResource]::New()
	$tmProvider.Path = $tmPath

	if ($uri)
	{
		$tmProvider.Uri = [System.Uri]::New($uri)
	}
	if ($uriSchema)
	{
		$tmProvider.UriSchema = [System.Uri]::New($uriSchema)
	}

	$tmProvider.UserNameOrClientId = $userNameOrClientId
	$tmProvider.UserPasswordOrClientSecret = $userPasswordOrClientSecret
	$tmProvider.IsWindowsUser = $isWindowsUser
	$tmProvider.TargetLanguageCode = $targetLanguageCode

	return $tmProvider
}

function Import-TMXToFileBasedTM 
{
	param (
		[Parameter(Mandatory=$true)]
		[String] $tmPath,

		[Parameter(Mandatory=$true)]
		[String] $importPath,
		[String] $newFieldsOption = "AddToSetup",
		[String] $importTUProcessingMode = "ProcessCleanedTUOnly",
		[String] $tuUpdateMode = "AddNew",
		[Bool] $plainText = $false,
		[Bool] $checkMatchingSubLanguages = $true
	)

	$tm = Open-FileBasedTM $tmPath
	$importer = New-Object Sdl.LanguagePlatform.TranslationMemoryApi.TranslationMemoryImporter ($tm.LanguageDirection)

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
		Write-Host "Invalid Fields Options, TU Processing Mode or TU Update Mode" -ForegroundColor Red
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

	$OnBatchImportedDelegate = [RunspacedDelegateFactory]::NewRunspacedDelegate($OnBatchImported, [Runspace]::DefaultRunspace)
	
	$importer.Add_BatchImported($OnBatchImportedDelegate)
	$importer.Import($importPath)
	$importer.Remove_BatchImported($OnBatchImportedDelegate);

	Write-Host $null;
}

function Export-TMXFromFileBasedTM 
{
	param (
		[Parameter(Mandatory=$true)]
		[String] $tmPath,

		[Parameter(Mandatory=$true)]
		[String] $exportPath
	)

	$tm = Open-FileBasedTM $tmPath
	$exporter = New-OBject Sdl.LanguagePlatform.TranslationMemoryApi.TranslationMemoryExporter($tm.LanguageDirection)

	$OnBatchExported = [System.EventHandler[Sdl.LanguagePlatform.TranslationMemoryApi.BatchExportedEventArgs]] {
		param (
			[System.Object] $sender,
			[Sdl.LanguagePlatform.TranslationMemoryApi.BatchExportedEventArgs] $e
		)
		$TotalProcessed = $e.TotalProcessed
		$TotalExported = $e.TotalExported
		Write-Host "TUs processed: $TotalProcessed exported: $TotalExported`r" -NoNewLine
	}

	$OnBatchExportedDelegate = [RunspacedDelegateFactory]::NewRunspacedDelegate($OnBatchExported, [Runspace]::DefaultRunspace)
	
	$exporter.Add_BatchExported($OnBatchExportedDelegate)
	$exporter.Export($exportPath, $true);
	$exporter.Remove_BatchExported($OnBatchExportedDelegate)
	Write-Host $null;
}

function Convert-ToEnum 
{
	param (
		[Type] $type,
		[string] $value
	)

	try 
	{
		return $type
	}
	catch 
	{
		return $null;
	}
}

function Get-CultureInfo {
	param(
		[String] $Language
	)

	$CultureInfo = Get-Language $Language
	return $CultureInfo.CultureInfo
}

function Get-DefaultFuzzyIndexes
{
	 return [Sdl.LanguagePlatform.TranslationMemory.FuzzyIndexes]::SourceCharacterBased -band 
	 	[Sdl.LanguagePlatform.TranslationMemory.FuzzyIndexes]::SourceWordBased -band
		[Sdl.LanguagePlatform.TranslationMemory.FuzzyIndexes]::TargetCharacterBased -band
		[Sdl.LanguagePlatform.TranslationMemory.FuzzyIndexes]::TargetWordBased;
}

function Get-DefaultRecognizers
{
	return [Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeAcronyms -band
	[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeAll -band
	[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeDates -band
	[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeMeasurements -band
	[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeNumbers -band
	[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeTimes -band
	[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers]::RecognizeVariables;
}

function Get-DefaultTokenizerFlags
{
	return [Sdl.LanguagePlatform.Core.Tokenization.TokenizerFlags]::DefaultFlags;
}

function Get-DefaultWordCountFlags
{
	return [Sdl.LanguagePlatform.TranslationMemory.WordCountFlags]::DefaultFlags;
}

Export-ModuleMember New-FileBasedTM;
Export-ModuleMember Get-Language;
Export-ModuleMember Get-Languages;
Export-ModuleMember Open-FileBasedTM;
Export-ModuleMember Get-TargetTMLanguage;
Export-ModuleMember Get-TranslationProvider;
Export-ModuleMember Import-TMXToFileBasedTM;
Export-ModuleMember Export-TMXFromFileBasedTM;