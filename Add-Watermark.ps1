Function Add-Watermark {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
        [String[]]$source,

        [Parameter(Mandatory=$True)]
        [String]$destination,

        [String]$text = "PC " + [int]$env:COMPUTERNAME.Substring($env:COMPUTERNAME.length -2).tostring(),

        [switch]
        $greyScale,

        [byte[]]
        $RGB = (3, 3, 104),

        [byte]
        $Opacity = 255
    )
    Begin {
        $SourcePath = get-item $source -ErrorAction Stop
        $DestinationPath = (get-item $destination -ErrorAction Stop).fullname

        #Load System.Drawing assembly
        [Reflection.Assembly]::LoadWithPartialName("System.Drawing") > $Null

        #Select a font and instantiate
        $font = new-object System.Drawing.Font("Segoe UI", 96, [Drawing.FontStyle]'Bold' )

        # GreyScale image matrix
        $matrix = New-Object System.Drawing.Imaging.Colormatrix

        $matrix.Matrix00 = 0.3
        $matrix.Matrix01 = 0.3
        $matrix.Matrix02 = 0.3
        $matrix.Matrix03 = 0.0
        $matrix.Matrix04 = 0.0

        $matrix.Matrix10 = 0.59
        $matrix.Matrix11 = 0.59
        $matrix.Matrix12 = 0.59
        $matrix.Matrix13 = 0.0
        $matrix.Matrix14 = 0.0

        $matrix.Matrix20 = 0.11
        $matrix.Matrix21 = 0.11
        $matrix.Matrix22 = 0.11
        $matrix.Matrix23 = 0.0
        $matrix.Matrix24 = 0.0

        $matrix.Matrix30 = 0.0
        $matrix.Matrix31 = 0.0
        $matrix.Matrix32 = 0.0
        $matrix.Matrix33 = 1.0
        $matrix.Matrix34 = 0.0

        $matrix.Matrix40 = 0.0
        $matrix.Matrix41 = 0.0
        $matrix.Matrix42 = 0.0
        $matrix.Matrix43 = 0.0
        $matrix.Matrix44 = 1.0

        $attributes = New-Object System.Drawing.Imaging.ImageAttributes
        $attributes.SetColorMatrix($matrix)

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
            $color = [System.Drawing.Color]::FromArgb($opacity, $RGB[0], $RGB[1], $RGB[2])

            #Set up the brush for drawing image/watermark string
            $myBrush = new-object Drawing.SolidBrush $color
            $rect = New-Object Drawing.Rectangle 0,0,$img.Width,$img.Height
            $location = New-Object Drawing.RectangleF 0,100, $img.Width, 200
            $align = new-object Drawing.StringFormat
            $align.Alignment = 'Center'
            $gUnit = [Drawing.GraphicsUnit]::Pixel

            #at last, draw the water mark
            if($greyScale){
                $gImg.DrawImage($img,$rect,0,0,$img.Width,$img.Height,$gUnit, $attributes)
            } else {
                $gImg.DrawImage($img,$rect,0,0,$img.Width,$img.Height,$gUnit)
            }
            $gImg.DrawString($text, $font, $myBrush, $location, $align)

            if($greyScale){
                $newImagePath = Join-path $DestinationPath ("grey_" + $_.Name)
            } else {
                $newImagePath = Join-path $DestinationPath $_.Name
            }
            Write-Verbose $newImagePath

            $bmp.save($newImagePath,[System.Drawing.Imaging.ImageFormat]::Jpeg)
            $bmp.Dispose()
            $img.Dispose()
        }
    }
}
