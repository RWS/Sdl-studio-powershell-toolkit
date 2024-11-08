param ([String] $studioVersion)

<#
    .SYNOPSIS
    Creates a new file-based Translation Memory (TM).

    .DESCRIPTION
    Creates a file-based Translation Memory (TM) at the specified location. The TM will be configured with the provided description, source and target languages. Default values for FuzzyIndexes, Recognizers, TokenizerFlags, and WordCountFlags are used unless custom values are specified.

    .PARAMETER filePath
    Represents the path where the new TM file will be created.
    Example: "D:\Path\To\filebasedtm.sdltm"

    .PARAMETER sourceLanguageName
    Represents the language code to be used as the source language for the TM.
    Example: "en-US", "de-DE"

    .PARAMETER targetLanguageName
    Represents the language code to be used as the target language for the TM.
    Example: "en-US", "de-DE"
	
    .PARAMETER description
    Provides a description for the TM.

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
    Returns an instance of `FileBasedTranslationMemory` configured according to the provided parameters or $null if the parameters provided are invalid.

	.NOTES 
	If the provided path is an existing filebased translation memory, it will be overriden.
#>
function New-FileBasedTM
{
	param(
		[Parameter(Mandatory=$true)]
		[String] $filePath,

		[Parameter(Mandatory=$true)]
		[String] $sourceLanguageName,
		
		[Parameter(Mandatory=$true)]
		[String] $targetLanguageName,
		
		[String] $description,
		[Sdl.LanguagePlatform.TranslationMemory.FuzzyIndexes] $fuzzyIndexes = $(Get-DefaultFuzzyIndexes),
		[Sdl.LanguagePlatform.Core.Tokenization.BuiltinRecognizers] $recognizers = $(Get-DefaultRecognizers),
		[Sdl.LanguagePlatform.Core.Tokenization.TokenizerFlags] $tokenizerFlags = $(Get-DefaultTokenizerFlags),
		[Sdl.LanguagePlatform.TranslationMemory.WordCountFlags] $wordCountFlag = $(Get-DefaultWordCountFlags)
	)

# validates the file extension and adds the right extension for the filebased tm
$filePath = Get-FileExtension $filePath ".sdltm"

$sourceLanguage = Get-CultureInfo $sourceLanguageName;
$targetLanguage = Get-CultureInfo $targetLanguageName; 

# Checks if the source or target languages are valid languages
if ($null -eq $sourceLanguage -or $null -eq $targetLanguage)
{
	Write-Host "Invalid Source or Target Language"
	return;
}

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

	# Checks for the filepath extension, if it is not a valid tm extension it will be appended with the .sdltm extension
	$filePath = Get-FileExtension $filePath ".sdltm"

	# Checks if the provided path is an actual existing file
	if ($(Test-Path -Path $filePath -PathType Leaf) -eq $false)
	{
		Write-Host "Translation Memory does not exist at this location";
		return;
	}

	return New-Object Sdl.LanguagePlatform.TranslationMemoryApi.FileBasedTranslationMemory ($filePath);
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
	
		# check the existence of tm
	[Sdl.LanguagePlatform.TranslationMemoryApi.FileBasedTranslationMemory] $tm = Open-FileBasedTM $filePath;

	if ($null -eq $tm)
	{
		return;
	}

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

	.OUTPUTS
    [Sdl.Core.Globalization.Language]
    Returns a `Language` object that represents the specified language or null if the provided language code is invalid.

	.NOTES
	If the provided language name is not a valid language code, this function will simply return $null
#>
function Get-Language
{
	param(
		[Parameter(Mandatory=$true)]
		[String] $languageName)

	$lang = New-Object Sdl.Core.Globalization.Language ($languageName)

	# Checks if the provided language is a valid language code.
	if ($lang.IsSupported)
	{
		return $lang
	}

	return $null;
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
    Returns an array `Language` objects that represents the specified languages or null if one provided language code is invalid.

	.NOTES
	If one of the provided language names is an invalid language code this function will return $null
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
		if ($null -eq $newlang)
		{
			return;
		}

		$languages = $languages + $newlang
	}

	return $languages
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

function Get-FileExtension
{
	param (
		[String] $path,
		[String] $extension)

	if ($path.EndsWith($extension))
	{
		return $path
	}

	return $path + $extension;
}


Export-ModuleMember New-FileBasedTM;
Export-ModuleMember Get-Language;
Export-ModuleMember Get-Languages;
Export-ModuleMember Open-FileBasedTM;
Export-ModuleMember Get-TargetTMLanguage;