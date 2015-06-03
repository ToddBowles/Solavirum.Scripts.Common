$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -ireplace "tests.", ""
. "$here\$sut"

. "$currentDirectoryPath\_Find-RootDirectory.ps1"
$rootDirectory = Find-RootDirectory $here

Describe "Single" {
    Context "When multiple elements in input via piping with first element matching predicate" {
        It "Correctly returns single element that matches predicate" {
            $elements = @("TEST", [Guid]::NewGuid().ToString("N"), [Guid]::NewGuid().ToString("N"))

            $match = $elements | Single -Predicate { $_ -eq "TEST" }

            $match | Should Be "TEST"
        }
    }
}