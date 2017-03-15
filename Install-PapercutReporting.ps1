Param(
    [ValidatePattern('.*.exe$')]
    [string]$InstallFile
)
try {
    $source = Get-FileHash -path "$PSScriptRoot\print-provider.conf" -Algorithm SHA256 | Select-object -ExpandProperty hash
    $target = Get-FileHash -path "${env:ProgramFiles(x86)}\PaperCut NG\providers\print\win\print-provider.conf" -Algorithm SHA256 | Select-object -ExpandProperty hash
} catch {
    Write-Error "Powershell version is missing 'Get-fileHash'"
}
if($source -eq $target){
    # avoid re-running the installer if the configs contents hasn't changed at all.
    exit
}

Start-Process -FilePath (Join-Path $PSScriptRoot\$InstallFile) -ArgumentList '/TYPE=secondary_print', '/VERYSILENT' -Wait
