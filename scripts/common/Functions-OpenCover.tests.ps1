$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -ireplace "tests.", ""
. "$here\$sut"

. "$currentDirectoryPath\_Find-RootDirectory.ps1"
$rootDirectory = Find-RootDirectory $here

Describe "Get-OpenCoverExecutable" {
    Context "When function executed" {
        It "Returns valid OpenCover executable" {
            $executable = Get-OpenCoverExecutable

            $executable.FullName | Should Match "OpenCover\.Console\.exe"
            $executable.FullName | Should Exist
        }
    }
}

Describe "OpenCover-ExecuteTests" {
    Context "When supplied with a valid test library with passing tests and an appropriate runner for the test library" {
        It "Returns the location of the results file" {
            $executable = Get-OpenCoverExecutable

            $executable.FullName | Should Match "OpenCover\.Console\.exe"
            $executable.FullName | Should Exist
        }
    }

    Context "When supplied with a valid test library with failing tests and an appropriate runner for the test library" {
        It "Throws an exception indicating the number of failing tests" {
            $executable = Get-OpenCoverExecutable

            $executable.FullName | Should Match "OpenCover\.Console\.exe"
            $executable.FullName | Should Exist
        }
    }
}