Add-Type -AssemblyName System.Drawing

$src = Join-Path $PSScriptRoot "..\assets\hackprix_logo.png"
$dest = Join-Path $PSScriptRoot "..\web\favicon.png"
$size = 32

$source = [System.Drawing.Image]::FromFile($src)
$bmp = New-Object System.Drawing.Bitmap $size, $size, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::Transparent)
$g.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

$padding = [int]($size * 0.08)
$inner = $size - (2 * $padding)
$scale = [Math]::Min($inner / $source.Width, $inner / $source.Height)
$w = [int]($source.Width * $scale)
$h = [int]($source.Height * $scale)
$x = [int](($size - $w) / 2)
$y = [int](($size - $h) / 2)
$g.DrawImage($source, $x, $y, $w, $h)
$bmp.Save($dest, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()
$source.Dispose()

Write-Output "Updated web/favicon.png (32x32, transparent)."
