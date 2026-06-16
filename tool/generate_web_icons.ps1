Add-Type -AssemblyName System.Drawing

$src = Join-Path $PSScriptRoot "..\assets\hackprix_logo.png"
$outDir = Join-Path $PSScriptRoot "..\web\icons"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

function Save-Icon {
    param(
        [int]$Size,
        [string]$Path,
        [bool]$Maskable
    )

    $source = [System.Drawing.Image]::FromFile($src)
    $bmp = New-Object System.Drawing.Bitmap $Size, $Size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.Clear([System.Drawing.Color]::White)

    $padding = if ($Maskable) { [int]($Size * 0.18) } else { [int]($Size * 0.08) }
    $inner = $Size - (2 * $padding)
    $scale = [Math]::Min($inner / $source.Width, $inner / $source.Height)
    $w = [int]($source.Width * $scale)
    $h = [int]($source.Height * $scale)
    $x = [int](($Size - $w) / 2)
    $y = [int](($Size - $h) / 2)
    $g.DrawImage($source, $x, $y, $w, $h)
    $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)

    $g.Dispose()
    $bmp.Dispose()
    $source.Dispose()
}

Save-Icon -Size 192 -Path (Join-Path $outDir "Icon-192.png") -Maskable $false
Save-Icon -Size 512 -Path (Join-Path $outDir "Icon-512.png") -Maskable $false
Save-Icon -Size 192 -Path (Join-Path $outDir "Icon-maskable-192.png") -Maskable $true
Save-Icon -Size 512 -Path (Join-Path $outDir "Icon-maskable-512.png") -Maskable $true

$faviconPath = Join-Path $PSScriptRoot "..\web\favicon.png"
$faviconSize = 32
$faviconSource = [System.Drawing.Image]::FromFile($src)
$faviconBmp = New-Object System.Drawing.Bitmap $faviconSize, $faviconSize, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$faviconG = [System.Drawing.Graphics]::FromImage($faviconBmp)
$faviconG.Clear([System.Drawing.Color]::Transparent)
$faviconG.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$faviconG.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$faviconPadding = [int]($faviconSize * 0.08)
$faviconInner = $faviconSize - (2 * $faviconPadding)
$faviconScale = [Math]::Min($faviconInner / $faviconSource.Width, $faviconInner / $faviconSource.Height)
$faviconW = [int]($faviconSource.Width * $faviconScale)
$faviconH = [int]($faviconSource.Height * $faviconScale)
$faviconX = [int](($faviconSize - $faviconW) / 2)
$faviconY = [int](($faviconSize - $faviconH) / 2)
$faviconG.DrawImage($faviconSource, $faviconX, $faviconY, $faviconW, $faviconH)
$faviconBmp.Save($faviconPath, [System.Drawing.Imaging.ImageFormat]::Png)
$faviconG.Dispose()
$faviconBmp.Dispose()
$faviconSource.Dispose()

Write-Output "Generated HackPrix web icons."
