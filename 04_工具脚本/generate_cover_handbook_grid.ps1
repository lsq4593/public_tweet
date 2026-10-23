# generate_cover_handbook_grid.ps1
# 21:9 (1792x768) cover: a 60-cell submission wall, one cell lit under a spotlight.
# Source file is ASCII-only: every CJK string is passed in as a parameter.
param(
  [string]$SourceMd = "",
  [string]$OutPng  = "",
  [string]$Kicker = "",
  [string]$Subtitle = "",
  [string]$CaptionTop = "",
  [string]$CaptionBottom = "",
  [string]$FontUI = "Microsoft YaHei UI",
  [string]$FontHand = "KaiTi",
  [string]$FontMono = "Consolas",
  [int]$LitCol = 7,
  [int]$LitRow = 2
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
$cTop = [System.Drawing.Color]::FromArgb(255, 8, 8, 11)
$cBot = [System.Drawing.Color]::FromArgb(255, 22, 22, 28)
$bgb = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, $W, $H)), $cTop, $cBot, 92)
$g.FillRectangle($bgb, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)))
$bgb.Dispose()

# ================= grid geometry =================
$cols = 10
$rows = 6
$cell = 60
$gap = 16
$gridW = $cols * $cell + ($cols - 1) * $gap
$gridH = $rows * $cell + ($rows - 1) * $gap
$gx = $W - $gridW - 58
$gy = [int](($H - $gridH) / 2) - 18

$litX = $gx + $LitCol * ($cell + $gap)
$litY = $gy + $LitRow * ($cell + $gap)
$litCX = $litX + [int]($cell / 2)
$litCY = $litY + [int]($cell / 2)

# ================= spotlight cone =================
$cone = New-Object System.Drawing.Drawing2D.GraphicsPath
$cone.StartFigure()
$cone.AddLine(($litCX - 54), -20)
$cone.AddLine(($litCX + 54), -20)
$cone.AddLine(($litCX + 186), ($litY + $cell + 40))
$cone.AddLine(($litCX - 186), ($litY + $cell + 40))
$cone.CloseFigure()
$coneBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, $W, ($litY + $cell + 40))),
  [System.Drawing.Color]::FromArgb(62, 255, 236, 205),
  [System.Drawing.Color]::FromArgb(0, 255, 236, 205),
  90)
$g.FillPath($coneBrush, $cone)
$coneBrush.Dispose(); $cone.Dispose()

# glow pool around the lit cell
for ($r = 190; $r -gt 0; $r -= 5) {
  $a = [int](20 * [math]::Pow(1 - $r / 190, 2.0))
  if ($a -le 0) { continue }
  $gp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($a, 255, 206, 120)), 6
  $g.DrawEllipse($gp, ($litCX - $r), ($litCY - $r), (2 * $r), (2 * $r))
  $gp.Dispose()
}

# ================= cells =================
$cellBg = [System.Drawing.Color]::FromArgb(255, 28, 29, 36)
$cellEd = [System.Drawing.Color]::FromArgb(255, 56, 58, 68)

for ($r = 0; $r -lt $rows; $r++) {
  for ($c = 0; $c -lt $cols; $c++) {
    if ($c -eq $LitCol -and $r -eq $LitRow) { continue }
    $x = $gx + $c * ($cell + $gap)
    $y = $gy + $r * ($cell + $gap)
    $p = New-RoundRectPath $x $y $cell $cell 10
    $b = New-Object System.Drawing.SolidBrush $cellBg
    $g.FillPath($b, $p)
    $b.Dispose()
    $e = New-Object System.Drawing.Pen $cellEd, 1
    $g.DrawPath($e, $p)
    $e.Dispose()
    $p.Dispose()
  }
}

# ================= the lit cell =================
$lp = New-RoundRectPath $litX $litY $cell $cell 10
$litBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 250, 224, 168))
$g.FillPath($litBrush, $lp)
$litBrush.Dispose()
$litPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 255, 246, 222)), 2
$g.DrawPath($litPen, $lp)
$litPen.Dispose()
$lp.Dispose()

# envelope glyph inside the lit cell
$envW = 40; $envH = 27
$envX = $litX + [int](($cell - $envW) / 2)
$envY = $litY + [int](($cell - $envH) / 2)
$envPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(235, 96, 62, 18)), 3
$envPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
$g.DrawRectangle($envPen, $envX, $envY, $envW, $envH)
$g.DrawLine($envPen, $envX, $envY, ($envX + [int]($envW / 2)), ($envY + 14))
$g.DrawLine($envPen, ($envX + $envW), $envY, ($envX + [int]($envW / 2)), ($envY + 14))
$envPen.Dispose()

# ================= edge vignette =================
$edge = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, $W, 200)),
  [System.Drawing.Color]::FromArgb(180, 0, 0, 0),
  [System.Drawing.Color]::FromArgb(0, 0, 0, 0),
  90)
$g.FillRectangle($edge, (New-Object System.Drawing.Rectangle(0, 0, $W, 200)))
$edge.Dispose()

$edge2 = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, ($H - 200), $W, 200)),
  [System.Drawing.Color]::FromArgb(0, 0, 0, 0),
  [System.Drawing.Color]::FromArgb(170, 0, 0, 0),
  90)
