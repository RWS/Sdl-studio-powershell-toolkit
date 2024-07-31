param ([String] $studioVersion)

<#
    .SYNOPSIS
    Creates a new file-based Translation Memory (TM).

    .DESCRIPTION
    Creates a file-based Translation Memory (TM) at the specified location. The TM will be configured with the provided description, source and target languages. Default values for FuzzyIndexes, Recognizers, TokenizerFlags, and WordCountFlags are used unless custom values are specified.

    .PARAMETER filePath
    Represents the path where the new TM file will be created.
    Example: "D:\Path\To\filebasedtm.sdltm"

    .PARAMETER description
    Provides a description for the TM.

    .PARAMETER sourceLanguageName
    Represents the language code to be used as the source language for the TM.
    Example: "en-US", "de-DE"

    .PARAMETER targetLanguageName
    Represents the language code to be used as the target language for the TM.
    Example: "en-US", "de-DE"

    .PARAMETER fuzzyIndexes
    Specifies the fuzzy indexes settings for the TM. If not provided, default settings are used.

    .PARAMETER recognizers
    Specifies the recognizers settings for the TM. If not provided, default settings are used.

    .PARAMETER tokenizerFlags
    Specifies the tokenizer flags settings for the TM. If not provided, default settings are used.

    .PARAMETER wordCountFlag
    Specifies the word count flags settings for the TM. If not provided, default settings are used.

    .EXAMPLE
    New-FileBasedTM -filePath "D:\Path\To\TM.sdltm" -description "TM Description" -sourceLanguageName "en-US" -targetLanguageName "de-DE"
    
    Creates a new file-based Translation Memory with the specified file path, description, source language "en-US", and target language "de-DE" using default settings for fuzzy indexes, recognizers, tokenizer flags, and word count flags.

    .OUTPUTS
    [Sdl.LanguagePlatform.TranslationMemoryApi.FileBasedTranslationMemory]
    Returns an instance of `FileBasedTranslationMemory` configured according to the provided parameters.
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
    Opens an existing file-based Translation Memory (TM).

    .DESCRIPTION
    Opens and returns a file-based Translation Memory (TM) based on the specified file location.

    .PARAMETER filePath
    Represents the file path where the TM is located.
    Example: "D:\Path\To\TM.sdltm"

    .EXAMPLE
    Open-FileBasedTM "D:\Path\To\TM.sdltm"
    
    Opens the file-based TM located at "D:\Path\To\TM.sdltm" and returns the `FileBasedTranslationMemory` object.

    .OUTPUTS
    [Sdl.LanguagePlatform.TranslationMemoryApi.FileBasedTranslationMemory]
    Returns an instance of `FileBasedTranslationMemory` that corresponds to the file specified by `filePath`.

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
    Retrieves the target language of a specified file-based Translation Memory (TM).

    .DESCRIPTION
    Opens an existing file-based Translation Memory (TM) from the provided file location and reads its target language.

    .PARAMETER filePath
    The location of the TM file.
    Example: "D:\Path\To\TM.sdltm"

    .EXAMPLE
    Get-TargetTMLanguage "D:\Path\To\TM.sdltm"
    
    Opens the file-based TM located at "D:\Path\To\TM.sdltm" and retrieves its target language.

    .OUTPUTS
    [System.Globalization.CultureInfo]
    Returns a `CultureInfo` object representing the target language of the TM.
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
    Creates a `Sdl.Core.Globalization.Language` object from a language code.

    .DESCRIPTION
    Converts a language code (e.g., "en-US") into a `Sdl.Core.Globalization.Language` object that can be used with Trados functions. This object represents the specified language within the Trados environment.

    .PARAMETER languageName
    The language code or name representing the language. The code should be in the format of a culture code (e.g., "en-US" for English (United States), "de-DE" for German (Germany)).

    .EXAMPLE
    Get-Language "en-US"
    
    Creates and returns a `Sdl.Core.Globalization.Language` object for English (United States).

    .OUTPUTS
    [Sdl.Core.Globalization.Language]
    Returns a `Language` object that represents the specified language.
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
    Returns a `MemoryResource` object configured for a translation provider.

    .DESCRIPTION
    Creates and returns a `MemoryResource` object, which can be used for providing translation providers in project creation. 
	The object is set up based on the provided parameters, which include paths, URIs, authentication details, and target languages. 

    If the translation provider is a filebased translation memory, only the path and, optionally, the password should be provided.
    If the translation provider is a serverbased translation memory, the URI and URI schema should be provided along with the credentials if they are different. If both URI and URI schema are the same, only the URI schema needs to be provided.

    .PARAMETER tmPath
    The physical path to the translation memory file. For example, "D:\Path\To\tm.sdltm".

    .PARAMETER uriSchema
    The URI schema for the translation provider. For example, "deepltranslationprovider:///".

    .PARAMETER uri
    The full URI for the translation provider. If no URI is provided, this should be the same as the `uriSchema`. For example, "deepltranslationprovider:///".

    .PARAMETER userNameOrClientId
    The username or client ID for authentication. This is required if the translation provider uses authentication and does not rely solely on a password or API key.

    .PARAMETER userPasswordOrClientSecret
    The password or client secret for authentication. This is required if the translation provider is password-protected.

    .PARAMETER targetLanguageCodes
    An array of language codes that will be used for the project creation. For example, @("en-US", "fr-FR") for English (United States) and French (France).
	If the value is not provided this translation resource will be applied for all project language pairs

    .PARAMETER isWindowsUser
    A boolean value indicating whether the translation provider will be authenticated using Windows credentials. Set to `$true` for Windows authentication and `$false` otherwise.

    .EXAMPLE
    Get-TranslationProvider -tmPath "D:\Path\To\tm.sdltm" -uriSchema "deepltranslationprovider:///" -uri "deepltranslationprovider:///" -userNameOrClientId "clientId" -userPasswordOrClientSecret "secret" -targetLanguageCodes @("en-US") -isWindowsUser $false
    
    Creates and returns a `MemoryResource` object configured with the provided parameters for use with a translation provider.

    .OUTPUTS
    [DependencyResolver.MemoryResource]
    Returns a `MemoryResource` object configured with the specified parameters.
#>
function Get-TranslationProvider 
{
	param (
		[String] $tmPath,
		[String] $uriSchema,
		[String] $uri,
		[String] $userNameOrClientId,
		[String] $userPasswordOrClientSecret,
		[String[]] $targetLanguageCodes,
		[Bool] $isWindowsUser
	)

	$tmProvider = [DependencyResolver.MemoryResource]::New()
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
	$tmProvider.TargetLanguageCodes = $targetLanguageCodes

	return $tmProvider
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