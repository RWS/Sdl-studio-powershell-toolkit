param (
    [String] $vaultName = "LocalSecretStore"
)

$secretVault = Get-SecretVault -Name $vaultName -ErrorAction SilentlyContinue;
if ($null -eq $secretVault)
{
    Register-SecretVault -Name $vaultName -ModuleName Microsoft.PowerShell.SecretStore 
}
else {
    Unlock-SecretVault -Name $vaultName;
}

<#
.SYNOPSIS
Sets credentials for various Machine Translation (MT) services.

.DESCRIPTION
The `Set-MTCredential` function allows users to set credentials for supported Machine Translation services, including DeepL, LanguageWeaverEdge, LanguageWeaverCloud, Amazon, Google, and Microsoft Translator. 
It prompts the user to enter the necessary API keys and other required details based on the selected service type. The function then securely stores these credentials in a specified Secret Store.

.PARAMETER Type
Specifies the type of service for which credentials are being set. 
Accepted values: 'DeepL', 'LanguageWeaverEdge', 'LanguageWeaverCloud', 'Amazon', 'Google', 'Microsoft'.

.EXAMPLE
Set-MTCredential -Type "DeepL"

This command prompts the user to enter the Uri and API Key for the DeepL service and stores them securely.

.EXAMPLE
Set-MTCredential -Type "Amazon"

This command prompts the user to enter the Uri, Client ID, and Client Secret for Amazon and stores them securely.

.NOTES
The credentials are stored in a Secret Store. Make sure you have a local vault configured.
#>
function Set-MTCredential {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Type
    )

    $credentialData = @{}

    switch ($Type) {
        'DeepL' {
            $apyKey = Read-Host "Enter DeepL API Key"
            $credentialData = @{
                Type     = 'DeepL'
                Uri      = "deepltranslationprovider:///"
                ApiKey   = $apyKey 
            }
        }

        'LanguageWeaverEdge' {
            $accountRegion = Read-Host "Enter LanguageWeaverEdge Account Region"
            $lwhost = Read-Host "Enter LanguageWeaverEdge Host"
            $apiKey = Read-Host "Enter LanguageWeaverEdge API Key"
            $credentialData = @{
                Type          = 'LanguageWeaverEdge'
                Uri           = "languageweaveredge:///"
                AccountRegion = $accountRegion
                Host          = $lwhost
                ApiKey        = $apiKey
            }
        }

        'LanguageWeaverCloud' {
            $accountRegion = Read-Host "Enter LanguageWeaverCloud Account Region"
            $clientId = Read-Host "Enter LanguageWeaverCloud Client ID" 
            $clientSecret = Read-Host "Enter LanguageWeaverCloud Client Secret"
            $credentialData = @{
                Type          = 'LanguageWeaverCloud'
                Uri           = "languageweavercloud:///"
                AccountRegion = $accountRegion
                ClientId      = $clientId 
                ClientSecret  = $clientSecret
            }
        }
        'Amazon' {
            $clientId = Read-Host "Enter Amazon Client ID" 
            $clientSecret = Read-Host "Enter Amazon Client Secret"
            $credentialData = @{
                Type         = 'Amazon'
                Uri          = "amazontranslateprovider:///"
                ClientId     = $clientId 
                ClientSecret = $clientSecret 
            }
        }

        'Google' {
            $apiKey = Read-Host "Enter Google API Key"
            $credentialData = @{
                Type         = "Google"
                Uri          = "googletranslationprovider:///"
                ApiKey       = $apiKey
            }
        }

        'Microsoft' {
            $region = Read-Host "Enter Microsoft Region"
            $apiKey = Read-Host "Enter API Key"
            $credentialData = @{
                Type         = "MicrosoftTranslator"
                Uri          = "microsofttranslatorprovider:///"
                Region       = $region
                ApiKey       = $apiKey
            }
        }

        default {
            Write-Host "Unknown credential type: $Type"
            return
        }
    }

    Set-Secret -Name $Type -Secret $credentialData -Vault $vaultName;
}

<#
.SYNOPSIS
Retrieves stored credentials for a specified Machine Translation (MT) service.

.DESCRIPTION
The `Get-MTCredential` function retrieves the credentials for a specified MT service (e.g., DeepL, LanguageWeaverEdge) from the Secret Store. If no credentials are found, it returns a message indicating that no credentials are available for the specified service type.

.PARAMETER Target
Specifies the target MT service to retrieve credentials for. Supported values include DeepL, LanguageWeaverEdge, LanguageWeaverCloud, Amazon, Google, and Microsoft Translator.

.EXAMPLE
Get-MTCredential -Target "Google"

This command retrieves the credentials for the Google translation service from the Secret Store.

.NOTES
The credentials are retrieved from a Secret Store. Ensure you have access to the specified vault.

#>
function Get-MTCredential {
    param (
        [Parameter(Mandatory=$true)]
        [string] $Target 
    )

    try {
        $credentialData = Get-Secret -Name $Target -Vault $vaultName -AsPlainText -ErrorAction SilentlyContinue

        if ($null -eq $credentialData) {
            Write-Host "No credentials found for $Target."
            return $null
        }

        return $credentialData;

    } catch {
        Write-Host "An error occurred while retrieving credentials for $Target."
        Write-Host $_.Exception.Message
        return $null
    }
}

<#
.SYNOPSIS
Removes stored credentials for a specified Machine Translation (MT) service.

.DESCRIPTION
The `Remove-MTCredential` function removes the credentials for a specified MT service from the Secret Store. If the specified credentials do not exist, it informs the user that no credentials were found. If the credentials are successfully removed, it confirms the deletion.

.PARAMETER Target
Specifies the target MT service for which credentials should be removed. Supported values include DeepL, LanguageWeaverEdge, LanguageWeaverCloud, Amazon, Google, and Microsoft Translator.

.EXAMPLE
Remove-MTCredential -Target "Microsoft"

This command removes the credentials for the Microsoft Translator service from the Secret Store.

.NOTES
Ensure you have access to the specified Secret Store vault to manage stored credentials.

#>
function Remove-MTCredential {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Target 
    )

    try {
        $secret = Get-Secret -Name $Target -Vault "LocalSecretStore" -ErrorAction SilentlyContinue

        if ($null -eq $secret) {
            Write-Host "No credentials found for $Target in the vault."
            return
        }

        Remove-Secret -Name $Target -Vault $vaultName;
        Write-Host "Credentials for $Target have been removed from the vault."
    } catch {
        Write-Host "An error occurred while removing credentials for $Target."
        Write-Host $_.Exception.Message
    }
}

Export-ModuleMember Get-MTCredential;
Export-ModuleMember Remove-MTCredential;
Export-ModuleMember Set-MTCredential;