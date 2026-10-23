# generate_cover_handbook_paper.ps1
# 21:9 (1792x768) cover, "printed page + red pen markup" style.
# Source file is ASCII-only: every CJK string is passed in as a parameter.
param(
  [string]$SourceMd = "",
  [string]$OutPng  = "",
  [string]$Subtitle = "",
  [string]$Kicker = "",
  [string]$FontUI = "Microsoft YaHei UI",
  [string]$FontHand = "KaiTi",
  [double]$Rotate = -3.2
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

# ================= desk background =================
$cTop = [System.Drawing.Color]::FromArgb(255, 10, 11, 15)
$cBot = [System.Drawing.Color]::FromArgb(255, 26, 27, 33)
$bgb = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, $W, $H)), $cTop, $cBot, 78)
$g.FillRectangle($bgb, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)))
$bgb.Dispose()

# warm spotlight from the upper left
$spotPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$spotPath.AddEllipse(-560, -760, 2260, 2180)
$spot = New-Object System.Drawing.Drawing2D.PathGradientBrush($spotPath)
$spot.CenterPoint = New-Object System.Drawing.PointF(430, 120)
$spot.CenterColor = [System.Drawing.Color]::FromArgb(90, 255, 226, 190)
$spot.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 255, 226, 190))
$g.FillRectangle($spot, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)))
$spot.Dispose(); $spotPath.Dispose()

# fine paper grain on the desk
$rnd = New-Object System.Random 20261012
for ($i = 0; $i -lt 5200; $i++) {
  $x = $rnd.Next(0, $W); $y = $rnd.Next(0, $H)
  $a = $rnd.Next(4, 16)
  $c = if ($rnd.Next(0, 2) -eq 0) { [System.Drawing.Color]::FromArgb($a, 255, 244, 226) } else { [System.Drawing.Color]::FromArgb($a, 0, 0, 0) }
  $d = New-Object System.Drawing.SolidBrush $c
  $g.FillEllipse($d, $x, $y, 2, 2)
  $d.Dispose()
}

# left scrim so the title stays readable
$scrim = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, 1060, $H)),
  [System.Drawing.Color]::FromArgb(232, 4, 5, 8),
  [System.Drawing.Color]::FromArgb(0, 4, 5, 8),
  0)
$g.FillRectangle($scrim, (New-Object System.Drawing.Rectangle(0, 0, 1060, $H)))
$scrim.Dispose()

# ================= paper sheet =================
$sheetCX = 1330; $sheetCY = 392
$sheetW = 664; $sheetH = 620

$g.TranslateTransform($sheetCX, $sheetCY)
$g.RotateTransform($Rotate)
$g.TranslateTransform(-$sheetCX, -$sheetCY)

# drop shadow
for ($i = 26; $i -gt 0; $i -= 2) {
  $sp = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(3, 0, 0, 0))
  $g.FillRectangle($sp,
    ($sheetCX - $sheetW / 2 + $i - 12), ($sheetCY - $sheetH / 2 + $i),
    $sheetW, $sheetH)
  $sp.Dispose()
}

$paperRect = New-Object System.Drawing.Rectangle(
  ($sheetCX - $sheetW / 2), ($sheetCY - $sheetH / 2), $sheetW, $sheetH)
$paperBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 246, 244, 239))
$g.FillRectangle($paperBrush, $paperRect)
$paperBrush.Dispose()

# faint page gradient
$pg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  $paperRect,
  [System.Drawing.Color]::FromArgb(0, 0, 0, 0),
  [System.Drawing.Color]::FromArgb(26, 120, 112, 100),
  78)
$g.FillRectangle($pg, $paperRect)
$pg.Dispose()

# inner margin
$mL = $sheetCX - $sheetW / 2 + 46
$mR = $sheetCX + $sheetW / 2 - 46

