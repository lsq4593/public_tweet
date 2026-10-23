# make_contact_sheet.ps1
# Tiles a folder of images into one labelled grid so a batch can be reviewed in a single view.
param(
  [Parameter(Mandatory=$true)][string]$InDir,
  [Parameter(Mandatory=$true)][string]$Out,
  [int]$Cols = 4,
  [int]$TileW = 440,
  [int]$TileH = 300
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$files = Get-ChildItem -LiteralPath $InDir -File | Where-Object { $_.Extension -match '\.(jpg|jpeg|png)$' } | Sort-Object Name
if ($files.Count -eq 0) { Write-Output "no images in $InDir"; exit }

$rows = [int][math]::Ceiling($files.Count / $Cols)
$pad = 8
$labelH = 26
$W = $Cols * ($TileW + $pad) + $pad
$H = $rows * ($TileH + $labelH + $pad) + $pad

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

$bg = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 24, 24, 28))
$g.FillRectangle($bg, 0, 0, $W, $H)
$bg.Dispose()

$fLab = New-Object System.Drawing.Font ("Consolas", 18, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bLab = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 210, 90))
$bFrame = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 50, 50, 56))
$cCtr = New-Object System.Drawing.StringFormat
$cCtr.Alignment = [System.Drawing.StringAlignment]::Center
$cCtr.LineAlignment = [System.Drawing.StringAlignment]::Center

for ($i = 0; $i -lt $files.Count; $i++) {
  $col = $i % $Cols
  $row = [int][math]::Floor($i / $Cols)
  $x = $pad + $col * ($TileW + $pad)
  $y = $pad + $row * ($TileH + $labelH + $pad)
  $g.FillRectangle($bFrame, $x, $y, $TileW, ($TileH + $labelH))
  try {
    $im = [System.Drawing.Image]::FromFile($files[$i].FullName)
    $scale = [math]::Min($TileW / $im.Width, $TileH / $im.Height)
    $dw = [int]($im.Width * $scale); $dh = [int]($im.Height * $scale)
    $dx = $x + [int](($TileW - $dw) / 2); $dy = $y + [int](($TileH - $dh) / 2)
    $g.DrawImage($im, $dx, $dy, $dw, $dh)
    $im.Dispose()
  } catch {}
  $r = New-Object System.Drawing.RectangleF([single]$x, [single]($y + $TileH), [single]$TileW, [single]$labelH)
  $g.DrawString($files[$i].Name, $fLab, $bLab, $r, $cCtr)
}

$g.Dispose()
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Sheet -> " + $Out + "  (" + $W + "x" + $H + ", " + $files.Count + " tiles)")