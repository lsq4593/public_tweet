# generate_cover_handbook_paper_vertical.ps1
# 9:16 (1080x1920) vertical cover, "printed page + red pen markup" style.
# Source file is ASCII-only: every CJK string is passed in as a parameter.
param(
  [string]$SourceMd = "",
  [string]$OutPng  = "",
  [string]$Subtitle = "",
  [string]$Kicker = "",
  [string]$FontUI = "Microsoft YaHei UI",
  [string]$FontHand = "KaiTi",
  [double]$Rotate = -5.0
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$W = 1080
$H = 1920

if ($SourceMd.Length -gt 0 -eq $false) { throw "SourceMd is required" }
if ($OutPng.Length -gt 0 -eq $false) { throw "OutPng is required" }

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

# ================= desk background =================
$cTop = [System.Drawing.Color]::FromArgb(255, 10, 11, 15)
$cBot = [System.Drawing.Color]::FromArgb(255, 28, 29, 35)
$bgb = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, $W, $H)), $cTop, $cBot, 96)
$g.FillRectangle($bgb, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)))
$bgb.Dispose()

# warm spotlight from the upper left
$spotPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$spotPath.AddEllipse(-900, -900, 2100, 2100)
$spot = New-Object System.Drawing.Drawing2D.PathGradientBrush($spotPath)
$spot.CenterPoint = New-Object System.Drawing.PointF(300, 180)
$spot.CenterColor = [System.Drawing.Color]::FromArgb(95, 255, 226, 190)
$spot.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 255, 226, 190))
$g.FillRectangle($spot, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)))
$spot.Dispose(); $spotPath.Dispose()

# fine grain
$rnd = New-Object System.Random 20261012
for ($i = 0; $i -lt 9000; $i++) {
  $x = $rnd.Next(0, $W); $y = $rnd.Next(0, $H)
  $a = $rnd.Next(4, 16)
  $c = if ($rnd.Next(0, 2) -eq 0) { [System.Drawing.Color]::FromArgb($a, 255, 244, 226) } else { [System.Drawing.Color]::FromArgb($a, 0, 0, 0) }
  $d = New-Object System.Drawing.SolidBrush $c
  $g.FillEllipse($d, $x, $y, 2, 2)
  $d.Dispose()
}

# top scrim for the title block
$scrim = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, $W, 1080)),
  [System.Drawing.Color]::FromArgb(238, 4, 5, 8),
  [System.Drawing.Color]::FromArgb(0, 4, 5, 8),
  90)
$g.FillRectangle($scrim, (New-Object System.Drawing.Rectangle(0, 0, $W, 1080)))
$scrim.Dispose()

# bottom scrim under the page
$bScrim = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, ($H - 620), $W, 620)),
  [System.Drawing.Color]::FromArgb(0, 4, 5, 8),
  [System.Drawing.Color]::FromArgb(200, 4, 5, 8),
  90)
$g.FillRectangle($bScrim, (New-Object System.Drawing.Rectangle(0, ($H - 620), $W, 620)))
$bScrim.Dispose()

# ================= typography =================
$fontBadge = New-Object System.Drawing.Font ($FontUI, 38, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fontKick = New-Object System.Drawing.Font ($FontHand, 68, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fontSub = New-Object System.Drawing.Font ($FontUI, 42, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 247, 246, 244))
$redBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 232, 96, 84))
$mute = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(205, 158, 156, 152))

$textX = 92
$maxW = 896

# punctuation that must never start a line (code points so this file stays ASCII)
$noStartCodes = @(0x3002, 0xFF0C, 0x3001, 0xFF1F, 0xFF01, 0xFF1A, 0xFF1B, 0x300D, 0x300F, 0x3011, 0x300B, 0x3009, 0xFF09, 0x002C, 0x002E)
$NO_START = ""
foreach ($cp in $noStartCodes) { $NO_START += [char]$cp }

