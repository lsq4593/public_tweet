# make_grid.ps1
# Overlays a labelled coordinate grid on an image so text regions can be located precisely.
param(
  [Parameter(Mandatory=$true)][string]$In,
  [Parameter(Mandatory=$true)][string]$Out,
  [int]$Step = 100
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Bitmap]::FromFile($In)
$bmp = New-Object System.Drawing.Bitmap($src.Width, $src.Height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.DrawImage($src, 0, 0, $src.Width, $src.Height)

$f = New-Object System.Drawing.Font ("Consolas", 15, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$majorPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 255, 0, 0), 3)
$minorPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(200, 255, 255, 0), 1)
$lab = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 0, 0))
$labbg = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(190, 0, 0, 0))

for ($x = 0; $x -le $src.Width; $x += $Step) {
  $p = if (($x % 500) -eq 0) { $majorPen } else { $minorPen }
  $g.DrawLine($p, $x, 0, $x, $src.Height)
  if (($x % 500) -eq 0 -and $x -gt 0) {
    $g.DrawRectangle($labbg, ($x + 2), 2, 58, 20)
    $g.DrawString("$x", $f, $lab, ($x + 3), 2)
  }
}
for ($y = 0; $y -le $src.Height; $y += $Step) {
  $p = if (($y % 500) -eq 0) { $majorPen } else { $minorPen }
  $g.DrawLine($p, 0, $y, $src.Width, $y)
  if (($y % 500) -eq 0 -and $y -gt 0) {
    $g.DrawRectangle($labbg, 2, ($y + 2), 58, 20)
    $g.DrawString("$y", $f, $lab, 3, ($y + 3))
  }
}

$g.Dispose()
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose(); $src.Dispose()
Write-Output ("Grid -> " + $Out + "  (" + $src.Width + "x" + $src.Height + ")")