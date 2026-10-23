# generate_cover_street_photo.ps1
# Real-photo 21:9 cover for "同一条街".
# Takes a 1800x771 band out of the stock street photo, mosaics every place
# name / phone number, then scales to 1792x768 (WeChat's 2.35:1 cover ratio).
#
# Source: Pexels photo 36647050 (photographer mingche lee), full licence for
# commercial use, no attribution required. Originals live in _素材库\_源图\.
param(
  [string]$Src = "C:\Users\cbs\Desktop\公众号推文\01_精准深耕系列\_素材库\图03_熟客坐店门口.jpg",
  [string]$Out = "C:\Users\cbs\Desktop\公众号推文\01_精准深耕系列\_配图\街景对比_封面.png",
  [int]$CropY = 250,
  [int[]]$Redact = @()
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

# --- crop band (21:9 out of the 1800x1200 original) ---
$CROP_X = 0
$CROP_Y = $CropY
$CROP_W = 1800
$CROP_H = 771

# --- mosaic regions ---
# FLAT list passed in via -Redact, 5 ints per region: x, y, w, h, block
# (keep it flat: PowerShell's @() collapses nested arrays)
$REDACT = $Redact

$srcImg = [System.Drawing.Bitmap]::FromFile($Src)
$band = $srcImg.Clone((New-Object System.Drawing.Rectangle($CROP_X, $CROP_Y, $CROP_W, $CROP_H)), $srcImg.PixelFormat)
$srcImg.Dispose()

function Add-Mosaic {
  param($bmp, [int]$x, [int]$y, [int]$w, [int]$h, [int]$block)
  # translate source coords -> band coords
  $bx = $x - $CROP_X
  $by = $y - $CROP_Y
  $bx = [math]::Max(0, [math]::Min($bx, $bmp.Width - 1))
  $by = [math]::Max(0, [math]::Min($by, $bmp.Height - 1))
  $w = [math]::Min($w, $bmp.Width - $bx)
  $h = [math]::Min($h, $bmp.Height - $by)
  if ($w -le 2 -or $h -le 2) { return }
  $sw = [int][math]::Max([double]1, [math]::Floor(([double]$w) / [double]$block))
  $sh = [int][math]::Max([double]1, [math]::Floor(([double]$h) / [double]$block))
  $small = New-Object System.Drawing.Bitmap($sw, $sh)
  $gs = [System.Drawing.Graphics]::FromImage($small)
  $gs.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $gs.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
  $gs.DrawImage($bmp, (New-Object System.Drawing.Rectangle(0, 0, $sw, $sh)),
    (New-Object System.Drawing.Rectangle($bx, $by, $w, $h)), [System.Drawing.GraphicsUnit]::Pixel)
  $gs.Dispose()
  $gb = [System.Drawing.Graphics]::FromImage($bmp)
  $gb.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
  $gb.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
  $gb.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighSpeed
  $gb.DrawImage($small, (New-Object System.Drawing.Rectangle($bx, $by, $w, $h)))
  $gb.Dispose()
  $small.Dispose()
}

for ($i = 0; $i -lt $REDACT.Count; $i += 5) {
  Add-Mosaic $band $REDACT[$i] $REDACT[$i + 1] $REDACT[$i + 2] $REDACT[$i + 3] $REDACT[$i + 4]
}
Write-Output ("Redacted regions: " + [int]($REDACT.Count / 5))

# --- scale to WeChat cover ratio ---
$TW = 1792
$TH = 768
$final = New-Object System.Drawing.Bitmap($TW, $TH)
$gf = [System.Drawing.Graphics]::FromImage($final)
$gf.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gf.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$gf.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$gf.DrawImage($band, (New-Object System.Drawing.Rectangle(0, 0, $TW, $TH)))
$gf.Dispose()
$band.Dispose()

$final.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
$final.Dispose()
Write-Output ("Saved: " + $Out + "  (" + $TW + "x" + $TH + ")")