$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -ireplace "tests.", ""
. "$here\$sut"

. "$currentDirectoryPath\_Find-RootDirectory.ps1"
$rootDirectory = Find-RootDirectory $here

Describe "Convert-HashTableToAWSCloudFormationParametersArray" {
    Context "Using a hashtable of name/value pairs" {
        It "Creates a Parameters array for CloudFormation" {
            $paramsHashtable = @{
                "Key A"="Value A";
                "Key B"="Value B";
                "Key C"="Value C";
            }

            $array = Convert-HashTableToAWSCloudFormationParametersArray $paramsHashtable

            ($array | Measure-Object).Count | Should Be 3
            { $array | Any -Predicate { $_.ParameterKey -eq "Key A" } } | Should Not Throw
        }
    }
}