$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().name

get-childitem -path "\\$domain\sysvol\$domain\Policies" -Exclude PolicyDefinitions -Directory | 
    foreach {
        get-gpo -guid $_.name | select DisplayName,id
    } | 
    Sort-Object DisplayName |
    ConvertTo-Html -Head '<style>table{margin: auto;}tr:hover{background: #7ddafc}</style>' | 
    out-file (join-path $PSScriptRoot 'GPO ID Policy Map.html') -Encoding utf8 -Force
