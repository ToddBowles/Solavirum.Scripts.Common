$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -ireplace "tests.", ""
. "$here\$sut"

. "$currentDirectoryPath\_Find-RootDirectory.ps1"
$rootDirectory = Find-RootDirectory $here

function Get-UniqueTestWorkingDirectory
{
    $tempDirectoryName = [DateTime]::UtcNow.ToString("yyyyMMddHHmmssff")
    return "$here\test-working\$tempDirectoryName"
}

Describe "Get-NssmExecutable" {
    Context "When function executed" {
        It "Returns valid executable" {
            $executable = Get-NuGetExecutable

            $executable.FullName | Should Match "nssm.\.exe"
            $executable.FullName | Should Exist
        }
    }
}

Describe "Nssm-Install" {
    BeforeEach {
        $workingDirectoryPath = Get-UniqueTestWorkingDirectory
    }

    Context "When installing a valid program and specifying the max log file size as 1KB" {
        It "Log directory contains multiple files after service has been running for 60 seconds" {
            #Requires -RunAsAdministrator
            
            try
            {
                $serviceName = "T$([DateTime]::UtcNow.ToString("yyyyMMddHHmmssff"))"

                $program = "powershell -ExecutionPolicy Bypass -Command while (`$true) { Write-Output `"This is an infinite loop.`" }"
                $executable = New-Item -ItemType File -Path "$workingDirectoryPath\$serviceName.bat" -Force
                Set-Content -Path $executable.FullName -Value $program

                $logsDirectory = "$workingDirectoryPath\logs"
                $maxLogFileSize = 1000

                Nssm-Install -Service $serviceName -Program $executable -maxLogFileSizeBytesBeforeRotation $maxLogFileSize -DI_LogFilesDirectory $logsDirectory

                $service = Get-Service $serviceName
                $service.Start()
                $service.WaitForStatus("Running", [TimeSpan]::FromSeconds(30))

                Sleep -Seconds 1

                $service.Stop()
                $service.WaitForStatus("Stopped", [TimeSpan]::FromSeconds(30))

                $logFiles = Get-ChildItem $logsDirectory -Recurse -File
                # This is a bit of a hacky check, but it basically proves that the log file rotation is working as expected.
                $logFiles.Length -gt 1 | Should Be $true
            }
            finally
            {
                try
                {
                    $service = Get-Service -Name $serviceName
                    if ($service -ne $null)
                    {
                        if ($service.Status -eq "Running")
                        {
                            $service.Stop()
                            $service.WaitForStatus("Stopped", [TimeSpan]::FromSeconds(30))
                        }
                        Nssm-Remove $serviceName
                    }
                }
                catch
                {
                    Write-Warning "Could not detect existing service. Check the following text to see if its some sort of access issue."
                    Write-Warning $_
                }
            }
        }
    }

    AfterEach {
        if ([System.IO.Directory]::Exists($workingDirectoryPath))
        {
            [System.IO.Directory]::Delete($workingDirectoryPath, $true)
        }
    }
}