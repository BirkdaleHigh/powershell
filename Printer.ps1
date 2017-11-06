Param(
    # Overwrite Computer name, room is derived from the first 3 letters.
    [string]
    $Computer = $env:computername
    , # Overwrite User name
    [string]
    $User = $env:username
    , # Write output don't map the printer
    [switch]
    $test
)
$computer = $computer.toUpper()
$User = $User.toLower()

if($computer.length -ge 3){
    $room = $Computer.remove(3)
} else {
    $room = ''
}
$map = Get-Content -Raw -Path "\\bhs-app01\Deployment\printer\valid-print-map" |
    convertfrom-json
$logpath = "\\bhs-app01\Deployment\printer\log\$Computer.log"
Start-Transcript -path $logpath -append
"Time: " + (get-date).datetime

function printerList{
    get-printer | where type -eq 'connection' | foreach {
        "\\{0}\{1}" -f $_.computername, $_.ShareName
    } | write-output
}
function filterPrinter{
    [cmdletBinding()]
    Param(
        [parameter(valuefrompipeline,position=0)]
        [pscustomobject[]]$printserver,
        [string]$Room,
        [string]$Computer,
        [string]$User
    )
    begin{
        $desiredPrinter = @()
    }
    Process{
        $keys = $printserver | gm -MemberType noteproperty | select -ExpandProperty name | where {$_ -ne 'Name'}
        # TODO: filter for computername and user
        $server = $_.name
        write-Information ("`tserver: " + $server)
        foreach($property in $keys){
            $psitem.($property) |
            where name -eq $PSBoundParameters.($property) |
            foreach {
                write-Information ("`tFound: " + $psitem.name)
                $psitem.share | foreach {
                    $desiredPrinter += "\\$server\$($_.name)"
                }
            }
        }
    }
    end{
        write-output $desiredPrinter
    }
}
function ApplyPrinter{
    Param(
        [string[]]$expected
    )
    write-Information ("current printers: ")
    $list = printerList
    $expected |
        where {$_ -notin $list.sharename} |
        foreach {
            "Attampt to add: " + $psitem
            if(-not $test){
                add-printer -connectionName $psitem
            }
        }
}

"Search for room: " + $room
"List exisitng printers:"
printerList
"list expected printers:"
$filtered = $map.server | filterPrinter -room:$room -Computer:$Computer -User:$User
write-output $filtered

"Apply Printers -"
ApplyPrinter -expected $filtered

Stop-transcript