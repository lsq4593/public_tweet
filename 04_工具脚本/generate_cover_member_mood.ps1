# generate_cover_member_mood.ps1
# 21:9 (1792x768) text-free background for "会员到期提醒".
# Deliberately indirect: no receipt, no numbers, no UI. A blurred, half-cropped
# ring that reads as "倒数" or a clock rim, suspended in haze. The headline is
# overlaid by the WeChat editor.
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

function Add-Glow {
  param($g, [double]$cx, [double]$cy, [double]$rad, [int]$alpha, [int]$cr, [int]$cg, [int]$cb)
  if ($rad -le 0 -or $alpha -le 0) { return }
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddEllipse([single]($cx - $rad), [single]($cy - $rad), [single](2 * $rad), [single](2 * $rad))
  $pg = New-Object System.Drawing.Drawing2D.PathGradientBrush($path)
  $pg.CenterColor = [System.Drawing.Color]::FromArgb($alpha, $cr, $cg, $cb)
  $pg.SurroundColors = @([System.Drawing.Color]::FromArgb(0, $cr, $cg, $cb))
  $g.FillEllipse($pg, [single]($cx - $rad), [single]($cy - $rad), [single](2 * $rad), [single](2 * $rad))
  $pg.Dispose(); $path.Dispose()
}

# ---------- ground: almost black, opening up slightly toward the middle ----------
$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect,
  [System.Drawing.Color]::FromArgb(255, 6, 10, 20),
  [System.Drawing.Color]::FromArgb(255, 20, 31, 53), 78)
$g.FillRectangle($bg, $rect); $bg.Dispose()

# ---------- the light inside the ring ----------
Add-Glow $g 1150 356 430 34 120 165 235
Add-Glow $g 1150 356 190 44 255 226 175
Add-Glow $g 1150 356 92  30 255 240 214

# ---------- the ring: a rim cropped by the top-right of the frame ----------
# drawn small and scaled up so it lands far out of focus
$rw = 150; $rh = 150
$ring = New-Object System.Drawing.Bitmap($rw, $rh)
$gr = [System.Drawing.Graphics]::FromImage($ring)
$gr.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(190, 255, 232, 190), 3)
$pen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
$pen.DashPattern = [single[]]@(9.0, 11.0)
$gr.DrawEllipse($pen, 6, 6, ($rw - 12), ($rh - 12))
$gr.Dispose(); $pen.Dispose()

$ringBig = New-Object System.Drawing.Bitmap(1120, 1120)
$grb = [System.Drawing.Graphics]::FromImage($ringBig)
$grb.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$grb.DrawImage($ring, 0, 0, 1120, 1120)
$grb.Dispose(); $ring.Dispose()

$cm = New-Object System.Drawing.Imaging.ColorMatrix
$cm.Matrix00 = 1.0; $cm.Matrix11 = 1.0; $cm.Matrix22 = 1.0; $cm.Matrix33 = 0.34
$ia = New-Object System.Drawing.Imaging.ImageAttributes
$ia.SetColorMatrix($cm)
$g.DrawImage($ringBig, (New-Object System.Drawing.Rectangle(618, -156, 1120, 1120)), 0, 0, 1120, 1120,
  [System.Drawing.GraphicsUnit]::Pixel, $ia)
$ia.Dispose(); $ringBig.Dispose()

# a second, fainter ring, further out — depth without clutter
$ring2 = New-Object System.Drawing.Bitmap(120, 120)
$gr2 = [System.Drawing.Graphics]::FromImage($ring2)
$gr2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$pen2 = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(150, 150, 200, 255), 2)
$gr2.DrawEllipse($pen2, 4, 4, 112, 112)
$gr2.Dispose(); $pen2.Dispose()
$ring2Big = New-Object System.Drawing.Bitmap(900, 900)
$grb2 = [System.Drawing.Graphics]::FromImage($ring2Big)
$grb2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$grb2.DrawImage($ring2, 0, 0, 900, 900)
$grb2.Dispose(); $ring2.Dispose()
$cm2 = New-Object System.Drawing.Imaging.ColorMatrix
$cm2.Matrix00 = 0.85; $cm2.Matrix11 = 0.92; $cm2.Matrix22 = 1.0; $cm2.Matrix33 = 0.16
$ia2 = New-Object System.Drawing.Imaging.ImageAttributes
$ia2.SetColorMatrix($cm2)
$g.DrawImage($ring2Big, (New-Object System.Drawing.Rectangle(700, -110, 900, 900)), 0, 0, 900, 900,
  [System.Drawing.GraphicsUnit]::Pixel, $ia2)