function Wrap-Text([string]$t, $f, [int]$limitW, [int]$maxLines) {
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

# badge
if ($badge.Length -gt 0) {
  $bSize = $g.MeasureString($badge, $fontBadge, (New-Object System.Drawing.SizeF(9999, 9999)), $sf)
  $pillW = [int]$bSize.Width + 64
  $pillY = 176
  $pb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(44, 208, 48, 42))
  $g.FillRectangle($pb, $textX, $pillY, $pillW, 76)
  $pb.Dispose()
  $pp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(185, 208, 48, 42)), 2
  $g.DrawRectangle($pp, $textX, $pillY, $pillW, 76)
  $pp.Dispose()
  $g.DrawString($badge, $fontBadge, $redBrush, ($textX + 32), ($pillY + 20), $sf)
}

# title, shrink until it fits 4 lines
$sizes = @(104, 96, 88, 80, 72, 64, 56)
$fontTitle = $null
$titleLines = @()
$titleSize = $sizes[$sizes.Count - 1]
foreach ($s in $sizes) {
  $f = New-Object System.Drawing.Font ($FontUI, $s, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $ls = Wrap-Text $title $f $maxW 4
  if ($ls.Count -le 4) { $fontTitle = $f; $titleLines = $ls; $titleSize = $s; break }
  $f.Dispose()
}
if ($fontTitle -eq $null) {
  $titleSize = 56
  $fontTitle = New-Object System.Drawing.Font ($FontUI, $titleSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $titleLines = Wrap-Text $title $fontTitle $maxW 4
}

$titleY = 330
$lineH = [int]([math]::Round($titleSize * 1.24))
for ($i = 0; $i -lt $titleLines.Count; $i++) {
  $g.DrawString($titleLines[$i], $fontTitle, $white, $textX, ($titleY + $i * $lineH), $sf)
}
$bottom = $titleY + $titleLines.Count * $lineH

$ruleY = $bottom + 22
$rp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 208, 48, 42), 6)
$g.DrawLine($rp, $textX, $ruleY, ($textX + 210), $ruleY)
$rp.Dispose()

$nextY = $ruleY + 48
if ($Kicker.Length -gt 0) {
  $g.DrawString($Kicker, $fontKick, $redBrush, $textX, $nextY, $sf)
  $nextY += 104
}
if ($Subtitle.Length -gt 0) {
  $subLines = Wrap-Text $Subtitle $fontSub $maxW 2
  for ($i = 0; $i -lt $subLines.Count; $i++) {
    $g.DrawString($subLines[$i], $fontSub, $mute, $textX, ($nextY + $i * 60), $sf)
  }
}

# ================= paper sheet =================
$sheetCX = 556; $sheetCY = 1480
$sheetW = 700; $sheetH = 652

$g.TranslateTransform($sheetCX, $sheetCY)
$g.RotateTransform($Rotate)
$g.TranslateTransform(-$sheetCX, -$sheetCY)

for ($i = 28; $i -gt 0; $i -= 2) {
  $sp = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(3, 0, 0, 0))
  $g.FillRectangle($sp,
    ($sheetCX - $sheetW / 2 + $i - 14), ($sheetCY - $sheetH / 2 + $i),
    $sheetW, $sheetH)
  $sp.Dispose()
}

$paperRect = New-Object System.Drawing.Rectangle(
  ($sheetCX - $sheetW / 2), ($sheetCY - $sheetH / 2), $sheetW, $sheetH)
$paperBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 246, 244, 239))
$g.FillRectangle($paperBrush, $paperRect)
$paperBrush.Dispose()

$pg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  $paperRect,
  [System.Drawing.Color]::FromArgb(0, 0, 0, 0),
  [System.Drawing.Color]::FromArgb(26, 120, 112, 100),
  78)
$g.FillRectangle($pg, $paperRect)
$pg.Dispose()

$mL = $sheetCX - $sheetW / 2 + 48
$mR = $sheetCX + $sheetW / 2 - 48

$inkBold = [System.Drawing.Color]::FromArgb(255, 58, 56, 54)
$ink = [System.Drawing.Color]::FromArgb(255, 138, 135, 130)
$inkLite = [System.Drawing.Color]::FromArgb(255, 198, 195, 189)
$rule = [System.Drawing.Color]::FromArgb(255, 214, 211, 204)

