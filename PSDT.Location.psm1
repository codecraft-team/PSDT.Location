if (-not (Test-Path PreEnterLocationTabExpansion) -and (Test-Path Function:\TabExpansion)) {
  Rename-Item Function:\TabExpansion PreEnterLocationTabExpansion
}

Function global:TabExpansion($line, $lastWord) {
  $cmdletStartIndex = ([string]$line).LastIndexOf('|') + 1;
  $cmdlet = ([string]$line).Substring($cmdletStartIndex).TrimStart();
  $filter = ($cmdlet -split " " | Select-Object -Skip 1) -join ".*";
   
  switch -regex ($cmdlet) {
    "^(Enter-Location|el) .*" {
      Get-KnownPath $filter | Select-Object -ExpandProperty FullName
    }
    default {
      if (Test-Path Function:\PreEnterLocationTabExpansion) {
        PreEnterLocationTabExpansion $line $lastWord
      }
    }
  }
}

function Get-KnownPath {
  Get-Directory @args | Where-Object { ($_.FullName -notmatch "\\packages\\") -and ($_.FullName -notmatch "//packages//"); };
}

<#
.SYNOPSIS
  Looks for matchin child items based on the parameters and sets the current location to the first matching location.
  The cmdlet supports tab completion to show every matching child item.
.DESCRIPTION
  The cmdlet uses the Pop-Location cmdlet to enter the selected location.
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

#>
function Enter-Location {
  if (Test-Path $args[$args.Length - 1]) {
    Push-Location $args[$args.Length - 1];
  }
  else {
    $knownPath = Get-KnownPath @args | Select-Object -First 1 -ExpandProperty FullName;
    Push-Location $knownPath;
  }
}
Set-Alias el Enter-Location;