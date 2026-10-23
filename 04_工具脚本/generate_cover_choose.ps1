# generate_cover_choose.ps1
# 21:9 (1792x768) cover for "如果只能保住一样".
#
# Motif: three things — money, heart, laptop — standing side by side, each
# casting a shadow of a very different length. The long one catches the gold.
# The point of the piece is that the thing that weighs most is the one you
# answer slowest, so the shadow, not the object, carries the meaning.
#
# No text: the headline goes on in the WeChat editor.
param(
  [string]$Out = "C:\Users\cbs\Desktop\公众号推文\01_精准深耕系列\_配图\11_封面_三样东西.png"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$W = 1792
$H = 768
$FLOOR = 566

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

$cInk    = [System.Drawing.Color]::FromArgb(255, 8, 13, 24)
$cInkLit = [System.Drawing.Color]::FromArgb(255, 16, 25, 43)
$cGold   = [System.Drawing.Color]::FromArgb(255, 232, 186, 110)
$cLine   = [System.Drawing.Color]::FromArgb(150, 96, 128, 168)

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

function PF { param([double]$x, [double]$y)
  return (New-Object System.Drawing.PointF ([single]$x), ([single]$y))
}

# a list of PointF -> PointF[] (AddPolygon insists on the exact array type)
function Pts {
  param($items)
  $a = New-Object System.Drawing.PointF[] ([int]$items.Count)
  for ($i = 0; $i -lt $a.Length; $i++) { $a[$i] = [System.Drawing.PointF]$items[$i] }
  return ,$a
}

# ---------- background ----------
$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect,
  [System.Drawing.Color]::FromArgb(255, 7, 12, 22),
  [System.Drawing.Color]::FromArgb(255, 23, 34, 56), 82)
$g.FillRectangle($bg, $rect); $bg.Dispose()

# ---------- floor ----------
$fl = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 12, 19, 32))
$g.FillRectangle($fl, 0, $FLOOR, $W, ($H - $FLOOR)); $fl.Dispose()
$ln = New-Object System.Drawing.Pen ($cLine, 2)
$g.DrawLine($ln, 0, $FLOOR, $W, $FLOOR); $ln.Dispose()

# =========================================================
#  the three objects, each drawn into its own small bitmap
# =========================================================
$S = 200   # working size of each object bitmap

function New-Money {
  $b = New-Object System.Drawing.Bitmap($S, $S)
  $gg = [System.Drawing.Graphics]::FromImage($b)
  $gg.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $rnd = New-Object System.Random(5)
  for ($i = 5; $i -ge 0; $i--) {
    $w = 148 - $i * 5
    $y = 150 - $i * 19
    $br = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, (16 + $i * 4), (24 + $i * 4), (42 + $i * 6)))
    $gg.FillRectangle($br, [single](100 - $w / 2), [single]$y, [single]$w, 15)
    $br.Dispose()
    $p = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(120, 130, 158, 196), 1)
    $gg.DrawRectangle($p, [single](100 - $w / 2), [single]$y, [single]$w, 15)
    $p.Dispose()
  }
  $gg.Dispose()
  return $b
}

function New-Heart {
  $b = New-Object System.Drawing.Bitmap($S, $S)
  $gg = [System.Drawing.Graphics]::FromImage($b)
  $gg.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $m = New-Object System.Drawing.Drawing2D.GraphicsPath
  $m.StartFigure()
  $m.AddBezier((PF 100 60), (PF 126 26), (PF 172 56), (PF 164 90))
  $m.AddBezier((PF 164 90), (PF 156 124), (PF 100 168), (PF 100 168))
  $m.AddBezier((PF 100 168), (PF 44 124), (PF 36 90), (PF 36 90))
  $m.AddBezier((PF 36 90), (PF 28 56), (PF 74 26), (PF 100 60))
  $m.CloseFigure()
  $br = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 14, 22, 40))
  $gg.FillPath($br, $m); $br.Dispose()
  $p = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(170, 150, 178, 216), 2)
  $gg.DrawPath($p, $m); $p2 = $p
  $p.Dispose(); $m.Dispose()
  $gg.Dispose()
  return $b
}

function New-Laptop {
  $b = New-Object System.Drawing.Bitmap($S, $S)
  $gg = [System.Drawing.Graphics]::FromImage($b)
  $gg.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  # lid
  $lid = New-Object System.Drawing.Drawing2D.GraphicsPath
  $lid.AddPolygon((Pts @(
    (PF 46 26), (PF 154 26), (PF 160 128), (PF 40 128))))
  $br = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 15, 23, 41))
  $gg.FillPath($br, $lid); $br.Dispose()
  $p = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(180, 150, 178, 216), 2)
  $gg.DrawPath($p, $lid); $p.Dispose(); $lid.Dispose()
  # a faint glow inside the lid — the screen is on, work never stopped
  $screen = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(46, 130, 175, 235))
  $screenPath = New-Object System.Drawing.Drawing2D.GraphicsPath
  $screenPath.AddPolygon((Pts @(
    (PF 54 34), (PF 146 34), (PF 151 120), (PF 49 120))))
  $gg.FillPath($screen, $screenPath); $screen.Dispose(); $screenPath.Dispose()
  # base
  $base = New-Object System.Drawing.Drawing2D.GraphicsPath
  $base.AddPolygon((Pts @(
    (PF 22 148), (PF 178 148), (PF 170 132), (PF 30 132))))
  $br2 = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 20, 30, 52))
  $gg.FillPath($br2, $base); $br2.Dispose()
  $p2 = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(180, 150, 178, 216), 2)
  $gg.DrawPath($p2, $base); $p2.Dispose(); $base.Dispose()
  $gg.Dispose()
  return $b
}

