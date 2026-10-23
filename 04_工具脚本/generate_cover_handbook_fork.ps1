# generate_cover_handbook_fork.ps1
# 21:9 (1792x768) cover: title on the left, a fork-in-the-road on the right.
# Source file is ASCII-only: every CJK string is passed in as a parameter.
param(
  [string]$SourceMd = "",
  [string]$OutPng  = "",
  [string]$Subtitle = "",
  [string]$LeftLabel = "",
  [string]$RightLabel = "",
  [string]$FootLabel = "",
  [string]$TitleOverride = "",
  [string]$BadgeOverride = "",
  [string]$FontUI = "Microsoft YaHei UI"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$W = 1792
$H = 768

if ($OutPng.Length -eq 0) { throw "OutPng is required" }

$title = $TitleOverride
$badge = $BadgeOverride

if ($SourceMd.Length -gt 0 -and $title.Length -eq 0) {
  $all = [System.IO.File]::ReadAllText($SourceMd, [System.Text.Encoding]::UTF8)
  $h1 = ($all -split "`n" | Where-Object { $_ -match '^#\s' } | Select-Object -First 1)
  if ($h1 -ne $null) {
    $h1 = ($h1 -replace '^#\s+', '').Trim()
    $parts = $h1 -split [char]0xFF5C
    $title = $parts[0].Trim()
    if ($badge.Length -eq 0 -and $parts.Count -gt 1) { $badge = $parts[1].Trim() }
  }
}

if ($title.Length -eq 0) { throw "no title" }

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

$noStartCodes = @(0x3002, 0xFF0C, 0x3001, 0xFF1F, 0xFF01, 0xFF1A, 0xFF1B, 0x300D, 0x300F, 0x3011, 0x300B, 0x3009, 0xFF09, 0x002C, 0x002E)
$NO_START = ""
foreach ($cp in $noStartCodes) { $NO_START += [char]$cp }

function Wrap-Text([string]$t, $f, [int]$limitW) {
  $lines = New-Object System.Collections.ArrayList
  if ($t.IndexOf("|") -ge 0) {
    foreach ($piece in ($t -split "\|")) {
      if ($piece.Length -gt 0) { [void]$lines.Add($piece) }
    }
    return ,@($lines)
  }
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

function New-RoundRectPath([int]$x, [int]$y, [int]$w, [int]$h, [int]$r) {
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  if ($d -gt $w) { $d = $w }
  if ($d -gt $h) { $d = $h }
  $p.AddArc($x, $y, $d, $d, 180, 90)
  $p.AddArc(($x + $w - $d), $y, $d, $d, 270, 90)
  $p.AddArc(($x + $w - $d), ($y + $h - $d), $d, $d, 0, 90)
  $p.AddArc($x, ($y + $h - $d), $d, $d, 90, 90)
  $p.CloseFigure()
  return $p
}

# ================= background =================
$cTop = [System.Drawing.Color]::FromArgb(255, 7, 20, 40)
$cBot = [System.Drawing.Color]::FromArgb(255, 18, 56, 110)
$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $cTop, $cBot, 90)
$g.FillRectangle($brush, $rect)
$brush.Dispose()

$gridPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(18, 120, 190, 255), 1)
for ($x = 0; $x -le $W; $x += 64) { $g.DrawLine($gridPen, $x, 0, $x, $H) }
for ($y = 0; $y -le $H; $y += 64) { $g.DrawLine($gridPen, 0, $y, $W, $y) }
$gridPen.Dispose()

$vigRect = New-Object System.Drawing.Rectangle(0, 0, 1180, $H)
$vigBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  $vigRect,
  [System.Drawing.Color]::FromArgb(235, 4, 12, 30),
  [System.Drawing.Color]::FromArgb(0, 4, 12, 30),
  0)
$g.FillRectangle($vigBrush, $vigRect)
$vigBrush.Dispose()

# ================= right panel =================
$panelX = 1044; $panelY = 56; $panelW = 704; $panelH = 656
$panelPath = New-RoundRectPath $panelX $panelY $panelW $panelH 10
$panelFill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(42, 3, 18, 42))
$g.FillPath($panelFill, $panelPath)
$panelFill.Dispose()
$panelPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(95, 0, 200, 255), 2)
$g.DrawPath($panelPen, $panelPath)
$panelPen.Dispose()
$panelPath.Dispose()

# cyan glow behind the left fork, gold glow behind the right fork
$gcxL = $panelX + 210
$gcxR = $panelX + $panelW - 210
$gcy = $panelY + 210
for ($r = 220; $r -gt 0; $r -= 8) {
  $a = [int](16 * [math]::Pow(1 - $r / 220, 2.2))
  if ($a -le 0) { continue }
  $gp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($a, 0, 200, 255), 8)
  $g.DrawEllipse($gp, ($gcxL - $r), ($gcy - $r), (2 * $r), (2 * $r))
  $gp.Dispose()
}
for ($r = 200; $r -gt 0; $r -= 8) {
  $a = [int](18 * [math]::Pow(1 - $r / 200, 2.2))
  if ($a -le 0) { continue }
  $gp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($a, 232, 178, 92), 8)
  $g.DrawEllipse($gp, ($gcxR - $r), ($gcy - $r), (2 * $r), (2 * $r))
  $gp.Dispose()
}

