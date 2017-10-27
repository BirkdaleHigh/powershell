Param(
    # Map file to verify, template at
    $map = "\\bhs-app01\Deployment\printer\map.json"
    , # output path
    $validpath = "\\bhs-app01\Deployment\printer\valid-print-map"
    , # Output a template map file. Pipe to out-file "mymap.json"
    [switch]$GetTemplate
)

$template= @'
{
    "Server":[
        {
            "Name": "org-server1",
            "Room":[
                {
                    "name": "roomA",
                    "share": [
                        {
                            "Name": "printer1",
                            "Default": true
                        },
                        {
                            "Name": "printer2"
                        }
                    ]
                }
            ],
            "Computer":[
                {
                    "name": "labA1",
                    "share": [
                        {
                            "Name": "printer3"
                        }
                    ]
                }
            ],
            "User":[
                {
                    "Name": "example",
                    "share": [
                        {
                            "Name": "printer1"
                        }
                    ]
                }
            ]
        },
        {
            "Name": "org-server2",
            "Computer": [
                {
                    "name": "LabA1",
                    "share": [
                        {
                            "Name": "printer1"
                        }
                    ]
                }
            ]
        }
    ]
}
'@

if($GetTemplate){
    Write-warning "Pipe this to | out-file mymap.json"
    write-output $template
    return
}

function create{
    Param(
        [string]$in,
        [string]$out
    )
    Get-Content -Raw -path $in |
        ConvertFrom-Json |
        ConvertTo-Json -depth 100 |
        Out-File -FilePath $out -Encoding 'utf8' -force
}

$file = get-item $map -errorAction Stop
try{
    $output = Get-item $validPath
} catch {
    $new = $True
}

# Convert from json and back to json to confirm powershell doesn't have any error reading the format.
if($new){
    write-warning "No file found, creating new at $validpath"
    create -in $file.fullname -out $validPath
}

if($file.LastWriteTimeUtc -gt $output.LastWriteTimeUtc){
    write-warning "Map file newer than validated file, updating at $validpath"
    create -in $file.fullname -out $output.fullname
} else {
    write-warning "Map last write date is not newer than the validated file."
}


