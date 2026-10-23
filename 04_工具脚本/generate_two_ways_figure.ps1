# generate_two_ways_figure.ps1
# 21:9 (1792x768) two-card comparison figure, dark + gold, matching the ledger table.
# Source file is ASCII-only: every CJK string is passed in as a parameter.
param(
  [string]$OutPng = "",
  [string]$Header = "",
  [string]$LeftTitle = "",
  [string]$RightTitle = "",
  [string]$LeftItems = "",
  [string]$RightItems = "",
  [string]$Footer = "",
  [string]$FontUI = "Microsoft YaHei UI"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$W = 1792
$H = 768

if ($OutPng.Length -eq 0) { throw "OutPng is required" }

$leftList = @($LeftItems -split "\|")
$rightList = @($RightItems -split "\|")

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = [System.Drawing.StringAlignment]::Near
$sf.LineAlignment = [System.Drawing.StringAlignment]::Near
$sf.FormatFlags = $sf.FormatFlags -bor [System.Drawing.StringFormatFlags]::NoPadding

$sfC = New-Object System.Drawing.StringFormat
$sfC.Alignment = [System.Drawing.StringAlignment]::Center
$sfC.LineAlignment = [System.Drawing.StringAlignment]::Near
$sfC.FormatFlags = $sfC.FormatFlags -bor [System.Drawing.StringFormatFlags]::NoPadding

function Measure-W([string]$t, $f) {
  return $g.MeasureString($t, $f, (New-Object System.Drawing.SizeF(9999, 9999)), $sf).Width
}

function New-RoundRectPath([int]$x, [int]$y, [int]$w, [int]$h, [int]$r) {
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $p.AddArc($x, $y, $d, $d, 180, 90)
  $p.AddArc(($x + $w - $d), $y, $d, $d, 270, 90)
  $p.AddArc(($x + $w - $d), ($y + $h - $d), $d, $d, 0, 90)
  $p.AddArc($x, ($y + $h - $d), $d, $d, 90, 90)
  $p.CloseFigure()
  return $p
}

# ================= background =================
$cTop = [System.Drawing.Color]::FromArgb(255, 9, 10, 14)
$cBot = [System.Drawing.Color]::FromArgb(255, 24, 25, 31)
$bgb = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, $W, $H)), $cTop, $cBot, 90)
$g.FillRectangle($bgb, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)))
$bgb.Dispose()

$spotPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$spotPath.AddEllipse(-300, -640, 2400, 1900)
$spot = New-Object System.Drawing.Drawing2D.PathGradientBrush($spotPath)
$spot.CenterPoint = New-Object System.Drawing.PointF(700, 40)
$spot.CenterColor = [System.Drawing.Color]::FromArgb(38, 255, 232, 196)
$spot.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 255, 232, 196))
$g.FillRectangle($spot, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)))
$spot.Dispose(); $spotPath.Dispose()

# ================= fonts / colors =================
$fHead = New-Object System.Drawing.Font ($FontUI, 32, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fTitle = New-Object System.Drawing.Font ($FontUI, 34, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fBody = New-Object System.Drawing.Font ($FontUI, 28, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fIdx = New-Object System.Drawing.Font ("Consolas", 20, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fFoot = New-Object System.Drawing.Font ($FontUI, 26, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 248, 247, 245))
$goldB = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 238, 190, 104))
$mute = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(215, 172, 170, 166))
$dim = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(160, 116, 116, 120))
$inkA = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 248, 247, 245))
$inkB = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(220, 172, 170, 166))

# ================= header =================
$g.DrawString($Header, $fHead, $goldB, 64, 36, $sf)

# ================= two cards =================
$gap = 40
$margin = 64
$cardY = 92
$cardH = 548
$cardW = [int](($W - 2 * $margin - $gap) / 2)
$cardX = @($margin, ($margin + $cardW + $gap))

function Draw-Card([int]$x, [int]$y, [int]$w, [int]$h, [string]$title, $items, [bool]$isGold) {
  $path = New-RoundRectPath $x $y $w $h 8
  $fillCol = if ($isGold) {
    [System.Drawing.Color]::FromArgb(255, 28, 24, 18)
  } else {
    [System.Drawing.Color]::FromArgb(255, 16, 17, 22)
  }
  $fb = New-Object System.Drawing.SolidBrush $fillCol
  $g.FillPath($fb, $path)
  $fb.Dispose()

  $edgeCol = if ($isGold) {
    [System.Drawing.Color]::FromArgb(140, 238, 190, 104)
  } else {
    [System.Drawing.Color]::FromArgb(70, 150, 152, 160)
  }
  $ep = New-Object System.Drawing.Pen $edgeCol, 1
  $g.DrawPath($ep, $path)
  $ep.Dispose()

  $barCol = if ($isGold) {
    [System.Drawing.Color]::FromArgb(255, 238, 190, 104)
  } else {
    [System.Drawing.Color]::FromArgb(160, 150, 152, 160)
  }
  $bar = New-Object System.Drawing.SolidBrush $barCol
  $g.FillRectangle($bar, $x, $y, 6, $h)
  $bar.Dispose()

  $titleBrush = if ($isGold) { $goldB } else { $white }
  $g.DrawString($title, $fTitle, $titleBrush, ($x + 36), ($y + 28), $sf)

  $ruleY = $y + 82
  $rp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(50, 238, 190, 104), 1)
  $g.DrawLine($rp, ($x + 36), $ruleY, ($x + $w - 36), $ruleY)
  $rp.Dispose()

  $itemH = 96
  $startY = $ruleY + 22
  for ($i = 0; $i -lt $items.Count; $i++) {
    $iy = $startY + $i * $itemH
    $idx = "{0:d2}" -f ($i + 1)
    $idxBrush = if ($isGold) { $goldB } else { $dim }
    $g.DrawString($idx, $fIdx, $idxBrush, ($x + 36), ($iy + 8), $sf)
    $bodyBrush = if ($isGold) { $inkA } else { $inkB }
    $g.DrawString($items[$i], $fBody, $bodyBrush, ($x + 88), ($iy + 4), $sf)
  }

  $path.Dispose()
}

Draw-Card $cardX[0] $cardY $cardW $cardH $LeftTitle $leftList $true
Draw-Card $cardX[1] $cardY $cardW $cardH $RightTitle $rightList $false

# footer
if ($Footer.Length -gt 0) {
  $fw = Measure-W $Footer $fFoot
  $fx = [int](($W - $fw) / 2)
  $g.DrawString($Footer, $fFoot, $goldB, $fx, 686, $sf)
}

# grain
$rnd = New-Object System.Random 20261019
for ($i = 0; $i -lt 4200; $i++) {
  $x = $rnd.Next(0, $W); $y = $rnd.Next(0, $H)
  $a = $rnd.Next(3, 11)
  $col = if ($rnd.Next(0, 2) -eq 0) {
    [System.Drawing.Color]::FromArgb($a, 255, 242, 224)
  } else {
    [System.Drawing.Color]::FromArgb($a, 0, 0, 0)
  }
  $d = New-Object System.Drawing.SolidBrush $col
  $g.FillEllipse($d, $x, $y, 2, 2)
  $d.Dispose()
}

$white.Dispose(); $goldB.Dispose(); $mute.Dispose(); $dim.Dispose()
$inkA.Dispose(); $inkB.Dispose()
$fHead.Dispose(); $fTitle.Dispose(); $fBody.Dispose(); $fIdx.Dispose(); $fFoot.Dispose()
$g.Dispose()
$bmp.Save($OutPng, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $OutPng)