$g.FillRectangle($edge2, (New-Object System.Drawing.Rectangle(0, ($H - 200), $W, 200)))
$edge2.Dispose()

# left scrim
$scrim = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, 980, $H)),
  [System.Drawing.Color]::FromArgb(236, 5, 5, 8),
  [System.Drawing.Color]::FromArgb(0, 5, 5, 8),
  0)
$g.FillRectangle($scrim, (New-Object System.Drawing.Rectangle(0, 0, 980, $H)))
$scrim.Dispose()

# fine grain
$rnd = New-Object System.Random 20261012
for ($i = 0; $i -lt 7000; $i++) {
  $x = $rnd.Next(0, $W); $y = $rnd.Next(0, $H)
  $a = $rnd.Next(3, 13)
  $col = if ($rnd.Next(0, 2) -eq 0) { [System.Drawing.Color]::FromArgb($a, 255, 240, 220) } else { [System.Drawing.Color]::FromArgb($a, 0, 0, 0) }
  $d = New-Object System.Drawing.SolidBrush $col
  $g.FillEllipse($d, $x, $y, 2, 2)
  $d.Dispose()
}

# ================= typography =================
$fontBadge = New-Object System.Drawing.Font ($FontUI, 28, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fontCap = New-Object System.Drawing.Font ($FontMono, 22, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fontCapSmall = New-Object System.Drawing.Font ($FontMono, 19, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fontKick = New-Object System.Drawing.Font ($FontHand, 44, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fontSub = New-Object System.Drawing.Font ($FontUI, 29, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 248, 247, 245))
$gold = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 236, 186, 96))
$redB = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 234, 98, 86))
$mute = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(200, 150, 148, 145))
$dim = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(150, 120, 120, 122))

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

# captions above and below the wall
if ($CaptionTop.Length -gt 0) {
  $g.DrawString($CaptionTop, $fontCap, $dim, $gx, ($gy - 44), $sf)
}
if ($CaptionBottom.Length -gt 0) {
  $g.DrawString($CaptionBottom, $fontCap, $gold, $gx, ($gy + $gridH + 32), $sf)
}
$g.DrawString("60", $fontCapSmall, $dim, ($gx + $gridW - 30), ($gy - 42), $sf)

# badge
if ($badge.Length -gt 0) {
  $bSize = $g.MeasureString($badge, $fontBadge, (New-Object System.Drawing.SizeF(9999, 9999)), $sf)
  $pillW = [int]$bSize.Width + 52
  $pillY = 84
  $pb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(40, 236, 186, 96))
  $g.FillRectangle($pb, 96, $pillY, $pillW, 58)
  $pb.Dispose()
  $pp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(170, 236, 186, 96)), 2
  $g.DrawRectangle($pp, 96, $pillY, $pillW, 58)
  $pp.Dispose()
  $g.DrawString($badge, $fontBadge, $gold, (96 + 26), ($pillY + 14), $sf)
}

# title
$textX = 96
$maxW = 800
$sizes = @(94, 86, 78, 70, 62, 56)
$fontTitle = $null
$titleLines = @()
$titleSize = $sizes[$sizes.Count - 1]
foreach ($s in $sizes) {
  $f = New-Object System.Drawing.Font ($FontUI, $s, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $ls = Wrap-Text $title $f $maxW
  if ($ls.Count -le 3) { $fontTitle = $f; $titleLines = $ls; $titleSize = $s; break }
  $f.Dispose()
}
if ($fontTitle -eq $null) {
  $titleSize = 56
  $fontTitle = New-Object System.Drawing.Font ($FontUI, $titleSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $titleLines = Wrap-Text $title $fontTitle $maxW
}

$titleY = 212
$lineH = [int]([math]::Round($titleSize * 1.22))
for ($i = 0; $i -lt $titleLines.Count; $i++) {
  $g.DrawString($titleLines[$i], $fontTitle, $white, $textX, ($titleY + $i * $lineH), $sf)
}
$bottom = $titleY + $titleLines.Count * $lineH

$ruleY = $bottom + 16
$rp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 236, 186, 96), 5)
$g.DrawLine($rp, $textX, $ruleY, ($textX + 176), $ruleY)
$rp.Dispose()

$nextY = $ruleY + 38
if ($Kicker.Length -gt 0) {
  $g.DrawString($Kicker, $fontKick, $redB, $textX, $nextY, $sf)
  $nextY += 66
}
if ($Subtitle.Length -gt 0) {
  $subLines = Wrap-Text $Subtitle $fontSub $maxW
  for ($i = 0; $i -lt $subLines.Count; $i++) {
    $g.DrawString($subLines[$i], $fontSub, $mute, $textX, ($nextY + $i * 42), $sf)
  }
}

$white.Dispose(); $gold.Dispose(); $redB.Dispose(); $mute.Dispose(); $dim.Dispose()
$fontBadge.Dispose(); $fontCap.Dispose(); $fontCapSmall.Dispose()
$fontKick.Dispose(); $fontSub.Dispose(); $fontTitle.Dispose()
$g.Dispose()
$bmp.Save($OutPng, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $OutPng)