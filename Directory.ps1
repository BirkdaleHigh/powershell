function Clear-Directory{
    <#
    .SYNOPSIS
    Move the content of a folder to another path under todays date.

    .DESCRIPTION
    Empty the contents of a target path into an another path for archival purposes inserting todays date into that path.

    \\server\files\work\* could be moved to \\server\files\archive\2018\06\18\*

    .EXAMPLE
    Clear-Directory -Path \\server\files\work -Destination \\server\files\archive
    .EXAMPLE
    Clear-Directory -Path \\server\files\work -ArchivePath \\server\files\archive
    #>
    Param(
    # Directory to clear
    [parameter(mandatory=$true)]
    [string]$Path

    , # Archive Directory Path
    [parameter(mandatory=$true)]
    [Alias('ArchivePath')]
    [string]$Destination

    )
    Begin{
        function Archive {
            # Expand the current date to a folder path.
            $DatePath = (get-date).toString('yyyy/MM/dd')
            # Create the target date folder
            $storePath = join-path $Destination $DatePath
            try{
                new-item -ItemType Directory -Path $storePath -ErrorAction Stop
            } catch [System.IO.IOException]{
                # Directory already exists, which is fine so carry on.
            } catch {
                # All other errors, stop the script.
                Throw $psitem
            }
            $moveList = Get-childItem $Path
            move-item -Path $moveList.fullname -Destination $storePath
        }
    }
    Process{
        # Test there actually is anything to archive before creating a folder.
        if((Get-childItem $Path).length){
            Archive
        }
    }
}


function Get-PolicyCompliance{
    <#
    .SYNOPSIS
    Get a report of the files in a target folder and their compliance with the given date.
    .DESCRIPTION
    Returns and object containing files that do or do not match the given policy date.

    .EXAMPLE
    Get-PolicyCompliance . (get-date).addyears(-2)

    Expired
    -------
    {@{BaseName=Convert-ADUserAccounts; CreationTimeUtc=10/12/2015 14:31:44; DirectoryName=N:\Documents\src\ps-birkdale..

    .NOTES
    Future additions might allow the user to specify the date field being compared (CreationTimeUtc, LastWriteTimeUTC)
    Custom formatting of the return object for prettier output
    #>
    Param(
        # Target folder containing files to check
        $Directory

        , # Compliance Date, Default of 28 days.
        [System.DateTime]
        $Date = (Get-date).addDays(-28)
    )
    Begin{
        $contents = Get-childItem -Recurse $Directory -File
    }
    Process {
        # Datetime value uses .date to zero out the hours from the provided day.
        $PendingDelete = $contents |
            Select-Object BaseName, CreationTimeUtc, DirectoryName, FullName |
            Where-Object CreationTimeUtc -le $Date.date
        $CurrentFiles = $contents |
            Select-Object BaseName, CreationTimeUtc, DirectoryName, FullName |
            Where-Object CreationTimeUtc -gt $Date.date

        # 5 or more properties triggers the automatic Format-List style output for readability.
        $output = [pscustomobject]@{
            "ExpiredCount" = $PendingDelete.length
            "Expired" = $PendingDelete | sort-Object CreationTimeUtc
            "CompliantCount" = $CurrentFiles.length
            "Compliant" = $CurrentFiles | sort-Object CreationTimeUtc
            "TestedDateTime" = Get-Date
            "PolicyDateTime" = $Date.date
        }
        Write-Output $output
    }
}
