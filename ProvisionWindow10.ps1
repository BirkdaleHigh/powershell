[CmdletBinding()]
Param()
function ProvisionWindows10{
[CmdletBinding()]
    $PackageRemoveList = @(
        'Microsoft.BingFinance_*'
        'Microsoft.BingNews_*'
        'Microsoft.BingSport_*'
        'Microsoft.BingWeather_*'
        'Microsoft.DesktopAppInstaller_*'
        'Microsoft.Getstarted_*'
        'Microsoft.Messaging_*'
        'Microsoft.MicrosoftOfficeHub_*'
        'Microsoft.MicrosoftSolitaireCollection_*'
        'Microsoft.MicrosoftStickyNotes_*'
        'Microsoft.OneConnect_*'
        'Microsoft.People_*'
        'Microsoft.SkypeApp_*'
        'Microsoft.StorePurchaseApp_*'
        'Microsoft.Wallet_*'
        'Microsoft.Windows.Photos_*'
        'Microsoft.WindowsCamera_*'
        'Microsoft.WindowsCommunicationsApps_*'
        'Microsoft.WindowsFeedbackHub_*'
        'Microsoft.WindowsPhone_*'
        'Microsoft.WindowsStore_*'
        'Microsoft.Xbox*'
        'Microsoft.Zune*'
    )

    $windowsPackages = Get-AppxProvisionedPackage -Online

    $ObjectsForRemoval = foreach ($name in $windowsPackages.packagename) {
        foreach($remove in $PackageRemoveList) {
            if($name -like $remove){
                $name
            }
        }
    }

    Write-verbose "Found $(write-output $ObjectsForRemoval.count) package(s) to remove."
    foreach($n in $ObjectsForRemoval){
        Write-verbose $n
        Remove-AppxProvisionedPackage -Online -packagename $n
    }
    $ObjectsForRemoval | Remove-AppxPackage -AllUsers

}

ProvisionWindows10