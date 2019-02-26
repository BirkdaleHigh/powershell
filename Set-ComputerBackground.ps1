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

function Enable-PersonalizationCSP{
    Param(
        #Change as per your needs
        $DesktopPath = "$($env:temp)\Desktop.jpg",

        # Lock screen image path
        $LockScreenPath = "$($env:temp)\LockScreen.jpg"
    )
    $RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

    $StatusValue = "1"

    IF( -not (Test-Path $RegKeyPath)){
        New-Item -Path $RegKeyPath -Force | Out-Null
    }

    New-ItemProperty -Path $RegKeyPath -Name "DesktopImageStatus" -Value $StatusValue -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $RegKeyPath -Name "LockScreenImageStatus" -Value $StatusValue -PropertyType DWORD -Force | Out-Null

    New-ItemProperty -Path $RegKeyPath -Name "DesktopImagePath" -Value $DesktopPath -PropertyType STRING -Force | Out-Null
    New-ItemProperty -Path $RegKeyPath -Name "DesktopImageUrl" -Value $DesktopPath -PropertyType STRING -Force | Out-Null
    New-ItemProperty -Path $RegKeyPath -Name "LockScreenImagePath" -Value $LockScreenPath -PropertyType STRING -Force | Out-Null
    New-ItemProperty -Path $RegKeyPath -Name "LockScreenImageUrl" -Value $LockScreenPath -PropertyType STRING -Force | Out-Null
}

New-CustomBackground{
    Param(
        [string]$Path
    )
    . (Join-Path $PSScriptRoot .\Add-Watermark.ps1)

    $item = get-item $Path -ErrorAction Stop

    New-Item -Type Directory -Force "c:\ProgramData\Scripts" -ErrorAction SilentlyContinue > $null
    Add-Watermark -source $item.FullName -destination "c:\ProgramData\Scripts\"
    Add-Watermark -source $item.FullName -destination "c:\ProgramData\Scripts\" -GreyScale
}
