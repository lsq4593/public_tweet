# generate_cover_member.ps1
# 21:9 (1792x768) text-free background for "会员到期提醒".
# Motif: a dark room, a phone screen's glow, and a blurred receipt floating in it.
# Deliberately carries no text — the headline is added by the WeChat editor.
param(
  [string]$Out = "C:\Users\cbs\Desktop\公众号推文\01_精准深耕系列\_配图\会员到期_封面.png"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$W = 1792
$H = 768

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# ---------- base gradient: near-black at the bottom, deep navy at the top ----------
$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect,
  [System.Drawing.Color]::FromArgb(255, 10, 17, 33),
  [System.Drawing.Color]::FromArgb(255, 24, 37, 64), 90)
$g.FillRectangle($bg, $rect); $bg.Dispose()

# ---------- soft radial glow (true gradient, no concentric banding) ----------
function Add-Glow {
  param($g, [int]$cx, [int]$cy, [int]$rad, [int]$alpha, [int]$cr, [int]$cg, [int]$cb)
  if ($rad -le 0 -or $alpha -le 0) { return }
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddEllipse(($cx - $rad), ($cy - $rad), (2 * $rad), (2 * $rad))
  $pg = New-Object System.Drawing.Drawing2D.PathGradientBrush($path)
  $pg.CenterColor = [System.Drawing.Color]::FromArgb($alpha, $cr, $cg, $cb)
  $pg.SurroundColors = @([System.Drawing.Color]::FromArgb(0, $cr, $cg, $cb))
  $g.FillEllipse($pg, ($cx - $rad), ($cy - $rad), (2 * $rad), (2 * $rad))
  $pg.Dispose(); $path.Dispose()
}
Add-Glow $g 1210 300 620 46 150 190 255
Add-Glow $g 1210 300 260 60 255 226 170
Add-Glow $g 240 660 560 26 90 140 210

# ---------- a blurred receipt, drifting off to the left ----------
# drawn tiny, then scaled far past 1:1 so it reads as pure out-of-focus shape
$rw = 46; $rh = 116
$receipt = New-Object System.Drawing.Bitmap($rw, $rh)
$gr = [System.Drawing.Graphics]::FromImage($receipt)
$paper = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 206, 200, 190))
$gr.FillRectangle($paper, 0, 0, $rw, $rh)
# faux rows: no glyphs, just blocks — nothing readable on purpose
$y = 8
$rr2 = New-Object System.Random(77)
while ($y -lt $rh - 10) {
  $w = [int]($rr2.Next([int]($rw * 0.34), [int]($rw * 0.86)))
  $a = 50 + $rr2.Next(0, 60)
  $row = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($a, 70, 66, 60))
  $gr.FillRectangle($row, 5, $y, $w, 2)
  $row.Dispose()
  $y += 5 + $rr2.Next(0, 4)
}
$gr.Dispose()

$big = New-Object System.Drawing.Bitmap(196, 494)
$gb2 = [System.Drawing.Graphics]::FromImage($big)
$gb2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gb2.DrawImage($receipt, 0, 0, 196, 494)
$gb2.Dispose()
$receipt.Dispose()

# fade it right down and tint it cool so it stays a suggestion, not a document
$cm = New-Object System.Drawing.Imaging.ColorMatrix
$cm.Matrix00 = 0.95; $cm.Matrix11 = 0.96; $cm.Matrix22 = 1.00; $cm.Matrix33 = 0.17
$ia = New-Object System.Drawing.Imaging.ImageAttributes
$ia.SetColorMatrix($cm)

$state = $g.Save()
$g.TranslateTransform(232, 470)
$g.RotateTransform(-15)
$g.DrawImage($big, (New-Object System.Drawing.Rectangle(0, -247, 196, 494)), 0, 0, 196, 494,
  [System.Drawing.GraphicsUnit]::Pixel, $ia)
$g.Restore($state)
$ia.Dispose(); $big.Dispose()

# ---------- out-of-focus light points ----------
$palette = @(
  @(232, 186, 110), @(232, 186, 110), @(120, 200, 255),
  @(255, 226, 170), @(150, 180, 235), @(255, 240, 210)
)
$rng = New-Object System.Random(20261015)
for ($i = 0; $i -lt 54; $i++) {
  $cx = $rng.Next(-60, $W + 60)
  $cy = $rng.Next(-40, $H + 40)
  $depth = $rng.Next(0, 100) / 100.0
  $r = [int](10 + 86 * $depth * $depth)
  $p = $palette[$rng.Next(0, $palette.Count)]
  $alpha = [int](14 + 52 * $depth)
  Add-Glow $g $cx $cy $r $alpha $p[0] $p[1] $p[2]
}

# ---------- vignette ----------
$vg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, $W, 130)),
  [System.Drawing.Color]::FromArgb(190, 3, 6, 14),
  [System.Drawing.Color]::FromArgb(0, 3, 6, 14), 90)
$g.FillRectangle($vg, (New-Object System.Drawing.Rectangle(0, 0, $W, 130))); $vg.Dispose()
$vg2 = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, ($H - 170), $W, 170)),
  [System.Drawing.Color]::FromArgb(0, 3, 6, 14),
  [System.Drawing.Color]::FromArgb(180, 3, 6, 14), 90)
$g.FillRectangle($vg2, (New-Object System.Drawing.Rectangle(0, ($H - 170), $W, 170))); $vg2.Dispose()

# ---------- a single warm accent, to carry the gold note ----------
$ln = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(120, 232, 186, 110), 3)
$g.DrawLine($ln, 96, ($H - 96), 300, ($H - 96))
$ln.Dispose()

$g.Dispose()
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $Out)