$inkBold = [System.Drawing.Color]::FromArgb(255, 58, 56, 54)
$ink = [System.Drawing.Color]::FromArgb(255, 138, 135, 130)
$inkLite = [System.Drawing.Color]::FromArgb(255, 198, 195, 189)
$rule = [System.Drawing.Color]::FromArgb(255, 214, 211, 204)

function Ink-Line([int]$x, [int]$y, [int]$w, [int]$h, $color, [int]$alpha = 255) {
  $b = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($alpha, $color.R, $color.G, $color.B))
  $g.FillRectangle($b, $x, $y, $w, $h)
  $b.Dispose()
}

# header: avatar square + name lines
$av = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 222, 219, 213))
$g.FillRectangle($av, $mL, ($sheetCY - $sheetH / 2 + 44), 62, 62)
$av.Dispose()
Ink-Line ($mL + 80) ($sheetCY - $sheetH / 2 + 50) 168 16 $inkBold
Ink-Line ($mL + 80) ($sheetCY - $sheetH / 2 + 78) 104 11 $ink
Ink-Line ($mR - 150) ($sheetCY - $sheetH / 2 + 50) 150 11 $inkLite
Ink-Line ($mR - 150) ($sheetCY - $sheetH / 2 + 72) 118 11 $inkLite

$hrY = $sheetCY - $sheetH / 2 + 134
$hrPen = New-Object System.Drawing.Pen ($rule), 2
$g.DrawLine($hrPen, $mL, $hrY, $mR, $hrY)
$hrPen.Dispose()

# section heading
Ink-Line $mL ($hrY + 28) 122 12 $inkBold
$rowY = $hrY + 62
$rowH = 62
$markRow = 2

for ($i = 0; $i -lt 5; $i++) {
  $y = $rowY + $i * $rowH
  $bul = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 206, 203, 197))
  $g.FillRectangle($bul, $mL, ($y + 5), 7, 7)
  $bul.Dispose()
  $w1 = if ($i % 2 -eq 0) { 372 } else { 330 }
  $w2 = if ($i % 2 -eq 0) { 246 } else { 300 }
  Ink-Line ($mL + 20) $y $w1 10 $ink
  Ink-Line ($mL + 20) ($y + 22) $w2 8 $inkLite
}

# the row that gets circled
$cy = $rowY + $markRow * $rowH

# ================= red pen markup =================
$red = [System.Drawing.Color]::FromArgb(255, 208, 48, 42)
$redSoft = [System.Drawing.Color]::FromArgb(255, 226, 84, 74)

function Stroke-Ellipse([int]$cx, [int]$cy2, [int]$rx, [int]$ry, $color, [int]$alpha, [double]$rot) {
  $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($alpha, $color.R, $color.G, $color.B)), 5
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $g.TranslateTransform($cx, $cy2)
  $g.RotateTransform($rot)
  $g.TranslateTransform(-$cx, -$cy2)
  $g.DrawEllipse($pen, ($cx - $rx), ($cy2 - $ry), (2 * $rx), (2 * $ry))
  $g.ResetTransform()
  $pen.Dispose()
}

$ringCX = $mL + 206
$ringCY = $cy + 14
Stroke-Ellipse $ringCX $ringCY 176 38 $red 235 -1.6
Stroke-Ellipse ($ringCX + 3) ($ringCY - 2) 171 34 $redSoft 120 -2.4

# strike-through the first line of the marked row
$strikePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 208, 48, 42)), 6
$strikePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$strikePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawLine($strikePen, ($mL + 18), ($cy + 4), ($mL + 384), ($cy - 5))
$g.DrawLine($strikePen, ($mL + 22), ($cy + 30), ($mL + 252), ($cy + 26))
$strikePen.Dispose()

# cross mark in the bottom corner of the sheet
$crossPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 208, 48, 42)), 7
$crossPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$crossPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$kx = $sheetCX + $sheetW / 2 - 92
$ky = $sheetCY + $sheetH / 2 - 88
$g.DrawLine($crossPen, $kx, $ky, ($kx + 52), ($ky + 52))
$g.DrawLine($crossPen, ($kx + 52), $ky, $kx, ($ky + 52))
$crossPen.Dispose()

