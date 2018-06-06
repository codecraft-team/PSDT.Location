$global:PSDTLocationConfiguration = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "config.json") -Raw | ConvertFrom-Json;

if (-not (Test-Path PreEnterLocationTabExpansion) -and (Test-Path Function:\TabExpansion)) {
  Rename-Item Function:\TabExpansion PreEnterLocationTabExpansion
}

Function global:TabExpansion($line, $lastWord) {
  $cmdletStartIndex = ([string]$line).LastIndexOf('|') + 1;
  $cmdlet = ([string]$line).Substring($cmdletStartIndex).TrimStart();
  $filter = ($cmdlet -split " " | Select-Object -Skip 1) -join ".*";

  $enterLocationAliases = (Get-Alias -Definition Enter-Location -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name) -join "|";
  $enterLocationPattern = ("Enter-Location", $enterLocationAliases | Where-Object { $_.Length -gt 0 }) -join "|";
  switch -regex ($cmdlet) {
    "^($enterLocationPattern) .*" {
      Get-KnownPath $filter | Select-Object -ExpandProperty FullName -First $global:PSDTLocationConfiguration.MaximumTabCompletionItems;
    }
    default {
      if (Test-Path Function:\PreEnterLocationTabExpansion) {
        PreEnterLocationTabExpansion $line $lastWord
      }
    }
  }
}

function Get-KnownPath {
  $filter = ".*{0}.*" -f ($args -join ".*");
  return Get-ChildItem .\ -Recurse -Directory | Where-Object { $_.FullName -match $filter; };
}

<#
.SYNOPSIS
  Looks for child items, based on the parameters and sets the current location to the first matching location.
  If no matching child items were found, the cmdlet looks in the parent directory. This continues until the first match or the root of the PSDrive is reached.
.DESCRIPTION
  The cmdlet uses the Push-Location cmdlet to enter the selected location i.e. Push-Location can be used to navigate back in the global navigation stack.
.EXAMPLE
  Consider the following child item structure:

    Directory: R:\PSDT.Location

Mode                LastWriteTime         Length Name 
----                -------------         ------ ---- 
d-----        3/15/2018   8:43 AM                en-US
-a----         3/4/2018   2:15 PM           2780 appveyor.yml
-a----        2/21/2018   4:42 PM           1092 LICENSE

  The following command looks for the child items using the *en* filter and calls the Push-Location cmdlet with the first match:

  PS :\> Enter-Location en
  PS :\en-US> 

.EXAMPLE
  Consider the following child item structure:

    Directory: R:\PSDT.Location

Mode                LastWriteTime         Length Name 
----                -------------         ------ ---- 
d-----        3/15/2018   8:43 AM                en-US
-a----         3/4/2018   2:15 PM           2780 appveyor.yml
-a----        2/21/2018   4:42 PM           1092 LICENSE

  Pressing the TAB key after the following command:
    PS :\> Enter-Location en

  will replace the last parameter with the first matching location, like this:
    PS :\> Enter-Location R:\PSDT.Location\en-US

  By pressing the enter, the location will be pushed:
    PS R:\PSDT.Location\en-US> 

.EXAMPLE
  The following example shows how a location can be reached, which is outside the child directory branch.
  Consider the following child item structure:

    Directory: R:\PSDT.Location
    Directory: R:\PSDT.Location\en-US
    Directory: R:\PSDT.VisualStudio
    Directory: R:\PSDT.VisualStudio\Tests
  
    PS R:\PSDT.Location\en-US> Enter-Location Tests
    PS R:\PSDT.VisualStudio\Tests>
#>
function Enter-Location {
  Set-Location -StackName $null;

  if (Test-Path $args[$args.Length - 1]) {
    Push-LocationToGlobalStack $args[$args.Length - 1];
  }
  else {
    $knownPath = Get-KnownPath @args | Select-Object -First 1 -ExpandProperty FullName;
    if($global:PSDTLocationConfiguration.EnableParentLocation -and -not $knownPath) {
      $previousPath = $Null; 
      while(-not $knownPath -and $previousPath -ne $PWD.Path) { 
        Write-Host $PWD.Path;
        $previousPath = $PWD.Path; Push-Location ..; 
        $knownPath = Get-KnownPath @args | Select-Object -First 1 -ExpandProperty FullName;
      }
    }
    Push-LocationToGlobalStack $knownPath;
  }
}
Set-Alias el Enter-Location;