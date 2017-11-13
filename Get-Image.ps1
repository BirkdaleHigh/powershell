Param(
    # Default NASA recent Sun photo
    $url = "http://sdo.gsfc.nasa.gov/assets/img/latest/latest_2048_0335.jpg"
)
$filename = split-path $url -Leaf

function DuplicateFile{
    Param(
        [System.IO.FileInfo]
        $file
    )
    Process{
        if(test-path $file.fullname){
            $path = $file.fullname
            $newName = $path.replace($file.BaseName, $file.BaseName + (get-date).tostring("_yyyyMMdd_HH"))
            copy-item $path $newName
        }
    }
}

# backup old image
$f = Get-Item $filename -ErrorAction SilentlyContinue
if($f){
    DuplicateFile $f
}

# LOL MS, use the 50 settings in windows disabling TLS1.0 already.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12

$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, (join-path $psscriptroot $filename ) )
