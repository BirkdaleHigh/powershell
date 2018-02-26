[cmdletBinding()]
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

$MapPath = "placeholder"

$map = Get-Content -Raw -Path $MapPath |
    convertfrom-json
$logpath = "placeholder\log\$Computer.log"
Start-Transcript -path $logpath -append
"Time: " + (get-date).datetime

Write-information @"
`t Parameters called as;
`t Map path : $MapPath
`t Computer : $computer
`t User     : $user
`t Testing  : $test
"@


function filterPrinter{
    [cmdletBinding()]
    Param(
        [parameter(valuefrompipeline,position=0)]
        [pscustomobject[]]$printserver,
        [string]$Room,
        [string]$Computer,
        [string]$User
    )
    Process{
        $keys = $printserver | gm -MemberType noteproperty | select -ExpandProperty name | where {$_ -ne 'Name'}
        # TODO: filter for computername and user
        $server = $_.name
        foreach($property in $keys){
            write-information ("[filterPrinter] Lookup by {0}" -f $property)
            $psitem.($property) |
            where name -eq $PSBoundParameters.($property) |
            foreach {
                write-information ("[filterPrinter] Matched {0} as {1}" -f $property, $psitem.name)
                foreach ($printer in $psitem.share){
                    $printer | add-member -type noteproperty -name 'UNCPath' -value "\\$server\$($printer.name)"
                    write-information (
                        "[filterPrinter] Return printer named: {0}, share {2} and set as default: {1}" -f
                        $printer.name,
                        ($printer.default -or $false),
                        $printer.UNCPath
                    )
                    write-output $printer
                }
            }
        }
    }
}

function ApplyPrinter{
    Param(
        [parameter(valuefrompipeline,mandatory)]
        $printer
    )
    Process{
        write-information ("[ApplyPrinter] Add Printer Connection: {0}" -f $printer.uncpath)
        if(-not $test){
            $Network.AddWindowsPrinterConnection($printer.UNCPath)
        }
        if($printer.default){
            write-information ("[ApplyPrinter] Set as Default printer {0}" -f $printer.uncpath)
            if(-not $test){
                $Network.SetDefaultPrinter($printer.UNCPath)
            }
        }
    }
}

$Network = New-Object -ComObject Wscript.Network

$printers = $map.server |
    filterPrinter -room:$room -Computer:$Computer -User:$User

try {
    $printers | ApplyPrinter
} catch {
    Write-information "Attempt to add printers a second time."
    try {
        $printers | ApplyPrinter
    } catch {
        throw $psitem
    }
}
