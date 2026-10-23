# generate_cover_handbook_ledger.ps1
# 21:9 (1792x768) cover: a 27-row ledger, 23 filled and 4 left blank.
# Source file is ASCII-only: every CJK string is passed in as a parameter.
param(
  [string]$SourceMd = "",
  [string]$OutPng  = "",
  [string]$Kicker = "",
  [string]$Subtitle = "",
  [string]$PanelHead = "",
  [string]$PanelFoot = "",
  [string]$FontUI = "Microsoft YaHei UI",
  [string]$FontMono = "Consolas",
  [int]$Filled = 23,
  [int]$Total = 27
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$W = 1792
$H = 768

if ($SourceMd.Length -eq 0) { throw "SourceMd is required" }
if ($OutPng.Length -eq 0) { throw "OutPng is required" }

$all = [System.IO.File]::ReadAllText($SourceMd, [System.Text.Encoding]::UTF8)
$h1 = ($all -split "`n" | Where-Object { $_ -match '^#\s' } | Select-Object -First 1)
if ($h1 -eq $null) { throw "no H1 found in $SourceMd" }
$h1 = ($h1 -replace '^#\s+', '').Trim()

$parts = $h1 -split [char]0xFF5C
$title = $parts[0].Trim()
$badge = ""
if ($parts.Count -gt 1) { $badge = $parts[1].Trim() }

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = [System.Drawing.StringAlignment]::Near
$sf.LineAlignment = [System.Drawing.StringAlignment]::Near
$sf.FormatFlags = $sf.FormatFlags -bor [System.Drawing.StringFormatFlags]::NoPadding

function Measure-W([string]$t, $f) {
  return $g.MeasureString($t, $f, (New-Object System.Drawing.SizeF(9999, 9999)), $sf).Width
}

# ================= background =================
$cTop = [System.Drawing.Color]::FromArgb(255, 9, 10, 14)
$cBot = [System.Drawing.Color]::FromArgb(255, 24, 25, 31)
$bgb = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, $W, $H)), $cTop, $cBot, 88)
$g.FillRectangle($bgb, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)))
$bgb.Dispose()

# faint warm pool behind the ledger panel
$spotPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$spotPath.AddEllipse(560, -420, 1720, 1620)
$spot = New-Object System.Drawing.Drawing2D.PathGradientBrush($spotPath)
$spot.CenterPoint = New-Object System.Drawing.PointF(1330, 400)
$spot.CenterColor = [System.Drawing.Color]::FromArgb(46, 255, 232, 196)
$spot.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 255, 232, 196))
$g.FillRectangle($spot, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)))
$spot.Dispose(); $spotPath.Dispose()

# left scrim
$scrim = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, 940, $H)),
  [System.Drawing.Color]::FromArgb(240, 4, 5, 8),
  [System.Drawing.Color]::FromArgb(0, 4, 5, 8),
  0)
$g.FillRectangle($scrim, (New-Object System.Drawing.Rectangle(0, 0, 940, $H)))
$scrim.Dispose()

# ================= ledger geometry =================
$cols = 3
$rows = 9
$cellW = 258
$cellH = 44
$gapX = 12
$gapY = 12
$gridW = $cols * $cellW + ($cols - 1) * $gapX
$gridH = $rows * $cellH + ($rows - 1) * $gapY
$gx = $W - $gridW - 84
$gy = 152

# which rows stay blank: spread them so it does not read as a single block
$blankRows = @(3, 10, 18, 25)

# panel frame
$framePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(58, 255, 220, 170)), 1
$g.DrawRectangle($framePen, ($gx - 34), ($gy - 74), ($gridW + 68), ($gridH + 140))
$framePen.Dispose()

$dimBox = [System.Drawing.Color]::FromArgb(255, 40, 42, 50)
$dimLine = [System.Drawing.Color]::FromArgb(255, 62, 65, 76)
$dimLine2 = [System.Drawing.Color]::FromArgb(255, 40, 42, 50)
$gold = [System.Drawing.Color]::FromArgb(255, 238, 190, 104)

# soft glow behind each blank row
foreach ($br in $blankRows) {
  if ($br -ge $Total) { continue }
  $cc = $br % $cols
  $rr = [int]($br / $cols)
  $bx = $gx + $cc * ($cellW + $gapX)
  $by = $gy + $rr * ($cellH + $gapY)
  for ($k = 46; $k -gt 0; $k -= 4) {
    $a = [int](16 * [math]::Pow(1 - $k / 46, 2.2))
    if ($a -le 0) { continue }
    $gp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($a, 255, 200, 120)), 6
    $g.DrawEllipse($gp, ($bx + $cellW / 2 - $k), ($by + $cellH / 2 - $k), (2 * $k), (2 * $k))
    $gp.Dispose()
  }
}