$g.ResetTransform()

# ================= typography =================
$fontBadge = New-Object System.Drawing.Font ($FontUI, 30, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fontKick = New-Object System.Drawing.Font ($FontHand, 46, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fontSub = New-Object System.Drawing.Font ($FontUI, 30, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 247, 246, 244))
$redBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 232, 96, 84))
$mute = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(205, 158, 156, 152))

$textX = 104
$maxW = 830

# punctuation that must never start a line (kept as code points so this file stays ASCII)
$noStartCodes = @(0x3002, 0xFF0C, 0x3001, 0xFF1F, 0xFF01, 0xFF1A, 0xFF1B, 0x300D, 0x300F, 0x3011, 0x300B, 0x3009, 0xFF09, 0x002C, 0x002E)
$NO_START = ""
foreach ($cp in $noStartCodes) { $NO_START += [char]$cp }

function Wrap-Text([string]$t, $f, [int]$limitW) {
  $lines = New-Object System.Collections.ArrayList
  $cur = ""
  foreach ($ch in $t.ToCharArray()) {
    $test = $cur + $ch
    if ((Measure-W $test $f) -gt $limitW -and $cur.Length -gt 0) {
      # pull the trailing punctuation down onto this line instead of pushing it to the next
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
  $pillW = [int]$bSize.Width + 54
  $pillY = 96
  $pb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(44, 208, 48, 42))
  $g.FillRectangle($pb, $textX, $pillY, $pillW, 60)
  $pb.Dispose()
  $pp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(185, 208, 48, 42)), 2
  $g.DrawRectangle($pp, $textX, $pillY, $pillW, 60)
  $pp.Dispose()
  $g.DrawString($badge, $fontBadge, $redBrush, ($textX + 27), ($pillY + 15), $sf)
}

# title, shrink until it fits 3 lines
$sizes = @(80, 74, 68, 62, 56, 50)
$fontTitle = $null
$titleLines = @()
foreach ($s in $sizes) {
  $f = New-Object System.Drawing.Font ($FontUI, $s, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $ls = Wrap-Text $title $f $maxW
  if ($ls.Count -le 3) { $fontTitle = $f; $titleLines = $ls; break }
  $f.Dispose()
}
if ($fontTitle -eq $null) {
  $fontTitle = New-Object System.Drawing.Font ($FontUI, 50, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $titleLines = Wrap-Text $title $fontTitle $maxW
}

$titleY = 226
$lineH = 104
for ($i = 0; $i -lt $titleLines.Count; $i++) {
  $g.DrawString($titleLines[$i], $fontTitle, $white, $textX, ($titleY + $i * $lineH), $sf)
}
$bottom = $titleY + $titleLines.Count * $lineH

$ruleY = $bottom + 18
$rp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 208, 48, 42), 5)
$g.DrawLine($rp, $textX, $ruleY, ($textX + 168), $ruleY)
$rp.Dispose()

$nextY = $ruleY + 40
if ($Kicker.Length -gt 0) {
  $g.DrawString($Kicker, $fontKick, $redBrush, $textX, $nextY, $sf)
  $nextY += 72
}
if ($Subtitle.Length -gt 0) {
  $subLines = Wrap-Text $Subtitle $fontSub $maxW
  for ($i = 0; $i -lt $subLines.Count; $i++) {
    $g.DrawString($subLines[$i], $fontSub, $mute, $textX, ($nextY + $i * 44), $sf)
  }
}

$white.Dispose(); $redBrush.Dispose(); $mute.Dispose()
$fontBadge.Dispose(); $fontKick.Dispose(); $fontSub.Dispose(); $fontTitle.Dispose()
$g.Dispose()
$bmp.Save($OutPng, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $OutPng)