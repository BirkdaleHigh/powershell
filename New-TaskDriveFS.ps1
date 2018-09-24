function New-TaskDriveFS {
    [cmdletBinding()]
    <#
    .SYNOPSIS
        Create scheduled tasks called at logon to start Google Drive FileStream
    .DESCRIPTION
        Windows 10 doesn't seem to auto-start the Google Drive FileStream application once the GPO has intalled it.

        This function registers a task to that runs at logon to start the GoogleDriveFS executable.

        This is a powershell script because the GoogleDriveFS exe gets installed under a version specific path,
        so the path must be deduced.
    .EXAMPLE
        New-TaskDriveFS

        TaskPath      TaskName                    State
        --------      --------                    -----
        \Google\      Start Drive FileStream      Ready
    .EXAMPLE
        New-TaskDriveFS -InformationAction Continue

        Task already has been created, exiting.
    .OUTPUTS
        Registered task in the folder \Google
    .NOTES
        TODO: Check if an existing tasks action path still exists, otherwise remove the task.
        TODO: Check the version of an existing task action and replace it if a newer file is present.
    #>
    param(
        # Path to google drive file stream install location
        [string]
        $Path = 'C:\Program Files\Google\Drive File Stream\'

        , # Folder under task scheduler to create task
        [ValidatePattern("^\\.*\\$")]
        [string]
        $TaskPath = "\Google\"

        , # Name to call task
        [string]
        $TaskName = "Start Drive FileStream"
    )
    try{
        $existing = Get-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName
    } catch {
        Write-Information "Existing task has not been found, register a new one."
    }

    if($existing) {
        Write-Information "Task name already Exists, exiting without creating a new one."
        return
    }

    $programLocation = get-childitem $Path -Filter 'GoogleDriveFS.exe' -Recurse |
        sort-object VersionInfo.ProductVersion |
        Select-Object -Last 1
    $action = New-ScheduledTaskAction -WorkingDirectory $programLocation.DirectoryName -Execute 'GoogleDriveFS.exe'
    $trigger = New-ScheduledTaskTrigger -AtLogOn

    $taskProperties = @{
        TaskPath = $TaskPath
        TaskName = $TaskName
        Description = "Start file stream sync to appear as a mapped drive."
        Action = $action
        Trigger = $trigger
    }

    Register-ScheduledTask @taskProperties

}