for ($i = 0; $i -lt $Total; $i++) {
  $cc = $i % $cols
  $rr = [int]($i / $cols)
  $x = $gx + $cc * ($cellW + $gapX)
  $y = $gy + $rr * ($cellH + $gapY)
  $isBlank = $blankRows -contains $i

  if ($isBlank) {
    # empty checkbox, outlined in gold
    $bp = New-Object System.Drawing.Pen ($gold), 2
    $g.DrawRectangle($bp, $x, ($y + 13), 18, 18)
    $bp.Dispose()
    # two text lines, the second one empty because nothing can be written
    $l1 = New-Object System.Drawing.SolidBrush $gold
    $g.FillRectangle($l1, ($x + 30), ($y + 12), 150, 9)
    $l1.Dispose()
    $mk = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(150, 238, 190, 104)), 1
    $g.DrawLine($mk, ($x + 30), ($y + 30), ($x + 96), ($y + 30))
    $mk.Dispose()
  } else {
    # filled checkbox
    $bb = New-Object System.Drawing.SolidBrush $dimBox
    $g.FillRectangle($bb, $x, ($y + 13), 18, 18)
    $bb.Dispose()
    $bl = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(120, 120, 124, 134)), 2
    $g.DrawLine($bl, ($x + 4), ($y + 22), ($x + 8), ($y + 27))
    $g.DrawLine($bl, ($x + 8), ($y + 27), ($x + 14), ($y + 17))
    $bl.Dispose()
    $l1 = New-Object System.Drawing.SolidBrush $dimLine
    $g.FillRectangle($l1, ($x + 30), ($y + 12), 150, 9)
    $l1.Dispose()
    $l2 = New-Object System.Drawing.SolidBrush $dimLine2
    $g.FillRectangle($l2, ($x + 30), ($y + 28), 96, 7)
    $l2.Dispose()
  }
}

# fine grain
$rnd = New-Object System.Random 20261013
for ($i = 0; $i -lt 6500; $i++) {
  $x = $rnd.Next(0, $W); $y = $rnd.Next(0, $H)
  $a = $rnd.Next(3, 12)
  $col = if ($rnd.Next(0, 2) -eq 0) { [System.Drawing.Color]::FromArgb($a, 255, 242, 224) } else { [System.Drawing.Color]::FromArgb($a, 0, 0, 0) }
  $d = New-Object System.Drawing.SolidBrush $col
  $g.FillEllipse($d, $x, $y, 2, 2)
  $d.Dispose()
}

# ================= typography =================
$fontBadge = New-Object System.Drawing.Font ($FontUI, 28, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
# NB: local variable names must not shadow the -Font* parameters (PowerShell is case-insensitive)
$fMono = New-Object System.Drawing.Font ($FontMono, 21, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fMonoS = New-Object System.Drawing.Font ($FontMono, 19, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fontSub = New-Object System.Drawing.Font ($FontUI, 29, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 248, 247, 245))
$goldB = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 238, 190, 104))
$mute = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(195, 150, 148, 145))
$dim = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(155, 118, 118, 122))

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

if ($PanelHead.Length -gt 0) {
  $g.DrawString($PanelHead, $fMono, $dim, ([single]($gx - 34)), ([single]($gy - 52)), $sf)
}
if ($PanelFoot.Length -gt 0) {
  $g.DrawString($PanelFoot, $fMonoS, $goldB, ([single]($gx - 34)), ([single]($gy + $gridH + 26)), $sf)
}

$textX = 100
$maxW = 770

if ($badge.Length -gt 0) {
  $bSize = $g.MeasureString($badge, $fontBadge, (New-Object System.Drawing.SizeF(9999, 9999)), $sf)
  $pillW = [int]$bSize.Width + 52
  $pillY = 82
  $pb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(42, 238, 190, 104))
  $g.FillRectangle($pb, $textX, $pillY, $pillW, 58)
  $pb.Dispose()
  $pp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(175, 238, 190, 104)), 2
  $g.DrawRectangle($pp, $textX, $pillY, $pillW, 58)
  $pp.Dispose()
  $g.DrawString($badge, $fontBadge, $goldB, ($textX + 26), ($pillY + 14), $sf)
}

$sizes = @(88, 80, 72, 64, 58, 52)
$fontTitle = $null
$titleLines = @()
$titleSize = $sizes[$sizes.Count - 1]
foreach ($s in $sizes) {
  $f = New-Object System.Drawing.Font ($FontUI, $s, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $ls = Wrap-Text $title $f $maxW
  if ($ls.Count -le 4) { $fontTitle = $f; $titleLines = $ls; $titleSize = $s; break }
  $f.Dispose()
}
if ($fontTitle -eq $null) {
  $titleSize = 52
  $fontTitle = New-Object System.Drawing.Font ($FontUI, $titleSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $titleLines = Wrap-Text $title $fontTitle $maxW
}

$titleY = 206
$lineH = [int]([math]::Round($titleSize * 1.22))
for ($i = 0; $i -lt $titleLines.Count; $i++) {
  $g.DrawString($titleLines[$i], $fontTitle, $white, $textX, ($titleY + $i * $lineH), $sf)
}
$bottom = $titleY + $titleLines.Count * $lineH

$ruleY = $bottom + 18
$rp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 238, 190, 104), 5)
$g.DrawLine($rp, $textX, $ruleY, ($textX + 168), $ruleY)
$rp.Dispose()

$nextY = $ruleY + 40
if ($Kicker.Length -gt 0) {
  $kLines = Wrap-Text $Kicker $fontSub $maxW
  for ($i = 0; $i -lt $kLines.Count; $i++) {
    $g.DrawString($kLines[$i], $fontSub, $goldB, $textX, ($nextY + $i * 44), $sf)
  }
  $nextY += $kLines.Count * 44
}
if ($Subtitle.Length -gt 0) {
  $sLines = Wrap-Text $Subtitle $fontSub $maxW
  for ($i = 0; $i -lt $sLines.Count; $i++) {
    $g.DrawString($sLines[$i], $fontSub, $mute, $textX, ($nextY + $i * 44), $sf)
  }
}

$white.Dispose(); $goldB.Dispose(); $mute.Dispose(); $dim.Dispose()
$fontBadge.Dispose(); $fMono.Dispose(); $fMonoS.Dispose(); $fontSub.Dispose(); $fontTitle.Dispose()
$g.Dispose()
$bmp.Save($OutPng, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $OutPng)