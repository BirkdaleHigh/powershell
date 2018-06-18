<#
.SYNOPSIS
    Copy paths to a destination when run
.DESCRIPTION
    Script cmdlet to be used as a shortcut target for automatically copying work for users as starters t o activities.

    Powershell swtiches of interest are;
    * -NoLogo to elimintate the powershell copywrite.
    * -NoExit to leave the console open, usefull for command line lessons.
    * -NonInteractive, combined with noExit can leave the actions taken open for users to see.

    Anything after -File is interpreted for this script and not powershell.exe therefore it must be at the end of the above options.

    Be careful of the path field length limitations when creating shortcut files. You might have to create intermediate script files to call this file instead.
.EXAMPLE
    PS C:\> Powershell.exe -NoExit -NoLogo -File "\\applications\path\Start-ClassTopic.ps1" -Path "\\files\share\lesson\*" -Destination "~\lesson1" -Open "readme.docx" -Show
    Execute this file in powershell, without exiting the console to show the user where files have been copied to in their own area. If called again will open "readme.docx" instead.

    Create a shortcut with this as the target at a location users look to start programs,
    they can quickly jumpstart their lesson by getting resources they will need automatically.
#>
Param(
    # Files or filter to source files from.
    [string[]]
    $Path

    , # Folder to copy files into
    [string]
    $Destination

    , # File or path to open when already copied. Full Path or in destination.
    [string]
    $Open

    , # Show the copied items as output.
    [Alias('Show')]
    [switch]
    $PassThru
)

try {
    New-Item -Path $Destination -ItemType Directory -ErrorAction Stop > $null
} catch {
    Write-Host "You already have a Folder at: $Destination, This will not copy the files again, carry on." -ForegroundColor Green
    if($Open){
        Push-Location $Destination
        Start-Process $Open
        Pop-Location
    }
    return # Exit here if the folder already exists
}

Write-Host "Now copying work to your area: $Destination"
Copy-Item -recurse $Path -Destination $Destination -ErrorAction SilentlyContinue -PassThru:$PassThru
