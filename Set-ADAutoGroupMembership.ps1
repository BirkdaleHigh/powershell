<#
.SYNOPSIS
    Add users from an OU path into a security group
.DESCRIPTION
    Schedule this script to run at a recurring time to automatically add users from an OU path to a group.

    This is useful for other areas of the network that depend on security group to determine access .
.PARAMETER Level
    A Base query searches only the current path or object.
    A OneLevel query searches the immediate children of that path or object.
    A Subtree query searches the current path or object and all children of that path or object.
#>
Param(
    # Distinguished name path to find users.
    [Parameter(Mandatory=$true)]
    [string]
    $SearchBase

    , # Search Scope level to find users
    [string]
    [ValidateSet('Base', 'OneLevel', 'Subtree')]
    $Level = 'Subtree'

    , # Security group to add members to
    [Parameter(Mandatory=$true)]
    [string]
    $TargetGroup

    , # Rule to filter the user search quiery with
    [string]
    $filter = "ObjectClass -eq 'user'"

    , # Host computer to import powershell ActiveDirectory module cmdlets from
    [string]
    $ModuleSource = ([DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().domainControllers[0].name)
)
try {
    $Session = New-PSSession $ModuleSource -ErrorAction Stop
} catch {
    throw $error[0]
}
import-module -Name 'ActiveDirectory' -PSSession $Session

try{
    $group = get-adgroup $TargetGroup -ErrorAction Stop
} catch {
    throw $error[0]
}
$members = get-aduser -filter $filter -SearchBase $SearchBase -SearchScope $level -ErrorAction Stop -ResultSetSize $null

Add-ADGroupMember -Identity $group.DistinguishedName -Members $members.DistinguishedName
