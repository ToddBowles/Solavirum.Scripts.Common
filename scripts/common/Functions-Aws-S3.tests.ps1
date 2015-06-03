$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -ireplace "tests.", ""
. "$here\$sut"

. "$currentDirectoryPath\_Find-RootDirectory.ps1"
$rootDirectory = Find-RootDirectory $here

. "$here\Functions-Aws.ps1"
Ensure-AwsPowershellFunctionsAvailable

. "$here\Functions-Credentials.ps1"

function Get-AwsCredentials
{
    $s3PowershellTestsKeyLookup = "S3_POWERSHELL_TESTS_AWS_KEY"
    $s3PowershellTestsSecretLookup = "S3_POWERSHELL_TESTS_AWS_SECRET"

    $awsCreds = @{
        AwsKey = (Get-CredentialByKey $s3PowershellTestsKeyLookup);
        AwsSecret = (Get-CredentialByKey $s3PowershellTestsSecretLookup);
        AwsRegion = "ap-southeast-2";
    }
    return New-Object PSObject -Property $awsCreds
}

$bucketPrefix = "s3.powershell.tests."

Describe "Ensure-S3BucketExists" {
    Context "When bucket already exists" {
        It "Returns the bucket" {
            $creds = Get-AwsCredentials

            $bucket = "$bucketPrefix$([DateTime]::Now.ToString("yyyyMMdd.HHmmss"))"

            (New-S3Bucket -BucketName $bucket -AccessKey $creds.AwsKey -SecretKey $creds.AwsSecret -Region $creds.AwsRegion) | Write-Verbose
            $bucketCreated = $true

            try
            {
                $result = Ensure-S3BucketExists -BucketName $bucket -AwsKey $creds.AwsKey -AwsSecret $creds.AwsSecret -AwsRegion $creds.AwsRegion

                $result | Should Be $bucket
            }
            finally
            {
                if ($bucketCreated)
                {
                    (Remove-S3Bucket -BucketName $bucket -AccessKey $creds.AwsKey -SecretKey $creds.AwsSecret -Region $creds.AwsRegion -DeleteObjects -Force) | Write-Verbose
                }
            }
        }
    }

    Context "When bucket does not exist" {
        It "Creates the bucket and returns it" {
            $creds = Get-AwsCredentials

            $bucket = "$bucketPrefix$([DateTime]::Now.ToString("yyyyMMdd.HHmmss"))"

            try
            {
                $result = Ensure-S3BucketExists -BucketName $bucket -AwsKey $creds.AwsKey -AwsSecret $creds.AwsSecret -AwsRegion $creds.AwsRegion

                $result | Should Be $bucket
            }
            finally
            {
                (Remove-S3Bucket -BucketName $bucket -AccessKey $creds.AwsKey -SecretKey $creds.AwsSecret -Region $creds.AwsRegion -DeleteObjects -Force) | Write-Verbose
            }
        }
    }
}