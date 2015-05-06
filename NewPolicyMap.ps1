<#
Create a table to lookup what GPO name means what ID folder in the sysvol path for debugging.

This file is left in our administrator documents area for group policy notes, 
it is intended to just be "right-click" and ran with powershell to easily update the list by anyone.
#>
$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().name

get-childitem -path "\\$domain\sysvol\$domain\Policies" -Exclude PolicyDefinitions -Directory | 
    foreach {
        get-gpo -guid $_.name | select DisplayName,id
    } | 
    Sort-Object DisplayName |
    ConvertTo-Html -Head '<style>table{margin: auto;}tr:hover{background: #7ddafc}</style>' | 
    out-file (join-path $PSScriptRoot 'GPO ID Policy Map.html') -Encoding utf8 -Force
