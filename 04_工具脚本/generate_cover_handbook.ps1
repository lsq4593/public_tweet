# generate_cover_handbook.ps1
# 21:9 (1792x768) cover generator - reads title from the markdown H1, no hardcoded CJK.
param(
  [string]$SourceMd = "C:\Users\cbs\Desktop\公众号推文\02_AI主题\15_AI动手手册01_有了AI之后，我一天到底省了多长时间.md",
  [string]$OutPng  = "C:\Users\cbs\Desktop\公众号推文\02_AI主题\_配图\15_AI省了多长时间_封面.png",
  [string]$Subtitle = ""
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$W = 1792
$H = 768

# ---------- read H1 from markdown ----------
$all = [System.IO.File]::ReadAllText($SourceMd, [System.Text.Encoding]::UTF8)
$h1 = ($all -split "`n" | Where-Object { $_ -match '^#\s' } | Select-Object -First 1)
$h1 = $h1 -replace '^#\s+', ''
$h1 = $h1.Trim()

# split title / badge on the fullwidth pipe U+FF5C
$parts = $h1 -split [char]0xFF5C
$title = $parts[0].Trim()
$badge = ""
if ($parts.Count -gt 1) { $badge = $parts[1].Trim() }

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# ---------- background gradient ----------
$top = [System.Drawing.Color]::FromArgb(255, 7, 20, 40)
$bot = [System.Drawing.Color]::FromArgb(255, 18, 56, 110)
$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $top, $bot, 90)
$g.FillRectangle($brush, $rect)

# ---------- subtle grid ----------
$gridPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(18, 120, 190, 255), 1)
for ($x = 0; $x -le $W; $x += 64) { $g.DrawLine($gridPen, $x, 0, $x, $H) }
for ($y = 0; $y -le $H; $y += 64) { $g.DrawLine($gridPen, 0, $y, $W, $y) }
$gridPen.Dispose()

# ---------- left vignette so text stays readable ----------
$vigBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, 1150, $H)),
  [System.Drawing.Color]::FromArgb(235, 4, 12, 30),
  [System.Drawing.Color]::FromArgb(0, 4, 12, 30),
  0)
$g.FillRectangle($vigBrush, (New-Object System.Drawing.Rectangle(0, 0, 1150, $H)))
$vigBrush.Dispose()

# ---------- accent glow behind the clock ----------
$cx = 1370; $cy = 384
for ($r = 420; $r -gt 0; $r -= 6) {
  $a = [int](16 * [math]::Pow(1 - $r / 420, 2.2))
  if ($a -le 0) { continue }
  $p = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($a, 0, 200, 255), 6)
  $g.DrawEllipse($p, ($cx - $r), ($cy - $r), (2 * $r), (2 * $r))
  $p.Dispose()
}

# ---------- clock face (right side) ----------
$R = 196
$ringPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(110, 140, 210, 255), 3)
$g.DrawEllipse($ringPen, ($cx - $R), ($cy - $R), (2 * $R), (2 * $R))
$ringPen.Dispose()

# tick marks
for ($i = 0; $i -lt 60; $i++) {
  $a = $i * 6 * [math]::PI / 180 - [math]::PI / 2
  $isHour = ($i % 5 -eq 0)
  $r1 = if ($isHour) { $R - 22 } else { $R - 12 }
  $p = New-Object System.Drawing.Pen (
    [System.Drawing.Color]::FromArgb($(if ($isHour) { 255 } else { 140 }), 165, 215, 255),
    $(if ($isHour) { 4 } else { 1 }))
  $g.DrawLine($p,
    ($cx + $r1 * [math]::Cos($a)), ($cy + $r1 * [math]::Sin($a)),
    ($cx + ($R - 4) * [math]::Cos($a)), ($cy + ($R - 4) * [math]::Sin($a)))
  $p.Dispose()
}

# elapsed arc in gold, roughly two thirds of the circle
$arcRect = New-Object System.Drawing.Rectangle(($cx - $R + 6), ($cy - $R + 6), (2 * $R - 12), (2 * $R - 12))
$arcPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 226, 166, 74), 9)
$arcPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$arcPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawArc($arcPen, $arcRect, -90, 235)
$arcPen.Dispose()

# hands
$handPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(235, 235, 242, 252), 6)
$handPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$handPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawLine($handPen, $cx, $cy, ($cx + 78 * [math]::Cos(-1.1)), ($cy + 78 * [math]::Sin(-1.1)))
$g.DrawLine($handPen, $cx, $cy, ($cx + 122 * [math]::Cos(1.95)), ($cy + 122 * [math]::Sin(1.95)))
$handPen.Dispose()

$hubBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 235, 242, 252))
$g.FillEllipse($hubBrush, ($cx - 9), ($cy - 9), 18, 18)
$hubBrush.Dispose()

# ---------- small floating tiles (echo the existing cover style) ----------
function New-Tile([int]$x, [int]$y, [int]$w, [int]$h, [int]$alpha) {
  $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($alpha, 0, 200, 255), 2)
  $g.DrawRectangle($pen, $x, $y, $w, $h)
  $pen.Dispose()
  $lp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb([int]($alpha * 0.6), 150, 205, 255), 2)
  for ($i = 0; $i -lt 3; $i++) {
    $ly = $y + 12 + $i * 13
    $g.DrawLine($lp, ($x + 9), $ly, ($x + $w - 9), $ly)
  }
  $lp.Dispose()
}
New-Tile 1160 132 108 74 170
New-Tile 1560 176 92 66 135
New-Tile 1130 606 124 82 150
New-Tile 1590 566 88 62 125

# connector lines from tiles to the clock
$conn = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(80, 0, 200, 255), 2)
$g.DrawLine($conn, 1214, 206, ($cx - 150), ($cy - 120))
$g.DrawLine($conn, 1620, 242, ($cx + 168), ($cy - 96))
$g.DrawLine($conn, 1192, 606, ($cx - 156), ($cy + 116))
$conn.Dispose()

# ---------- typography ----------
$fontBold = New-Object System.Drawing.Font ("Microsoft YaHei UI", 78, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fontBadge = New-Object System.Drawing.Font ("Microsoft YaHei UI", 30, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fontSub = New-Object System.Drawing.Font ("Microsoft YaHei UI", 33, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 244, 248, 255))
$gold = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 232, 178, 92))
$cyan = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 126, 205, 255))
$mute = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(210, 168, 196, 226))

$textX = 110

# optional Chinese subtitle, passed in as a parameter to keep this file CJK-safe
$subtitle = ""
if ($args.Count -ge 1 -and $args[0].Length -gt 0) { $subtitle = $args[0] }

# badge pill
if ($badge.Length -gt 0) {
  $bSize = $g.MeasureString($badge, $fontBadge)
  $pillW = [int]$bSize.Width + 56
  $pillH = 62
  $pillY = 96
  $pillBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(46, 0, 200, 255))
  $g.FillRectangle($pillBrush, $textX, $pillY, $pillW, $pillH)
  $pillBrush.Dispose()
  $pillPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(190, 0, 200, 255), 2)
  $g.DrawRectangle($pillPen, $textX, $pillY, $pillW, $pillH)
  $pillPen.Dispose()
  $g.DrawString($badge, $fontBadge, $cyan, ($textX + 28), ($pillY + 14))
}

# title wrapped onto at most two lines
$maxW = 900
$titleY = 250
$words = $title
$lines = New-Object System.Collections.ArrayList
$current = ""
foreach ($ch in $words.ToCharArray()) {
  $test = $current + $ch
  $sz = $g.MeasureString($test, $fontBold)
  if ($sz.Width -gt $maxW -and $current.Length -gt 0) {
    [void]$lines.Add($current)
    $current = $ch
  } else {
    $current = $test
  }
}
if ($current.Length -gt 0) { [void]$lines.Add($current) }
if ($lines.Count -gt 2) { $lines[0] = $lines[0] + $lines[1]; $lines.RemoveAt(1) }

$lineH = 112
for ($i = 0; $i -lt $lines.Count; $i++) {
  $g.DrawString($lines[$i], $fontBold, $white, $textX, ($titleY + $i * $lineH))
}

# gold rule, with clearance so it never touches the descenders
$ruleY = $titleY + $lines.Count * $lineH - 6
$rulePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 232, 178, 92), 4)
$g.DrawLine($rulePen, $textX, $ruleY, ($textX + 180), $ruleY)
$rulePen.Dispose()

# subtitle
if ($subtitle.Length -gt 0) {
  $subY = $ruleY + 40
  $g.DrawString($subtitle, $fontSub, $mute, $textX, $subY)
}

# cleanup
$white.Dispose(); $gold.Dispose(); $cyan.Dispose(); $mute.Dispose()
$fontBold.Dispose(); $fontBadge.Dispose(); $fontSub.Dispose()
$brush.Dispose()
$g.Dispose()

$bmp.Save($OutPng, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $OutPng)