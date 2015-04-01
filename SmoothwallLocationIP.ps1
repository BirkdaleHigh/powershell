Param(
    # Name the room to get a list fo computers for
    [Parameter(Mandatory=$true)]
    [string]
    $Room

    , # A list of computer numbers to get. e.g. (1..32)
    [Parameter(Mandatory=$true)]
    [int[]]
    $PCNumber
)

# Require jackbennett ps/util module
Import-module util

New-ComputerList -Room $Room -Computer $PCNumber |
    Test-Connection -Count 1 -TimeToLive 1 -ErrorAction SilentlyContinue |
    select -ExpandProperty IPv4Address |
    select -ExpandProperty IPAddressToString |
    clip

Write-Warning "IP address' now copied to your clipboard"
