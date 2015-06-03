$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -ireplace "tests.", ""
. "$here\$sut"

. "$currentDirectoryPath\_Find-RootDirectory.ps1"
$rootDirectory = Find-RootDirectory $here
$rootDirectoryPath = $rootDirectory.FullName

. "$rootDirectoryPath\scripts\common\Functions-Enumerables.ps1"

function Get-UniqueTestWorkingDirectory
{
    $tempDirectoryName = [DateTime]::UtcNow.ToString("yyyyMMddHHmmssff")
    return "$here\test-working\$tempDirectoryName"
}

. "$here\Functions-Credentials.ps1"

function Get-OctopusCredentials
{
    $keyLookup = "OCTOPUS_API_KEY"
    $urlLookup = "OCTOPUS_URL"

    $creds = @{
        ApiKey = (Get-CredentialByKey $keyLookup);
        Url = (Get-CredentialByKey $urlLookup);
    }
    return New-Object PSObject -Property $creds
}

function MakeTestsFail
{
    [CmdletBinding()]
    param
    (
        [string]$projectRootDirectory
    )

    $replacement = "`$1false"
    $fileOfClassToMakeFail = Get-ChildItem -Recurse -Path $projectRootDirectory -Filter DefaultThingo.cs |
        Single

    $filePath = $fileOfClassToMakeFail.FullName
    (Get-Content $filePath) |
        ForEach-Object { $_ -replace "(_shouldThingoReturnOne = )(true)", $replacement} |
        Set-Content $filePath
}

Describe "Build-DeployableComponent" {
    Context "When valid deployable component supplied but deploy is not specified" {
        It "Component is built but not deployed" {
            $testDirectoryPath = Get-UniqueTestWorkingDirectory
            $newSourceDirectoryPath = "$testDirectoryPath\src"
            $newBuildOutputDirectoryPath = "$testDirectoryPath\build-output"

            $referenceDirectoryPath = "$rootDirectoryPath\src\TestDeployableComponent"
            Copy-Item $referenceDirectoryPath $testDirectoryPath -Recurse 
            
            $result = Build-DeployableComponent -DI_sourceDirectory { return $testDirectoryPath } -DI_buildOutputDirectory { return $newBuildOutputDirectoryPath }

            (Get-ChildItem -Path $result.BuildOutput) | Any
        }
    }

    Context "When valid deployable component supplied, deploy specified and neither project prefix or projects are specified" {
        It "An exception is thrown" {
            $testDirectoryPath = Get-UniqueTestWorkingDirectory
            $newSourceDirectoryPath = "$testDirectoryPath\src"
            $newBuildOutputDirectoryPath = "$testDirectoryPath\build-output"

            $referenceDirectoryPath = "$rootDirectoryPath\src\TestDeployableComponent"
            Copy-Item $referenceDirectoryPath $testDirectoryPath -Recurse 
            
            try
            {
                Build-DeployableComponent -deploy -environment not-real -OctopusServerUrl "notreal" -OctopusServerApiKey "notreal" -DI_sourceDirectory { return $testDirectoryPath } -DI_buildOutputDirectory { return $newBuildOutputDirectoryPath }
            }
            catch 
            {
                $exception = $_
                Write-Verbose $exception
            }

            $exception | Should Not Be $null
        }
    }

    Context "When valid deployable component supplied, deploy specified and an empty list of projects is specified" {
        It "An exception is thrown" {
            $testDirectoryPath = Get-UniqueTestWorkingDirectory
            $newSourceDirectoryPath = "$testDirectoryPath\src"
            $newBuildOutputDirectoryPath = "$testDirectoryPath\build-output"

            $referenceDirectoryPath = "$rootDirectoryPath\src\TestDeployableComponent"
            Copy-Item $referenceDirectoryPath $testDirectoryPath -Recurse 
            
            try
            {
                Build-DeployableComponent -deploy -environment not-real -OctopusServerUrl "notreal" -OctopusServerApiKey "notreal" -projects @() -DI_sourceDirectory { return $testDirectoryPath } -DI_buildOutputDirectory { return $newBuildOutputDirectoryPath }
            }
            catch 
            {
                $exception = $_
                Write-Verbose $exception
            }

            $exception | Should Not Be $null
        }
    }

    Context "When valid deployable component supplied, deploy specified and a specific project is specified" {
        It "No exceptions are thrown and the specified project in the specified environment is deployed to" {
            $creds = Get-OctopusCredentials

            $testDirectoryPath = Get-UniqueTestWorkingDirectory
            $newSourceDirectoryPath = "$testDirectoryPath\src"
            $newBuildOutputDirectoryPath = "$testDirectoryPath\build-output"

            $referenceDirectoryPath = "$rootDirectoryPath\src\TestDeployableComponent"
            Copy-Item $referenceDirectoryPath $testDirectoryPath -Recurse 
            
            $project = "TEST_DeployableComponent"
            $environment = "CI"
            $result = Build-DeployableComponent -deploy -environment $environment -OctopusServerUrl $creds.Url -OctopusServerApiKey $creds.ApiKey -projects @($project) -DI_sourceDirectory { return $testDirectoryPath } -DI_buildOutputDirectory { return $newBuildOutputDirectoryPath }

            . "$rootDirectoryPath\scripts\common\Functions-OctopusDeploy.ps1"

            $projectRelease = Get-LastReleaseToEnvironment -ProjectName $project -EnvironmentName $environment -OctopusServerUrl $creds.Url -OctopusApiKey $creds.ApiKey
            
            $result.VersionInformation.New | Should Be $projectRelease
        }
    }

    Context "When deployable component with failing tests supplied and valid deploy" {
        It "An exception is thrown indicating build failure" {
            $creds = Get-OctopusCredentials

            $testDirectoryPath = Get-UniqueTestWorkingDirectory
            $newSourceDirectoryPath = "$testDirectoryPath\src"
            $newBuildOutputDirectoryPath = "$testDirectoryPath\build-output"

            $referenceDirectoryPath = "$rootDirectoryPath\src\TestDeployableComponent"
            Copy-Item $referenceDirectoryPath $testDirectoryPath -Recurse

            MakeTestsFail $testDirectoryPath
            
            $project = "TEST_DeployableComponent"
            $environment = "CI"
            try
            {
                $result = Build-DeployableComponent -deploy -environment $environment -OctopusServerUrl $creds.Url -OctopusServerApiKey $creds.ApiKey -projects @($project) -DI_sourceDirectory { return $testDirectoryPath } -DI_buildOutputDirectory { return $newBuildOutputDirectoryPath }
            }
            catch 
            {
                $exception = $_
            }

            $exception | Should Not Be $null

            . "$rootDirectoryPath\scripts\common\Functions-OctopusDeploy.ps1"

            $projectRelease = Get-LastReleaseToEnvironment -ProjectName $project -EnvironmentName $environment -OctopusServerUrl $creds.Url -OctopusApiKey $creds.ApiKey
            $projectRelease | Should Not Be $result.VersionInformation.New
        }
    }
}