# ---------- the cast: x position, shadow stretch, is the heavy one ----------
$cast = @(
  @{ obj = (New-Money);  x = 470.0;  stretch = 2.1; heavy = $false },
  @{ obj = (New-Heart);  x = 900.0;  stretch = 3.4; heavy = $false },
  @{ obj = (New-Laptop); x = 1310.0; stretch = 7.6; heavy = $true  }
)

$OBJ_W = 214
$OBJ_H = 214
$OBJ_TOP = $FLOOR - $OBJ_H + 26

# ---------- shadows first, so the objects sit on top ----------
foreach ($c in $cast) {
  if ($c.heavy) {
    Add-Glow $g ($c.x + 300) ($FLOOR + 40) 420 26 232 186 110
    Add-Glow $g ($c.x + 470) ($FLOOR + 26) 300 16 232 186 110
  }
  $sm = New-Object System.Drawing.Imaging.ImageAttributes
  $cm = New-Object System.Drawing.Imaging.ColorMatrix
  if ($c.heavy) {
    $cm.Matrix00 = 0.55; $cm.Matrix11 = 0.50; $cm.Matrix22 = 0.42; $cm.Matrix33 = 0.46
  } else {
    $cm.Matrix00 = 0.42; $cm.Matrix11 = 0.44; $cm.Matrix22 = 0.52; $cm.Matrix33 = 0.24
  }
  $sm.SetColorMatrix($cm)
  $st = $g.Save()
  # pull the object's base to the origin, skew it down, stretch it sideways,
  # then push it back — so the shadow grows out from where the thing stands
  $m = [System.Drawing.Drawing2D.Matrix]::new()
  $m.Translate([single]$c.x, [single]($FLOOR - 4))
  $m.Shear(13.0, 0.0)
  $m.Scale([single]$c.stretch, [single]1)
  $m.Translate([single](-$c.x), [single](-($FLOOR - 4)))
  $g.Transform = $m
  $g.DrawImage($c.obj,
    (New-Object System.Drawing.Rectangle([single]($c.x - $OBJ_W / 2), [single]$OBJ_TOP, [single]$OBJ_W, [single]$OBJ_H)),
    0, 0, $S, $S, [System.Drawing.GraphicsUnit]::Pixel, $sm)
  $m.Dispose()
  $g.Restore($st)
  $sm.Dispose()
}

# ---------- the objects ----------
foreach ($c in $cast) {
  $g.DrawImage($c.obj,
    (New-Object System.Drawing.Rectangle([single]($c.x - $OBJ_W / 2), [single]$OBJ_TOP, [single]$OBJ_W, [single]$OBJ_H)),
    0, 0, $S, $S, [System.Drawing.GraphicsUnit]::Pixel)
  if ($c.heavy) {
    # a thin gold edge, so the eye lands on the one that weighs most
    $eg = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(150, 232, 186, 110), 2)
    $g.DrawEllipse($eg, [single]($c.x - $OBJ_W / 2), [single]$OBJ_TOP, [single]$OBJ_W, [single]$OBJ_H)
    $eg.Dispose()
  }
  $c.obj.Dispose()
}

# ---------- a low band of warm light, tying the three together ----------
$band = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, ($FLOOR - 190), $W, 190)),
  [System.Drawing.Color]::FromArgb(0, 150, 190, 240),
  [System.Drawing.Color]::FromArgb(24, 150, 190, 240), 90)
$g.FillRectangle($band, (New-Object System.Drawing.Rectangle(0, ($FLOOR - 190), $W, 190))); $band.Dispose()

# ---------- dust ----------
$rng = New-Object System.Random(1011)
for ($i = 0; $i -lt 52; $i++) {
  $cx = $rng.Next(0, $W)
  $cy = $rng.Next(0, $H)
  $d = $rng.Next(0, 100) / 100.0
  $rad = 1.4 + 7.0 * $d * $d
  $a = [int](6 + 22 * $d)
  Add-Glow $g $cx $cy $rad $a 255 236 200
}

# ---------- vignette ----------
$vg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, $W, 210)),
  [System.Drawing.Color]::FromArgb(205, 4, 7, 14),
  [System.Drawing.Color]::FromArgb(0, 4, 7, 14), 90)
$g.FillRectangle($vg, (New-Object System.Drawing.Rectangle(0, 0, $W, 210))); $vg.Dispose()
$vg2 = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, ($H - 250), $W, 250)),
  [System.Drawing.Color]::FromArgb(0, 4, 7, 14),
  [System.Drawing.Color]::FromArgb(200, 4, 7, 14), 90)
$g.FillRectangle($vg2, (New-Object System.Drawing.Rectangle(0, ($H - 250), $W, 250))); $vg2.Dispose()

$g.Dispose()
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $Out)