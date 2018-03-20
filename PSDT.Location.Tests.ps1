$testLocation = $(Split-Path -Parent $MyInvocation.MyCommand.Path);
# JH: PSDT.App improt is necessary (consider development and build environment). 
# Import-Module "$testLocation\..\PSDT.App\PSDT.App.psd1" -Force;
Import-Module "$testLocation\PSDT.Location.psd1" -Force;

Describe -Tags "PSDT.Location" "Enter-Location" {

    It "pushes the first matching location, when executing command" {
      $expectedLocation = "c:\powershell";
      Mock -CommandName Get-Directory -MockWith { return @([pscustomobject]@{FullName = $expectedLocation}, [pscustomobject]@{FullName = "c:\powershell\about"}) };
      Mock -CommandName Push-Location -MockWith { };
      
      Enter-Location en;

      Assert-MockCalled -CommandName Push-Location -Times 1 -Exactly -ParameterFilter { $Path -eq $expectedLocation };
    }
}
