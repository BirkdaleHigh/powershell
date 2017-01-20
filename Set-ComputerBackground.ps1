function Set-ComputerBackground{

. (Join-Path $PSScriptRoot .\Add-Watermark.ps1)

$path = Join-Path $env:windir 'system32\oobe\info\backgrounds'
$registry = 'HKLM:/SOFTWARE/Microsoft/Windows/CurrentVersion/Authentication/LogonUI/Background'

    if((Test-Path $path) -eq $false){
        New-Item -ItemType Directory -Force -Path $path
    }

    $background = Copy-Item '\\bhs.internal\sysvol\BHS.INTERNAL\scripts\background\images\backgroundDefault.jpg' $env:TEMP -PassThru

    Add-Watermark -source $background.FullName -destination $path

    if(Test-Path $registry){
        if(Get-ItemProperty -Path $registry -Name 'OEMBackground'){
            Set-ItemProperty -Path $registry -Name 'OEMBackground' -Value 1
        } else {
            New-ItemProperty -Path $registry -Name 'OEMBackground' -Value 1
        }
    } else {
        Write-Error "Background registry key missing."
    }

    Remove-Item -Path $background -Force
}
