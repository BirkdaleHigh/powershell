function Fix-AMDJpegDecoder {
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param(
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [alias('PSSession')]
        [System.Management.Automation.Runspaces.PSSession[]]
        $Session
    )
    Begin {
        if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]“Administrator”)){
            Write-Warning “You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!”
            Break
        }
    }

    Process{
        Invoke-Command -Session $Session -ScriptBlock {
            $path = "C:\Program Files\Common Files\ATI Technologies\Multimedia"

            Get-childItem -Path $path -filter "amf-wic-*" |
                foreach {
                    Rename-Item -Path $_.fullname -newname "amf-wic-jpeg-decoder.dll.$(get-random -Maximum 99 -Minimum 0).broken" -Force
                }

            Get-childItem -Path $path -filter "amf-wic-*"
        }
    }
}

if($args[0]){
    try{
        $session = New-PSSession $args[0] -ErrorAction Stop
    } catch {
        throw $psItem
    }

    Fix-AMDJpegDecoder -Session $session
}