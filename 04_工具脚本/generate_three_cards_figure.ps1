# generate_three_cards_figure.ps1
# 21:9 (1792x768) three-card figure, dark + gold, matching the ledger table.
# Source file is ASCII-only: every CJK string is passed in as a parameter.
param(
  [string]$OutPng = "",
  [string]$Header = "",
  [string]$Titles = "",
  [string]$Bodies = "",
  [string]$Footer = "",
  [string]$FontUI = "Microsoft YaHei UI"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$W = 1792
$H = 768

if ($OutPng.Length -eq 0) { throw "OutPng is required" }

$titleList = @($Titles -split "\|")
$bodyList = @($Bodies -split "\|")
if ($titleList.Count -lt 3) { throw "need 3 titles" }
if ($bodyList.Count -lt 3) { throw "need 3 bodies" }

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

$noStartCodes = @(0x3002, 0xFF0C, 0x3001, 0xFF1F, 0xFF01, 0xFF1A, 0xFF1B, 0x300D, 0x300F, 0x3011, 0x300B, 0x3009, 0xFF09, 0x002C, 0x002E)
$NO_START = ""
foreach ($cp in $noStartCodes) { $NO_START += [char]$cp }

function Wrap-Text([string]$t, $f, [int]$limitW) {
  $lines = New-Object System.Collections.ArrayList
  $cur = ""
  foreach ($ch in $t.ToCharArray()) {
    $test = $cur + $ch
    if ((Measure-W $test $f) -gt $limitW -and $cur.Length -gt 0) {
      if ($NO_START.IndexOf($ch) -ge 0) { $cur = $test; continue }
      [void]$lines.Add($cur); $cur = $ch
    } else { $cur = $test }
  }
  if ($cur.Length -gt 0) { [void]$lines.Add($cur) }
  return ,@($lines)
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

$fHead = New-Object System.Drawing.Font ($FontUI, 32, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fIdx = New-Object System.Drawing.Font ("Consolas", 22, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fTitle = New-Object System.Drawing.Font ($FontUI, 32, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fBody = New-Object System.Drawing.Font ($FontUI, 26, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fFoot = New-Object System.Drawing.Font ($FontUI, 26, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 248, 247, 245))
$goldB = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 238, 190, 104))
$mute = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(215, 172, 170, 166))

$g.DrawString($Header, $fHead, $goldB, 56, 36, $sf)

$margin = 56
$gap = 28
$cardW = [int](($W - 2 * $margin - 2 * $gap) / 3)
$cardY = 100
$cardH = 540

function Draw-Card([int]$x, [int]$y, [int]$w, [int]$h, [int]$idx, [string]$title, [string]$body, [bool]$isGold) {
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

  $idxStr = "{0:d2}" -f $idx
  $g.DrawString($idxStr, $fIdx, $goldB, ($x + 32), ($y + 32), $sf)

  $titleBrush = if ($isGold) { $goldB } else { $white }
  $tw = $w - 64
  $tLines = Wrap-Text $title $fTitle $tw
  $ty = $y + 78
  for ($k = 0; $k -lt $tLines.Count; $k++) {
    $g.DrawString($tLines[$k], $fTitle, $titleBrush, ($x + 32), ($ty + $k * 44), $sf)
  }

  $ruleY = $ty + $tLines.Count * 44 + 16
  $rp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(50, 238, 190, 104), 1)
  $g.DrawLine($rp, ($x + 32), $ruleY, ($x + $w - 32), $ruleY)
  $rp.Dispose()

  $bLines = Wrap-Text $body $fBody $tw
  $by = $ruleY + 28
  for ($k = 0; $k -lt $bLines.Count; $k++) {
    $g.DrawString($bLines[$k], $fBody, $mute, ($x + 32), ($by + $k * 40), $sf)
  }

  $path.Dispose()
}

for ($i = 0; $i -lt 3; $i++) {
  $x = $margin + $i * ($cardW + $gap)
  Draw-Card $x $cardY $cardW $cardH ($i + 1) $titleList[$i] $bodyList[$i] ($i -eq 2)
}

if ($Footer.Length -gt 0) {
  $fw = Measure-W $Footer $fFoot
  $fx = [int](($W - $fw) / 2)
  $g.DrawString($Footer, $fFoot, $goldB, $fx, 668, $sf)
}

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

$white.Dispose(); $goldB.Dispose(); $mute.Dispose()
$fHead.Dispose(); $fIdx.Dispose(); $fTitle.Dispose(); $fBody.Dispose(); $fFoot.Dispose()
$g.Dispose()
$bmp.Save($OutPng, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $OutPng)
