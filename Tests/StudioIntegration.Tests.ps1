# Pester 3.4.0. Needs a Trados Studio installation matching the PowerShell bitness:
#   x86 PowerShell -> Studio18 (2024), x64 PowerShell -> Studio19 (2026). Skipped when that version is not installed.
# Run: Invoke-Pester -Path .\Tests
$repoRoot = Split-Path $PSScriptRoot -Parent
$is64Bit = [System.IntPtr]::Size -eq 8
$studioVersion = if ($is64Bit) { "Studio19" } else { "Studio18" }
$programFiles = if ($is64Bit) { $Env:ProgramFiles } else { ${Env:ProgramFiles(x86)} }
$studioInstalled = Test-Path "$programFiles\Trados\Trados Studio\$studioVersion\SDLTradosStudio.exe"

Describe "Toolkit against $studioVersion" {
	if ($studioInstalled)
	{
		$env:PSModulePath += ";$repoRoot\Modules"
		Import-Module ToolkitInitializer -Force
		Import-ToolkitModules -StudioVersion $studioVersion
	}

	It "resolves the default project template to the file registered in Studio" -Skip:(-not $studioInstalled) {
		$template = & (Get-Module ProjectHelper) { Get-DefaultProjectTemplate }
		$template | Should Match '\.sdltpl$'
		Test-Path $template | Should Be $true
	}

	It "reports invalid credentials instead of throwing when the user manager server is unreachable" -Skip:(-not $studioInstalled) {
		$manager = Get-UserManager "http://localhost:1" "user" "password"
		$manager | Should BeNullOrEmpty
	}

	if ($studioInstalled)
	{
		Remove-ToolkitModules
	}
}
