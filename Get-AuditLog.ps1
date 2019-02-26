function parseLog{
    [cmdletBinding()]
    <#
        .NOTES
            Access Mask: https://docs.microsoft.com/en-gb/windows/desktop/WmiSdk/file-and-directory-access-rights-constants
    #>
    param(
        [parameter(ValueFromPipeline)]
        $log
    )
    Process{
        foreach($l in $log){
            add-member -InputObject $l -Force -NotePropertyName 'User' -NotePropertyValue $_.ReplacementStrings[1]
            add-member -InputObject $l -Force -NotePropertyName 'Type' -NotePropertyValue $_.ReplacementStrings[5]
            add-member -InputObject $l -Force -NotePropertyName 'Path' -NotePropertyValue $_.ReplacementStrings[6]

            # Humanize the acessmask string of the action being audited
            $accessMask = $value = $_.ReplacementStrings[9]
            switch ($accessMask) {
                '0x2' { $value = 'CREATE_WRITE' }
                '0x4' { $value = 'APPEND_DATA_CREATE_SUBFOLDER' }
                '0x10000' { $value = 'DELETE' }
                Default {
                    # unreconized mask will be passed through
                }
            }
            add-member -InputObject $l -Force -NotePropertyName 'AccessMask' -NotePropertyValue $value

            Write-Output $l
        }
    }
}

function filterUseful{
    [cmdletBinding()]
    param(
        [parameter(ValueFromPipeline)]
        $log
    )
    Process{
        $log | parseLog | Select-Object @(
            'TimeGenerated'
            'User'
            'Type'
            'Path'
            'AccessMask'
        )
    }
}

function Get-AuditLog{
    <#
        .DESCRIPTION
            Runs the security log through filters to make a usefuly upbject for querying NTFS Audit logging
        .EXAMPLE
            $log = Get-AuditLog -ComputerName example-server
            Get all the logs back for the last 24 hours by default to filter yourself

            e.g. `$log[2]` is row 2. `$log | select -first 200` is the first 200 rows to inspect the data.
        .EXAMPLE
            Get-AuditLog -ComputerName example-server | where accessmask -eq delete | where { -not $_.path.startsWith('D:\Home') } | ft
            Filter for only delete actions (which includes file modifications) excluding a certain file path entirely. 
    #>
    [cmdletBinding()]
    Param(
        $ComputerName,
        [securestring]
        $Credential,
        $After  = (Get-Date).AddDays(-1),
        $Before = (Get-Date)
    )
    $code = {
        Param($After,$Before)
        Get-EventLog -LogName security -After:$After -Before:$Before -EntryType SuccessAudit -InstanceId 4663
    }

    Invoke-command -ComputerName:$ComputerName -Credential:$Credential -ScriptBlock $code -ArgumentList $After,$Before | filterUseful
}

# Were this to be a module file;
# Export-ModuleMember -function 'Get-AuditLog'
