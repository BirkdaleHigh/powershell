<#
.SYNOPSIS
    Automate adding taskbar pins for users
.DESCRIPTION
    By listing the directory of shortcuts it's easy to copy the shortcuts from the shared start-menu location into the shared taskbar folder for pinning.
    This keeps the same workflow for adding desktop, startmenu AND Taskbar shortcuts.
    When invoking this script as the current user, sharing and NTFS permissions will restrict the shortcuts the user sees, just like the desktop and startmenu shortcuts.
    Shortcuts the "Target Path" doesn't exist or can't be accessed will not be added.
#>
Param(
    # Source of icons to pin to the taskbar
    [Parameter(Mandatory=$true)]
    [string]$Path

    , # Path to 'PinTo10' executable
    [string]$Executable = (Join-path $PSScriptRoot 'PinTo10v2.exe')
)

Import-module "P:\ps-util\util.psm1" -Scope "Local"

Get-ChildItem $path -Filter '*.lnk' |
    Select-Object -ExpandProperty FullName |
    Get-Shortcut |
    Select-Object -ExpandProperty TargetPath |
    ForEach-Object {
        & $Executable '/pintb', $psitem
    }
