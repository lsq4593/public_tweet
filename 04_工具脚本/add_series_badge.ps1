# add_series_badge.ps1
# Stamps the series badge onto an existing cover image. Does not resample the artwork.
param(
  [Parameter(Mandatory = $true)][string]$InPng,
  [Parameter(Mandatory = $true)][string]$OutPng,
  [Parameter(Mandatory = $true)][string]$Badge,
  [string]$FontUI = "Microsoft YaHei UI",
  [int]$MarginX = 96,
  [int]$MarginY = 62,
  [double]$FontScale = 1.0,
  [string]$PillFill = "18,38,78",
  [string]$PillEdge = "159,201,247",
  [string]$TextColor = "169,210,255"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Image]::FromFile($InPng)
$W = $src.Width
$H = $src.Height

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($src, 0, 0, $W, $H)
$src.Dispose()

$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = [System.Drawing.StringAlignment]::Near
$sf.LineAlignment = [System.Drawing.StringAlignment]::Near
$sf.FormatFlags = $sf.FormatFlags -bor [System.Drawing.StringFormatFlags]::NoPadding

$fs = [float](34 * $FontScale)
$font = New-Object System.Drawing.Font ($FontUI, $fs, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)

$tw = $g.MeasureString($Badge, $font, (New-Object System.Drawing.SizeF(9999, 9999)), $sf).Width
$padX = [int](30 * $FontScale)
$padY = [int](20 * $FontScale)
$pillW = [int]($tw + 2 * $padX)
$pillH = [int]($fs + 2 * $padY)
$px = $MarginX
$py = $MarginY

# soft shadow so the pill reads on a light background
for ($i = 7; $i -gt 0; $i--) {
  $sp = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(7, 0, 0, 0))
  $g.FillRectangle($sp, ($px + $i), ($py + $i), $pillW, $pillH)
  $sp.Dispose()
}

$fill = $PillFill -split ','
$edge = $PillEdge -split ','
$txt = $TextColor -split ','

$pb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(238, [int]$fill[0], [int]$fill[1], [int]$fill[2]))
$g.FillRectangle($pb, $px, $py, $pillW, $pillH)
$pb.Dispose()

$pp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(215, [int]$edge[0], [int]$edge[1], [int]$edge[2])), ([int](2 * $FontScale))
$g.DrawRectangle($pp, $px, $py, $pillW, $pillH)
$pp.Dispose()

$tb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, [int]$txt[0], [int]$txt[1], [int]$txt[2]))
$g.DrawString($Badge, $font, $tb, ($px + $padX), ($py + $padY - [int](2 * $FontScale)), $sf)

$tb.Dispose(); $font.Dispose(); $g.Dispose()
$bmp.Save($OutPng, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $OutPng)