$ia2.Dispose(); $ring2Big.Dispose()

# ---------- a sliver of warm light at the left, like a door left ajar ----------
$slit = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(120, 255, 224, 168))
$g.FillRectangle($slit, 236, 150, 3, 430)
$slit.Dispose()
$ig = New-Object System.Drawing.Imaging.ImageAttributes
$ig.SetColorMatrix((New-Object System.Drawing.Imaging.ColorMatrix))
$ig2 = New-Object System.Drawing.Imaging.ColorMatrix
$ig2.Matrix00 = 1.0; $ig2.Matrix11 = 1.0; $ig2.Matrix22 = 1.0; $ig2.Matrix33 = 0.30
$ig.Dispose()
$ia3 = New-Object System.Drawing.Imaging.ImageAttributes
$ia3.SetColorMatrix($ig2)
$soft = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(46, 255, 224, 168))
$g.FillRectangle($soft, 224, 150, 28, 430)
$soft.Dispose()
$ia3.Dispose()

# ---------- dust suspended in the beam ----------
$rng = New-Object System.Random(1106)
for ($i = 0; $i -lt 74; $i++) {
  $cx = $rng.Next(-40, $W + 40)
  $cy = $rng.Next(-30, $H + 30)
  $depth = $rng.Next(0, 100) / 100.0
  $rad = 1.6 + 9.0 * $depth * $depth
  $a = [int](7 + 26 * $depth)
  $pick = $rng.Next(0, 10)
  if ($pick -lt 4)      { Add-Glow $g $cx $cy $rad $a 255 232 186 }
  elseif ($pick -lt 7)  { Add-Glow $g $cx $cy $rad $a 190 220 255 }
  else                  { Add-Glow $g $cx $cy $rad $a 245 248 255 }
}

# ---------- haze: two very wide, very low-contrast washes ----------
$haze = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, $W, $H)),
  [System.Drawing.Color]::FromArgb(16, 120, 160, 220),
  [System.Drawing.Color]::FromArgb(0, 120, 160, 220), 0)
$g.FillRectangle($haze, (New-Object System.Drawing.Rectangle(0, 0, $W, $H))); $haze.Dispose()
$haze2 = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, ($H - 300), $W, 300)),
  [System.Drawing.Color]::FromArgb(0, 200, 170, 120),
  [System.Drawing.Color]::FromArgb(22, 200, 170, 120), 90)
$g.FillRectangle($haze2, (New-Object System.Drawing.Rectangle(0, ($H - 300), $W, 300))); $haze2.Dispose()

# ---------- one hairline of gold, low and fading ----------
for ($x = 120; $x -lt 620; $x += 2) {
  $t = ($x - 120) / 500.0
  $a = [int](120 * (1 - $t) * (1 - $t))
  if ($a -le 2) { continue }
  $br = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($a, 232, 186, 110))
  $g.FillRectangle($br, $x, 664, 2, 2)
  $br.Dispose()
}

# ---------- vignette ----------
$vg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, $W, 190)),
  [System.Drawing.Color]::FromArgb(210, 4, 7, 14),
  [System.Drawing.Color]::FromArgb(0, 4, 7, 14), 90)
$g.FillRectangle($vg, (New-Object System.Drawing.Rectangle(0, 0, $W, 190))); $vg.Dispose()
$vg2 = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, ($H - 240), $W, 240)),
  [System.Drawing.Color]::FromArgb(0, 4, 7, 14),
  [System.Drawing.Color]::FromArgb(200, 4, 7, 14), 90)
$g.FillRectangle($vg2, (New-Object System.Drawing.Rectangle(0, ($H - 240), $W, 240))); $vg2.Dispose()

$g.Dispose()
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $Out)