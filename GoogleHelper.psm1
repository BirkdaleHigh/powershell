function Test-DirectorySync {
    callSyncTool -Test
}

function Start-DirectorySync {
    param(
        # Ignore sync impact limits
        [switch]
        $force

        , # Clear Cache
        [switch]
        $Flush
    )

    callSyncTool -Start -Force:$Force -Flush:$Flush
}

function callSyncTool {
    Param(
        [switch]
        $Start

        ,[switch]
        $Force

        ,[switch]
        $Test

        ,[switch]
        $Flush

        ,[string]
        $WorkingDirectory = "C:\GoogleData"
    )
    $time = get-date -UFormat "%Y%d%m_%H%M%S"
    if($Test){
        $prefix = "Test_"
    }
    $process = @{
        "wait" = $true
        "RedirectStandardError" = "$PSScriptRoot\stderr"
        "RedirectStandardOutput" = "$PSScriptRoot\stout"
        "FilePath" = "$env:ProgramFiles\Google Apps Directory Sync\sync-cmd.exe"
        "WorkingDirectory" = $WorkingDirectory
        "ArgumentList" = @(
            "--config", "'$WorkingDirectory\Google Apps Directory Sync.xml'"
            "--report-out", "'$WorkingDirectory\$($prefix)GoogleSync_$time.log'"
        )
    }
    if($Start){ $process.ArgumentList += "--apply" }
    if($Force){ $process.ArgumentList += "--deletelimits" }
    if($Flush){ $process.ArgumentList += "--flush" }

    start-process @process
}

function Register-DirectorySync {
    <#
    .SYNOPSIS
        Create scheduled tasks to run the google sync tool from the command line
    .DESCRIPTION
        Create a "test" job that will not make any changes to google. This job must be run on demand.
        Create a "start" job that will apply changes to google and be scheduled for 6am everyday. This job can be run on demand.
        Create a "refresh" job the will flush the cashes' used by sync-cmd when running. Will take longer to sync.

        Call Start-DirectorySync directly from this module to get access to the "-Force" option which will ignore the delete limits in google.
        This will let you wipe the whole G-Suite service data so make sure you know what you're doing.

        Task must be regestered to run as the same user account that created the Google config xml. The secrets within that file can only be decrypted by that user.
    .EXAMPLE
        PS C:\GoogleData> Register-DirectorySync Schedule

        TaskPath      TaskName            State
        --------      --------            -----
        \Google\      Start G-Suite Sync  Ready
    .EXAMPLE
        PS C:\GoogleData> Register-DirectorySync Test

        TaskPath      TaskName            State
        --------      --------            -----
        \Google\      Test G-Suite Sync  Ready
    .OUTPUTS
        Registered task in the folder \Google
    .NOTES
        sync-cmd documentation: https://support.google.com/a/answer/6152425?hl=en
        Directory Sync release notes: https://support.google.com/a/answer/1263028?hl=en
    #>
    param(
        [parameter(Mandatory)]
        [ValidateSet("Test", "Schedule","Refresh")]
        [string]
        $Type
    )
    $action = New-ScheduledTaskAction -WorkingDirectory "C:\GoogleData" -Execute "$env:windir\System32\WindowsPowershell\v1.0\powershell.exe"
    $trigger = New-ScheduledTaskTrigger -Daily -At 6am

    switch ($Type) {
        "Test" {
            $action.Arguments = "-command `"& {import-module .\GoogleHelper\GoogleHelper.psm1; Test-DirectorySync}`""
            Register-ScheduledTask -TaskName "Test G-Suite Sync" -TaskPath "Google" -Action $action -Description "Test syncing action between active directory and google"
        }
        "Schedule" {
            $action.Arguments = "-command `"& {import-module .\GoogleHelper\GoogleHelper.psm1; Start-DirectorySync}`""
            Register-ScheduledTask -TaskName "Start G-Suite Sync" -TaskPath "Google" -Action $action -Description "Start syncing action between active directory and google" -Trigger $trigger
        }
        "Refresh" {
            $action.Arguments = "-command `"& {import-module .\GoogleHelper\GoogleHelper.psm1; Start-DirectorySync -Flush}`""
            Register-ScheduledTask -TaskName "Flush G-Suite Sync Cache" -TaskPath "Google" -Action $action -Description "Sync and flush teh cache between active directory and google"
        }
        Default { Write-Error "Select either 'Test' or 'Schedule' job types to register"}
    }

}

Export-ModuleMember -Function "Test-DirectorySync", "Start-DirectorySync", "Register-DirectorySync"
