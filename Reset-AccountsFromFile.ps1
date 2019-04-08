[cmdletbinding(SupportsShouldProcess)] # Enalbe built-in parameters like -whatIf
Param(
    [validateScript({
        test-path $psitem
    })]
    $Path = './account_reset_info.json'
)

$list = Get-Content -path $path -raw | ConvertFrom-Json
$adAccounts = $list.username | get-aduser

foreach ($user in $adAccounts) {
    $password = $list.where({$psitem.username -eq $user.samAccountName}).password
    if($null -eq $password){
        Throw "AD user doesn't seem to exist to set password for."
    }
    if ($pscmdlet.ShouldProcess($user, "Reset Account Password")) { # Hook into -whatif to avouid making changes if specified
        Set-ADAccountPassword -Identity $user -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $password -Force)
        try { 
            Set-ADUser -Identity $user -ChangePasswordAtLogon $true -ErrorAction Stop
        }
        catch {
            if ($psitem.Exception.message -eq $passwordNeverExpiresException) {
                Write-Warning $passwordNeverExpiresException.replace('this account', $user.samAccountName)
            }
            else {
                [PSCustomObject]@{
                    username = $user.samAccountName
                    reset = $false
                    message = $psitem.Exception.message
                }
            }
        }
        [PSCustomObject]@{
            username = $user.samAccountName
            reset = $true
        }
    }
}
