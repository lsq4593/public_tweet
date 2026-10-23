# crop_image.ps1
# Crops a region out of an image (optionally overriding the output path).
param(
  [Parameter(Mandatory=$true)][string]$In,
  [Parameter(Mandatory=$true)][string]$Out,
  [Parameter(Mandatory=$true)][int]$X,
  [Parameter(Mandatory=$true)][int]$Y,
  [Parameter(Mandatory=$true)][int]$W,
  [Parameter(Mandatory=$true)][int]$H,
  [switch]$PadWhite
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Bitmap]::FromFile($In)
$rect = New-Object System.Drawing.Rectangle($X, $Y, $W, $H)
$crop = $src.Clone($rect, $src.PixelFormat)
$src.Dispose()

$crop.Save($Out, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$crop.Dispose()
Write-Output ("Cropped -> " + $Out + "  (" + $W + "x" + $H + ")")