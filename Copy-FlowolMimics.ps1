param(
    [paramter(mandatory=$true)]
    $Path
        
    , $Destination = "${env:ProgramFiles(x86)}\Keep I.T. Easy\Flowol 3\Mimics"
)

copy-item -Recurse -Force -Path $path -Destination $Destination