# ================= the fork =================
$jx = [single]($panelX + $panelW / 2)
$jy = [single]($panelY + 430)
$startX = $jx
$startY = [single]($panelY + $panelH - 78)
$leftX = [single]($panelX + 168)
$leftY = [single]($panelY + 168)
$rightX = [single]($panelX + $panelW - 168)
$rightY = [single]($panelY + 168)

function Draw-Road([single]$x1, [single]$y1, [single]$x2, [single]$y2, $color, [int]$width) {
  $pen = New-Object System.Drawing.Pen $color, $width
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
  $g.DrawLine($pen, $x1, $y1, $x2, $y2)
  $pen.Dispose()
}

# trunk
Draw-Road $startX $startY $jx $jy ([System.Drawing.Color]::FromArgb(70, 150, 190, 230)) 28
Draw-Road $startX $startY $jx $jy ([System.Drawing.Color]::FromArgb(160, 210, 230, 255)) 6

# left fork: cyan, the easy ready-made answers
Draw-Road $jx $jy $leftX $leftY ([System.Drawing.Color]::FromArgb(90, 0, 190, 255)) 26
Draw-Road $jx $jy $leftX $leftY ([System.Drawing.Color]::FromArgb(220, 90, 210, 255)) 6

# right fork: gold, your own call
Draw-Road $jx $jy $rightX $rightY ([System.Drawing.Color]::FromArgb(90, 232, 178, 92)) 26
Draw-Road $jx $jy $rightX $rightY ([System.Drawing.Color]::FromArgb(230, 255, 214, 150)) 6

# dashed center line on the trunk
$dash = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(160, 255, 255, 255), 2)
$dash.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
$dash.DashPattern = @(3, 4)
$g.DrawLine($dash, $startX, ($startY - 8), $jx, ($jy + 10))
$dash.Dispose()

# left destination: stacked answer cards (AI output)
function Draw-Card([int]$cx, [int]$cy, [int]$w, [int]$h, [int]$alphaFill, [int]$alphaEdge) {
  $rp = New-RoundRectPath ($cx - [int]($w / 2)) ($cy - [int]($h / 2)) $w $h 8
  $fb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($alphaFill, 12, 40, 72))
  $g.FillPath($fb, $rp)
  $fb.Dispose()
  $ep = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($alphaEdge, 90, 210, 255), 2)
  $g.DrawPath($ep, $rp)
  $ep.Dispose()
  $line = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb([int]($alphaEdge * 0.7), 140, 220, 255), 2)
  $top = $cy - [int]($h / 2) + 12
  for ($i = 0; $i -lt 3; $i++) {
    $lw = [int]($w - 28 - $i * 10)
    $g.DrawLine($line, ($cx - [int]($w / 2) + 14), ($top + $i * 11), ($cx - [int]($w / 2) + 14 + $lw), ($top + $i * 11))
  }
  $line.Dispose()
  $rp.Dispose()
}
Draw-Card ([int]$leftX - 18) ([int]$leftY - 8) 92 58 180 200
Draw-Card ([int]$leftX + 10) ([int]$leftY - 28) 88 54 140 160

# right destination: a single gold ring (one decision, yours)
$ringPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(230, 232, 178, 92), 5)
$g.DrawEllipse($ringPen, ([int]$rightX - 28), ([int]$rightY - 36), 56, 56)
$ringPen.Dispose()
$ringFill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(50, 232, 178, 92))
$g.FillEllipse($ringFill, ([int]$rightX - 18), ([int]$rightY - 26), 36, 36)
$ringFill.Dispose()
$dot = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 224, 170))
$g.FillEllipse($dot, ([int]$rightX - 6), ([int]$rightY - 14), 12, 12)
$dot.Dispose()

# person at the junction, facing slightly toward the gold path
$px = [int]$jx
$py = [int]$jy
$ink = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 236, 242, 252))
$rimP = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(220, 232, 178, 92), 2)
# ground shadow
$sh = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(90, 0, 0, 0))
$g.FillEllipse($sh, ($px - 22), ($py + 18), 48, 12)
$sh.Dispose()
# legs
$g.FillPolygon($ink, @(
  (New-Object System.Drawing.Point ($px - 8), ($py + 2)),
  (New-Object System.Drawing.Point ($px - 1), ($py + 2)),
  (New-Object System.Drawing.Point ($px - 4), ($py + 22)),
  (New-Object System.Drawing.Point ($px - 12), ($py + 22))))
$g.FillPolygon($ink, @(
  (New-Object System.Drawing.Point ($px + 1), ($py + 2)),
  (New-Object System.Drawing.Point ($px + 8), ($py + 2)),
  (New-Object System.Drawing.Point ($px + 14), ($py + 22)),
  (New-Object System.Drawing.Point ($px + 6), ($py + 22))))
