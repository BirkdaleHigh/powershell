function Measure-ADComputer {
    param (
        # AD OU Path
        [String[]]
        $Search
    )
    $Search |
        ForEach-Object {
            $name = $psitem -split ','
            Get-ADComputer -Filter {enabled -eq $true} -SearchBase $psitem |
            Group-Object -Property count |
            Select-Object count, group, @{name='name';expression={ $name[0] }}
         } -OutVariable result |
        Measure-Object -Property count -Sum -Maximum -Minimum
        Write-Output $result
    }

function Get-MoviePlusCount {
    Measure-ADComputer -Search @(
        'OU=U5,OU=Suites,OU=U,OU=Desktop Devices,OU=Client Devices,OU=BHS,DC=BHS,DC=INTERNAL'
        'OU=U6,OU=Suites,OU=U,OU=Desktop Devices,OU=Client Devices,OU=BHS,DC=BHS,DC=INTERNAL'
        'OU=Wow Building,OU=Desktop Devices,OU=Client Devices,OU=BHS,DC=BHS,DC=INTERNAL'
        'OU=G01,OU=Suites,OU=G,OU=Desktop Devices,OU=Client Devices,OU=BHS,DC=BHS,DC=INTERNAL'
        'OU=O16,OU=Suites,OU=O,OU=Desktop Devices,OU=Client Devices,OU=BHS,DC=BHS,DC=INTERNAL'
        'OU=IT Support,OU=Client Devices,OU=BHS,DC=BHS,DC=INTERNAL'
    )
}
