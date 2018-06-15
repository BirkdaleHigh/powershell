Param(
    [string[]]
    $Path = @("W:\Computing\Topic 12\CL\*", "W:\Computing\Topic 12\Task 12Aiv.docx" )

    , # Folde to put the work into
    [string]
    $Destination = "N:\Topic"

    , #Open the topic start file if the templates already exist.
    [string]
    $Open = "W:\Computing\Topic 12\Task 12Aiv.docx"

    , # Show the copied items.
    [Alias('Show')]
    [switch]
    $PassThru
)

try {
    New-Item -Path $Destination -ItemType Directory -ErrorAction Stop > $null
} catch {
    Write-Host "You already have a Folder at: $Destination, This will not copy the files again, carry on." -ForegroundColor Green
    if($Open){
        Start-process (Join-Path $Destination $Open)
    }
    return # Exit here if the folder already exists
}

Write-Host "Now copying work to your area: $Destination"
Copy-Item -recurse $Path -Destination $Destination -ErrorAction SilentlyContinue -PassThru:$PassThru