# torso
$g.FillPolygon($ink, @(
  (New-Object System.Drawing.Point ($px - 11), ($py - 22)),
  (New-Object System.Drawing.Point ($px + 11), ($py - 22)),
  (New-Object System.Drawing.Point ($px + 9), ($py + 4)),
  (New-Object System.Drawing.Point ($px - 9), ($py + 4))))
# head
$g.FillEllipse($ink, ($px - 9), ($py - 42), 18, 18)
$g.DrawEllipse($rimP, ($px - 9), ($py - 42), 18, 18)
$ink.Dispose()
$rimP.Dispose()

# ================= fonts / colors =================
$fontBadge = New-Object System.Drawing.Font ($FontUI, 30, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fontSub = New-Object System.Drawing.Font ($FontUI, 30, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fontLab = New-Object System.Drawing.Font ($FontUI, 26, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fontFoot = New-Object System.Drawing.Font ($FontUI, 24, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 244, 248, 255))
$gold = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 232, 178, 92))
$cyan = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 126, 205, 255))
$mute = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(215, 168, 196, 226))

$textX = 110
$maxW = 880

# labels on the two paths
if ($LeftLabel.Length -gt 0) {
  $g.DrawString($LeftLabel, $fontLab, $cyan, $leftX, ($leftY + 44), $sfC)
}
if ($RightLabel.Length -gt 0) {
  $g.DrawString($RightLabel, $fontLab, $gold, $rightX, ($rightY + 44), $sfC)
}
if ($FootLabel.Length -gt 0) {
  $fw = Measure-W $FootLabel $fontFoot
  $g.DrawString($FootLabel, $fontFoot, $mute, ($jx - $fw / 2), ($panelY + $panelH - 52), $sf)
}

# badge
if ($badge.Length -gt 0) {
  $bSize = $g.MeasureString($badge, $fontBadge, (New-Object System.Drawing.SizeF(9999, 9999)), $sf)
  $pillW = [int]$bSize.Width + 56
  $pillY = 92
  $pillBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(46, 0, 200, 255))
  $g.FillRectangle($pillBrush, $textX, $pillY, $pillW, 62)
  $pillBrush.Dispose()
  $pillPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(190, 0, 200, 255), 2)
  $g.DrawRectangle($pillPen, $textX, $pillY, $pillW, 62)
  $pillPen.Dispose()
  $g.DrawString($badge, $fontBadge, $cyan, ($textX + 28), ($pillY + 15), $sf)
}

# title: prefer a forced break on the first Chinese comma, then shrink to fit
$forced = $title
$comma = [char]0xFF0C
if ($title.IndexOf("|") -lt 0 -and $title.IndexOf($comma) -ge 0) {
  $idx = $title.IndexOf($comma)
  $forced = $title.Substring(0, $idx + 1) + "|" + $title.Substring($idx + 1)
}

$sizes = @(72, 66, 60, 54, 48)
$fontTitle = $null
$titleLines = @()
foreach ($s in $sizes) {
  $f = New-Object System.Drawing.Font ($FontUI, $s, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $ls = Wrap-Text $forced $f $maxW
  $tooWide = $false
  foreach ($ln in $ls) {
    if ((Measure-W $ln $f) -gt $maxW) { $tooWide = $true; break }
  }
  if (-not $tooWide -and $ls.Count -le 3) { $fontTitle = $f; $titleLines = $ls; break }
  $f.Dispose()
}
if ($fontTitle -eq $null) {
  $fontTitle = New-Object System.Drawing.Font ($FontUI, 48, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $titleLines = Wrap-Text $forced $fontTitle $maxW
}

$titleY = 226
$lineH = 104
if ($titleLines.Count -ge 3) { $lineH = 92 }
for ($i = 0; $i -lt $titleLines.Count; $i++) {
  $g.DrawString($titleLines[$i], $fontTitle, $white, $textX, ($titleY + $i * $lineH), $sf)
}
$bottom = $titleY + $titleLines.Count * $lineH

$ruleY = $bottom - 4
$rulePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 232, 178, 92), 4)
$g.DrawLine($rulePen, $textX, $ruleY, ($textX + 180), $ruleY)
$rulePen.Dispose()

if ($Subtitle.Length -gt 0) {
  $subLines = Wrap-Text $Subtitle $fontSub $maxW
  $subY = $ruleY + 36
  for ($i = 0; $i -lt $subLines.Count; $i++) {
    $g.DrawString($subLines[$i], $fontSub, $mute, $textX, ($subY + $i * 44), $sf)
  }
}

$white.Dispose(); $gold.Dispose(); $cyan.Dispose(); $mute.Dispose()
$fontBadge.Dispose(); $fontSub.Dispose(); $fontLab.Dispose(); $fontFoot.Dispose(); $fontTitle.Dispose()
$g.Dispose()
$bmp.Save($OutPng, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $OutPng)
