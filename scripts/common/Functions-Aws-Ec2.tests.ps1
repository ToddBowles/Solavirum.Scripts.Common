$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -ireplace "tests.", ""
. "$here\$sut"

. "$currentDirectoryPath\_Find-RootDirectory.ps1"
$rootDirectory = Find-RootDirectory $here

Describe "Get-IncrementedVersionedImageName" {
    Context "When supplied with an old name containing an existing version number" {
        It "Returns a new name with an incremented version number" {
            $oldName = "[MGMT] Development Image V1"
            $expectedName = "[MGMT] Development Image V2"

            $actualName = Get-IncrementedVersionedImageName $oldName

            $actualName | Should BeExactly $expectedName
        }
    }

    Context "When supplied with an old name containing a double-digit existing version number" {
        It "Returns a new name with an incremented version number" {
            $oldName = "[MGMT] Development Image V13"
            $expectedName = "[MGMT] Development Image V14"

            $actualName = Get-IncrementedVersionedImageName $oldName

            $actualName | Should BeExactly $expectedName
        }
    }

    Context "When supplied with an old name containing NO version number" {
        It "Returns existing name at version 2" {
            $oldName = "[MGMT] Development Image"
            $expectedName = "[MGMT] Development Image V2"

            $actualName = Get-IncrementedVersionedImageName $oldName

            $actualName | Should BeExactly $expectedName
        }
    }
}