function Ink-Line([int]$x, [int]$y, [int]$w, [int]$h, $color) {
  $b = New-Object System.Drawing.SolidBrush $color
  $g.FillRectangle($b, $x, $y, $w, $h)
  $b.Dispose()
}

$top = $sheetCY - $sheetH / 2

$av = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 222, 219, 213))
$g.FillRectangle($av, $mL, ($top + 46), 64, 64)
$av.Dispose()
Ink-Line ($mL + 84) ($top + 52) 172 17 $inkBold
Ink-Line ($mL + 84) ($top + 82) 108 11 $ink
Ink-Line ($mR - 154) ($top + 52) 154 11 $inkLite
Ink-Line ($mR - 154) ($top + 74) 122 11 $inkLite

$hrY = $top + 142
$hrPen = New-Object System.Drawing.Pen ($rule), 2
$g.DrawLine($hrPen, $mL, $hrY, $mR, $hrY)
$hrPen.Dispose()

Ink-Line $mL ($hrY + 30) 126 12 $inkBold

$rowY = $hrY + 66
$rowH = 64
$markRow = 2
$innerW = $mR - $mL - 22

for ($i = 0; $i -lt 5; $i++) {
  $y = $rowY + $i * $rowH
  $bul = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 206, 203, 197))
  $g.FillRectangle($bul, $mL, ($y + 6), 8, 8)
  $bul.Dispose()
  $w1 = if ($i % 2 -eq 0) { [int]($innerW * 0.88) } else { [int]($innerW * 0.76) }
  $w2 = if ($i % 2 -eq 0) { [int]($innerW * 0.55) } else { [int]($innerW * 0.66) }
  Ink-Line ($mL + 22) $y $w1 11 $ink
  Ink-Line ($mL + 22) ($y + 24) $w2 8 $inkLite
}

$cy = $rowY + $markRow * $rowH

# ================= red pen markup =================
$red = [System.Drawing.Color]::FromArgb(255, 208, 48, 42)
$redSoft = [System.Drawing.Color]::FromArgb(255, 226, 84, 74)

function Stroke-Ellipse([int]$cx, [int]$cy2, [int]$rx, [int]$ry, $color, [int]$alpha, [double]$rot) {
  $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($alpha, $color.R, $color.G, $color.B)), 6
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $g.TranslateTransform($cx, $cy2)
  $g.RotateTransform($rot)
  $g.TranslateTransform(-$cx, -$cy2)
  $g.DrawEllipse($pen, ($cx - $rx), ($cy2 - $ry), (2 * $rx), (2 * $ry))
  $g.ResetTransform()
  $pen.Dispose()
}

$ringCX = $mL + [int]($innerW * 0.46)
$ringCY = $cy + 15
Stroke-Ellipse $ringCX $ringCY ([int]($innerW * 0.52)) 40 $red 235 -1.8
Stroke-Ellipse ($ringCX + 3) ($ringCY - 2) ([int]($innerW * 0.49)) 36 $redSoft 120 -2.6

$strikePen = New-Object System.Drawing.Pen ($red), 7
$strikePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$strikePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawLine($strikePen, ($mL + 16), ($cy + 5), ($mL + 20 + [int]($innerW * 0.84)), ($cy - 6))
$g.DrawLine($strikePen, ($mL + 24), ($cy + 32), ($mL + 24 + [int]($innerW * 0.52)), ($cy + 28))
$strikePen.Dispose()

$crossPen = New-Object System.Drawing.Pen ($red), 8
$crossPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$crossPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$kx = $sheetCX + $sheetW / 2 - 96
$ky = $sheetCY + $sheetH / 2 - 92
$g.DrawLine($crossPen, $kx, $ky, ($kx + 56), ($ky + 56))
$g.DrawLine($crossPen, ($kx + 56), $ky, $kx, ($ky + 56))
$crossPen.Dispose()

$g.ResetTransform()

$white.Dispose(); $redBrush.Dispose(); $mute.Dispose()
$fontBadge.Dispose(); $fontKick.Dispose(); $fontSub.Dispose(); $fontTitle.Dispose()
$g.Dispose()
$bmp.Save($OutPng, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $OutPng)