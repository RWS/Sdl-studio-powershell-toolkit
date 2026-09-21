# Installs the built MSI silently for the current user, verifies what it put in place, then uninstalls it.
# Usage (any PowerShell, no admin needed - the package is per-user):
#   dotnet build .\wix.Setup.sln -c Release
#   .\Test-Install.ps1 [-Msi .\wix.Setup\bin\x86\Release\wix.Setup.msi] [-StudioVersion Studio19] [-KeepInstalled]
# The toolkit import check runs in the PowerShell bitness that matches -StudioVersion (x86 for Studio17/18, x64 for Studio19+).
param(
	[String] $Msi = (Join-Path $PSScriptRoot "wix.Setup\bin\x86\Release\wix.Setup.msi"),
	[String] $StudioVersion = "Studio19",
	[Switch] $KeepInstalled
)

$ErrorActionPreference = "Stop"
# msiexec runs the install through the Windows Installer service, which may not be able to read the MSI from a user folder
# ("Failed to access database", exit 1619), so the package is installed from a copy in TEMP.
$msiCopy = Join-Path $env:TEMP (Split-Path $Msi -Leaf)
Copy-Item (Resolve-Path $Msi).Path $msiCopy -Force
$Msi = $msiCopy
$installDir = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "WindowsPowerShell"
$modulesDir = Join-Path $installDir "Modules"
$log = Join-Path $env:TEMP "toolkit-install.log"
$failures = @()

function Check([String] $what, [bool] $ok) {
	if ($ok) { Write-Host "OK   $what" -ForegroundColor Green } else { Write-Host "FAIL $what" -ForegroundColor Red; $script:failures += $what }
}

function Invoke-Msiexec([String[]] $arguments) {
	$p = Start-Process msiexec.exe -ArgumentList ($arguments + @("/qn", "/l*v", "`"$log`"")) -Wait -PassThru
	return $p.ExitCode
}

# --- install ---
$exit = Invoke-Msiexec @("/i", "`"$Msi`"")
Check "msiexec /i exit code 0 (got $exit; log: $log)" ($exit -eq 0)
if ($exit -ne 0) {
	Select-String -Path $log -Pattern "must be installed|is required" | % { Write-Host "  launch condition: $($_.Line.Trim())" }
	exit 1
}

foreach ($m in "GetGuids", "PackageHelper", "ProjectHelper", "ProjectServerHelper", "ProvidersHelper", "TMHelper", "TMServerHelper", "ToolkitInitializer", "UserManagerHelper") {
	Check "module $m installed (.psd1 + .psm1)" ((Test-Path "$modulesDir\$m\$m.psd1") -and (Test-Path "$modulesDir\$m\$m.psm1"))
}
Check "DependencyResolver.dll installed" (Test-Path "$modulesDir\ToolkitInitializer\DependencyResolver.dll")
foreach ($s in "FileBasedProject_Roundtrip.ps1", "ServerBasedProject_Roundtrip.ps1", "TMServer_Roundtrip.ps1", "UserManager_Roundtrip.ps1") {
	Check "script $s installed" (Test-Path "$installDir\$s")
}
$userPsModulePath = [Environment]::GetEnvironmentVariable("PSModulePath", "User")
Check "user PSModulePath contains Modules folder ($userPsModulePath)" (($userPsModulePath -split ";" | ForEach-Object { $_.TrimEnd("\") }) -contains $modulesDir)

# per-user MSI packages register under the machine-wide 32-bit Uninstall key
$installedVersion = (Get-ItemProperty "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | Where-Object DisplayName -eq "Trados PowerShell Toolkit").DisplayVersion
Check "registered in Apps & features (version $installedVersion)" ([bool] $installedVersion)

# --- import the installed toolkit in a fresh PowerShell of the right bitness (picks up the new user PSModulePath) ---
$is64 = [int] ($StudioVersion -replace "\D") -ge 19
$ps = if ($is64) { "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" } else { "$env:SystemRoot\SysWOW64\WindowsPowerShell\v1.0\powershell.exe" }
$importCheck = "& { Import-Module ToolkitInitializer -ErrorAction Stop; Import-ToolkitModules -StudioVersion $StudioVersion; if ((Get-Module ProjectHelper).ModuleBase -like '$modulesDir*') { 'IMPORT_OK' } else { 'IMPORT_WRONG_LOCATION ' + (Get-Module ProjectHelper).ModuleBase } }"
$importResult = & $ps -NoProfile -ExecutionPolicy Bypass -Command $importCheck 2>&1 | Select-Object -Last 1
Check "Import-ToolkitModules -StudioVersion $StudioVersion from the installed location ($importResult)" ($importResult -eq "IMPORT_OK")

if ($KeepInstalled) {
	Write-Host "Left installed (-KeepInstalled)."
}
else {
	# --- uninstall ---
	$exit = Invoke-Msiexec @("/x", "`"$Msi`"")
	Check "msiexec /x exit code 0 (got $exit)" ($exit -eq 0)
	Check "Modules folder removed" (-not (Test-Path $modulesDir))
	Check "scripts removed" (-not (Test-Path "$installDir\FileBasedProject_Roundtrip.ps1"))
	$userPsModulePath = [Environment]::GetEnvironmentVariable("PSModulePath", "User")
	Check "user PSModulePath no longer contains Modules folder ($userPsModulePath)" (-not (($userPsModulePath -split ";" | ForEach-Object { $_.TrimEnd("\") }) -contains $modulesDir))
}

if ($failures) { Write-Host "`n$($failures.Count) check(s) failed" -ForegroundColor Red; exit 1 }
Write-Host "`nAll checks passed" -ForegroundColor Green
