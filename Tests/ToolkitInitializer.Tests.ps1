# Pester 3.4.0 (ships with Windows PowerShell 5.1). Run: Invoke-Pester -Path .\Tests
# Covers the Studio-version logic in ToolkitInitializer without a Trados Studio installation.
$modulePath = Join-Path (Split-Path $PSScriptRoot -Parent) "Modules\ToolkitInitializer"
Import-Module $modulePath -Force

InModuleScope ToolkitInitializer {

	Describe "Get-StudioVersionNumber" {
		It "extracts the number from the version folder name" {
			Get-StudioVersionNumber "Studio19" | Should Be 19
		}
		It "returns 0 when there is no number" {
			Get-StudioVersionNumber "Studio" | Should Be 0
		}
	}

	Describe "Test-Is64BitStudio" {
		It "is false for Studio18 and earlier" {
			Test-Is64BitStudio "Studio17" | Should Be $false
			Test-Is64BitStudio "Studio18" | Should Be $false
		}
		It "is true for Studio19 and later" {
			Test-Is64BitStudio "Studio19" | Should Be $true
			Test-Is64BitStudio "Studio20" | Should Be $true
		}
	}

	Describe "Test-PSVersion" {
		$is32BitHost = [System.IntPtr]::Size -eq 4
		It "requires a PowerShell process matching the Studio bitness" {
			Test-PSVersion "Studio18" | Should Be $is32BitHost
			Test-PSVersion "Studio19" | Should Be (-not $is32BitHost)
		}
	}

	Describe "Add-Dependencies" {
		Mock Add-Type {}
		Mock Resolve-Log4Net {}
		Mock New-Object { New-Object -TypeName PSObject | Add-Member -MemberType ScriptMethod -Name Resolve -Value {} -PassThru } -ParameterFilter { $TypeName -eq "DependencyResolver.AssemblyResolver" }
		Mock Test-Path { $true }

		It "loads Studio18 from Program Files (x86)" {
			Add-Dependencies "Studio18"
			Assert-MockCalled Add-Type -ParameterFilter { $Path -like "${Env:ProgramFiles(x86)}\Trados\Trados Studio\Studio18\*Sdl.ProjectAutomation.FileBased.dll" }
		}

		It "loads Studio19 from Program Files" {
			Add-Dependencies "Studio19"
			Assert-MockCalled Add-Type -ParameterFilter { $Path -like "${Env:ProgramFiles}\Trados\Trados Studio\Studio19\*Sdl.ProjectAutomation.FileBased.dll" }
		}

		It "initialises log4net when Sdl.Desktop.Logger.dll exists" {
			Add-Dependencies "Studio18"
			Assert-MockCalled Resolve-Log4Net -Times 1 -Exactly -Scope It
		}

		It "skips log4net when Sdl.Desktop.Logger.dll does not exist" {
			Mock Test-Path { $false } -ParameterFilter { $Path -like "*Sdl.Desktop.Logger.dll" }
			Add-Dependencies "Studio19"
			Assert-MockCalled Resolve-Log4Net -Times 0 -Exactly -Scope It
		}

		# Pester 3 keeps a Mock declared inside an It for the rest of the Describe, so this one stays last
		It "throws a message naming the folder when the Studio folder does not exist" {
			Mock Test-Path { $false } -ParameterFilter { $PathType -eq "Container" }
			{ Add-Dependencies "Studio20" } | Should Throw "Studio20"
		}
	}
}
