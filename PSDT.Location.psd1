@{
    RootModule = '.\PSDT.Location.psm1'
    ModuleVersion = '1.0.0.0'
    GUID = '05be5ade-8f2c-4f56-a447-d652bf5f5437'
    Author = 'codecraft.team'
    CompanyName = 'codecraft.team'
    Copyright = '(c) 2017 codecraft.team. All rights reserved.'
    Description = 'A collection of PSDrive location related PowerShell developer tools.'
    RequiredModules = @()
    FunctionsToExport = @("Enter-Location")
    CmdletsToExport = @("*-*")
    VariablesToExport = '*'
    AliasesToExport = @("el")
}