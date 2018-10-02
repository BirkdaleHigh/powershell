[CmdletBinding()]
Param()
# CmdletBinding allows the script to use -Verbose when invoked
# Param() is required by CmdletBinding which turns this file into a "script-function"
# e.g. it makes "Fix-printer.ps1 -Verbose" work

# Look for papercut to be running
try {
    Get-process "pc-client"
}
catch {
    Write-Verbose "Papercut hasn't been found running"
    $newestClient = Get-ChildItem "C:\Cache\" |
        Get-ChildItem -filter "PC-Client.exe" |
        Select-Object -last 1
    & $newestClient.fullname
    Write-Verbose "Papercut was started from path: $($newestClient.fullname)"
}

# If there's a kix strict lets invoke that
if (Test-path "C:\LOCAL.PRT") {
    Write-Verbose "Kix script found, invoke KIX32.exe"
    & "\\bhs\netlogon\KIX32.EXE" "c:\local.prt"
}
else {
    Write-Verbose "No Kix script found to run"
}
