[CmdletBinding()]
param
(
    [string]$specificTestNames="*",
    [hashtable]$globalCredentialsLookup=@{}
)

$error.Clear()

$ErrorActionPreference = "Stop"

$currentDirectoryPath = Split-Path $script:MyInvocation.MyCommand.Path
write-verbose "Script is located at [$currentDirectoryPath]."

. "$currentDirectoryPath\_Find-rootDirectory.ps1"

$rootDirectoryPath = (Find-rootDirectory $currentDirectoryPath).FullName
$scriptsDirectoryPath = "$rootDirectoryPath\scripts\common"

. "$scriptsDirectoryPath\functions-enumerables.ps1"

$toolsDirectoryPath = "$rootDirectoryPath\tools"
$nuget = "$toolsDirectoryPath\nuget.exe"

$nugetPackagesDirectoryPath = "$toolsDirectoryPath\packages"
$packageId = "Pester"
$packageVersion = "3.3.5"
& $nuget install $packageId -Version $packageVersion -OutputDirectory $nugetPackagesDirectoryPath | Write-Verbose

$pesterDirectoryPath = ((Get-ChildItem -Path $nugetPackagesDirectoryPath -Directory) | Single -Predicate { $_.FullName -like "*$packageId.$packageVersion" }).FullName

Import-Module "$pesterDirectoryPath\tools\Pester.psm1"
Invoke-Pester -Strict -Path $scriptsDirectoryPath -TestName $specificTestNames
