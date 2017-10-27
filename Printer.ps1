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
$existingPrinters = (get-printer | where type -eq 'connection' | select -ExpandProperty name ) -join ', '
$setup = measure-command {
    if($computer){
        $room = $Computer.remove(3).toUpper()
    } else {
        $room = ''
    }
    $map = Get-Content -Raw -Path "\\bhs-app01\Deployment\printer\valid-print-map" | convertfrom-json
}
$apply = measure-command {
    $map.server | foreach {
        $server = $_.name
        $psitem.room | where name -eq $room | foreach {
            $psitem.share | foreach {
                if($test){
                    "Room: \\$server\$($_.name)" | out-default
                } else {
                    add-printer -connectionName "\\$server\$($_.name)"
                }
            }
        }
        $psitem.computer | where name -eq $computer | foreach {
            $psitem.share | foreach {
                if($test){
                    "Computer: \\$server\$($_.name)" | out-default
                } else {
                    add-printer -connectionName "\\$server\$($_.name)"
                }
            }
        }
        $psitem.user | where name -eq $user | foreach {
            $psitem.share | foreach {
                if($test){
                    "User: \\$server\$($_.name)" | out-default
                } else {
                    add-printer -connectionName "\\$server\$($_.name)"
                }
            }
        }
    }
}

"Total: $($setup.Milliseconds + $apply.Milliseconds), Setup: $($setup.Milliseconds), Apply: $($apply.Milliseconds), Username: $($user), Existing Printers: `"$existingPrinters`", New printers: `"$((get-printer | where type -eq 'connection' | select -ExpandProperty name ) -join ', ')`"" |
    Out-File -append -FilePath "\\bhs-app01\Deployment\printer\log\$Computer.log"
