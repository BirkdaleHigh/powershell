function Get-GoogleProgress {
    <#
    .SYNOPSIS
        Quickly assess the status of Google account access
    .DESCRIPTION
        Once a users password has been reset in the domain it instantly syncs to google.
        This function returns the percent completeness of accounts with passwords set after the date google was set up.
        This data is appended onto a spreadsheet whose graph tracks progress over time.
    .EXAMPLE
        Get-GoogleProgress

        Date                Office Staff Students
        ----                ------ ----- --------
        16/03/2017 14:28:59  23.08 12.33     6.06
    .EXAMPLE
        Get-GoogleProgress | ConvertTo-CSV -NoTypeInformation | Set-Clipboard
        Easily get the data to add onto a spreadsheet for historical purposes.
    #>
    $GoogleDate = Get-date "06/12/2016 09:16:40" # Date Google Auth sync was set up.
    $Filter = 'Enabled -eq "True" -and EmailAddress -like "*@birkdaleHigh.co.uk"'
    $Students = Get-aduser -filter $Filter -SearchBase 'OU=Students,OU=Users,OU=BHS,DC=BHS,DC=INTERNAL' -properties PasswordLastSet
    $Staff = Get-aduser -filter $Filter -SearchBase 'OU=Staff,OU=Users,OU=BHS,DC=BHS,DC=INTERNAL' -properties PasswordLastSet
    $Office = Get-aduser -filter $Filter -SearchBase 'OU=Office,OU=Users,OU=BHS,DC=BHS,DC=INTERNAL' -properties PasswordLastSet

    function percent([int]$a, [int]$b){
        [Math]::Round( ($b / $a) * 100, 2)
    }

    New-Object PSObject -Property @{
        "Date"     = Get-Date
        "Students" = percent ($Students | Measure-Object).count ($Students | Where-Object PasswordLastSet -gt $GoogleDate | Measure-Object).count
        "Staff"    = percent ($Staff    | Measure-Object).count ($Staff    | Where-Object PasswordLastSet -gt $GoogleDate | Measure-Object).count
        "Office"   = percent ($Office   | Measure-Object).count ($Office   | Where-Object PasswordLastSet -gt $GoogleDate | Measure-Object).count
    }
}
