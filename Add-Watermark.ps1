Function Add-Watermark {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
        [String[]]$source,

        [Parameter(Mandatory=$True)]
        [String]$destination,

        [String]$text = "PC " + [int]$env:COMPUTERNAME.Substring($env:COMPUTERNAME.length -2).tostring()
    )
    Begin {
        $SourcePath = get-item $source -ErrorAction Stop
        $DestinationPath = (get-item $destination -ErrorAction Stop).fullname

        #Load System.Drawing assembly
        [Reflection.Assembly]::LoadWithPartialName("System.Drawing") > $Null

        #Select a font and instantiate
        $font = new-object System.Drawing.Font("Segoe UI", 96, [Drawing.FontStyle]'Bold' )

    }
    Process {
        $SourcePath | ForEach-Object {
            #Get the image
            Write-Verbose ("processing " + $_.Name)
            $img = [System.Drawing.Image]::FromFile($_.FullName)

            #Create a bitmap
            $bmp = new-object System.Drawing.Bitmap([int]($img.width)),([int]($img.height))

            #Intialize Graphics
            $gImg = [System.Drawing.Graphics]::FromImage($bmp)
            $gImg.SmoothingMode = "AntiAlias"
            $gImg.TextRenderingHint = 'AntiAlias'

            #Set the color required for the watermark. You can change the color combination
            $color = [System.Drawing.Color]::FromArgb(3, 3, 104)

            #Set up the brush for drawing image/watermark string
            $myBrush = new-object Drawing.SolidBrush $color
            $rect = New-Object Drawing.Rectangle 0,0,$img.Width,$img.Height
            $location = New-Object Drawing.RectangleF 0,100, $img.Width, 200
            $align = new-object Drawing.StringFormat
            $align.Alignment = 'Center'
            $gUnit = [Drawing.GraphicsUnit]::Pixel

            #at last, draw the water mark
            $gImg.DrawImage($img,$rect,0,0,$img.Width,$img.Height,$gUnit)
            $gImg.DrawString($text, $font, $myBrush, $location, $align)

            $newImagePath = Join-path $DestinationPath $_.Name
            Write-Verbose $newImagePath

            $bmp.save($newImagePath,[System.Drawing.Imaging.ImageFormat]::Jpeg)
            $bmp.Dispose()
            $img.Dispose()
        }
    }
}
