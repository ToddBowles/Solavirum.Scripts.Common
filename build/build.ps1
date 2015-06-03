[CmdletBinding()]
param(
	[Parameter(Mandatory=$True, Position=1)]
	[string] $version
)

$rootDir = Get-Item "$PSScriptRoot\.."
$buildDirectory = If (Test-Path "$rootDir\BuildOutput") { Get-Item "$rootDir\BuildOutput" } else { mkdir "$rootDir\BuildOutput" }
& "$rootDir\tools\Nuget.exe" pack "$rootDir\src\Solavirum.Scripts.Common.nuspec" -OutputDirectory $buildDirectory.FullName -Properties version="$version"
write-host "##teamcity[publishArtifacts '$($buildDirectory.FullName)']"