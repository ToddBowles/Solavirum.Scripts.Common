$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -ireplace "tests.", ""
. "$here\$sut"

. "$currentDirectoryPath\_Find-RootDirectory.ps1"
$rootDirectory = Find-RootDirectory $here

function Get-UniqueTestWorkingDirectory
{
    $tempDirectoryName = [System.Guid]::NewGuid().ToString()
    return "$here\test-working\$tempDirectoryName"
}

Describe "Get-NUnitConsoleExecutable" {
    Context "When function executed" {
        It "Returns valid NUnitConsole executable" {
            $executable = Get-NUnitConsoleExecutable

            $executable.FullName | Should Match "nunit-console\.exe"
            $executable.FullName | Should Exist
        }
    }
}