# generate_cover_member_break.ps1
# 21:9 (1792x768) illustration for "会员到期提醒".
#
# Scene: a figure has just tossed a coin. Above it the coin turns into a rising
# cluster of larger, fading coins — what he is thinking about. On the left the
# membership card lies snapped in two. No text anywhere.
#
# Style: flat silhouette + single gold accent, matching the dark navy house look.
param(
  [string]$Out = "C:\Users\cbs\Desktop\公众号推文\01_精准深耕系列\_配图\会员到期_封面.png"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$W = 1792
$H = 768
$FLOOR = 660

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# ---------- palette ----------
$cDeep    = [System.Drawing.Color]::FromArgb(255, 6, 10, 20)
$cNavy    = [System.Drawing.Color]::FromArgb(255, 20, 31, 53)
$cFigure  = [System.Drawing.Color]::FromArgb(255, 9, 14, 26)
$cFigureL = [System.Drawing.Color]::FromArgb(255, 17, 26, 44)
$cGold    = [System.Drawing.Color]::FromArgb(255, 232, 186, 110)
$cGoldHot = [System.Drawing.Color]::FromArgb(255, 255, 232, 176)
$cCard    = [System.Drawing.Color]::FromArgb(255, 30, 44, 70)
$cCardL   = [System.Drawing.Color]::FromArgb(255, 44, 62, 94)
$cHair    = [System.Drawing.Color]::FromArgb(150, 96, 128, 168)

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

# ---------- background ----------
$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $cDeep, $cNavy, 80)
$g.FillRectangle($bg, $rect); $bg.Dispose()

# light behind the figure, and a cool wash behind the card
Add-Glow $g 760 330 430 30 130 172 235
Add-Glow $g 300 330 400 20 90 130 200

# ---------- floor ----------
$fl = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 13, 20, 34))
$g.FillRectangle($fl, 0, $FLOOR, $W, ($H - $FLOOR)); $fl.Dispose()
$ln = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(120, 96, 128, 168), 2)
$g.DrawLine($ln, 0, $FLOOR, $W, $FLOOR); $ln.Dispose()

# =========================================================
#  the coin, mid-flight
# =========================================================
function Draw-Coin {
  param($g, [double]$cx, [double]$cy, [double]$r, [int]$alpha, [bool]$solid)
  if ($alpha -le 1) { return }
  Add-Glow $g $cx $cy ($r * 4.2) ([int]($alpha * 0.55)) 232 186 110
  $b = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($alpha, 232, 186, 110))
  $g.FillEllipse($b, [single]($cx - $r), [single]($cy - $r), [single](2 * $r), [single]2 * $r)
  $b.Dispose()
  # rim + inner face, so it reads as a coin rather than a dot
  $p = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb([int]($alpha * 0.9), 255, 226, 168), [single][math]::Max(1, $r * 0.16))
  $g.DrawEllipse($p, [single]($cx - $r), [single]($cy - $r), [single](2 * $r), [single]2 * $r)
  $p.Dispose()
  if ($r -ge 9) {
    $p2 = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb([int]($alpha * 0.55), 255, 226, 168), [single][math]::Max(1, $r * 0.1))
    $g.DrawEllipse($p2, [single]($cx - $r * 0.62), [single]($cy - $r * 0.62), [single](1.24 * $r), [single]1.24 * $r)
    $p2.Dispose()
  }
}

# =========================================================
#  the thought: the coin keeps rising, bigger and emptier
# =========================================================
$thought = @(
  @(1010, 250, 26, 150),
  @(1096, 176, 33, 108),
  @(1196, 112, 41,  74),
  @(1312,  58, 50,  46),
  @(1444,  16, 60,  26),
  @(1580, -18, 70, 12)
)
foreach ($t in $thought) { Draw-Coin $g $t[0] $t[1] $t[2] $t[3] $false }

# the release: small coins just leaving the hand
Draw-Coin $g  900 470 13 225 $true
Draw-Coin $g  944 428 11 190 $true
Draw-Coin $g  976 396  9 150 $true

# flat [x,y,x,y,...] -> PointF[]
function Pts {
  param([double[]]$xy)
  $a = New-Object System.Drawing.PointF[] ([int]($xy.Length / 2))
  for ($i = 0; $i -lt $a.Length; $i++) {
    $a[$i] = New-Object System.Drawing.PointF ([single]$xy[$i * 2]), ([single]$xy[$i * 2 + 1])
  }
  return ,$a
}

# GraphicsPath.AddLine(float,float) overload gets mis-resolved by PowerShell —
# always hand it PointF objects instead
function PF { param([double]$x, [double]$y)
  return (New-Object System.Drawing.PointF ([single]$x), ([single]$y))
}
function Add-L { param($path, [double]$x1, [double]$y1, [double]$x2, [double]$y2)
  $path.AddLine((PF $x1 $y1), (PF $x2 $y2))
}

# =========================================================
#  the figure — silhouette, facing right, arm just released
# =========================================================
$FX = 760.0            # centre line of the body
$fig = New-Object System.Drawing.SolidBrush $cFigure

# legs
$legL = New-Object System.Drawing.Drawing2D.GraphicsPath
$legL.AddPolygon((Pts @(
  ($FX - 26), ($FLOOR - 186), ($FX - 4), ($FLOOR - 186),
  ($FX - 2), $FLOOR,        ($FX - 30), $FLOOR)))
$g.FillPath($fig, $legL); $legL.Dispose()
$legR = New-Object System.Drawing.Drawing2D.GraphicsPath
$legR.AddPolygon((Pts @(
  ($FX + 4), ($FLOOR - 186), ($FX + 26), ($FLOOR - 186),
  ($FX + 34), $FLOOR,       ($FX + 6),  $FLOOR)))
$g.FillPath($fig, $legR); $legR.Dispose()

# torso, slightly leaning forward
$torso = New-Object System.Drawing.Drawing2D.GraphicsPath
$torso.AddBezier(
  [single]($FX - 34), [single]($FLOOR - 300),
  [single]($FX - 40), [single]($FLOOR - 250),
  [single]($FX - 30), [single]($FLOOR - 214),
  [single]($FX - 27), [single]($FLOOR - 182))
$torso.AddLine((PF ($FX + 27) ($FLOOR - 182)), (PF ($FX + 34) ($FLOOR - 300)))
$torso.AddBezier(
  [single]($FX + 30), [single]($FLOOR - 214),
  [single]($FX + 42), [single]($FLOOR - 250),
  [single]($FX + 36), [single]($FLOOR - 302),
  [single]($FX + 34), [single]($FLOOR - 300))
$torso.CloseFigure()
$g.FillPath($fig, $torso); $torso.Dispose()

# neck
$neck = New-Object System.Drawing.SolidBrush $cFigure
$g.FillRectangle($neck, [single]($FX - 9), [single]($FLOOR - 322), 18, 26)
$neck.Dispose()

# head
$head = New-Object System.Drawing.SolidBrush $cFigure
$g.FillEllipse($head, [single]($FX - 30), [single]($FLOOR - 388), 60, 68)
$head.Dispose()
$hair = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 5, 8, 18))
$g.FillPie($hair, [single]($FX - 33), [single]($FLOOR - 392), 66, 52, 168, 168)
$g.FillRectangle($hair, [single]($FX - 33), [single]($FLOOR - 378), 20, 22)
$hair.Dispose()

# near arm — up and forward, fingers just opened
$arm = New-Object System.Drawing.Drawing2D.GraphicsPath
$arm.AddBezier(
  [single]($FX + 26), [single]($FLOOR - 296),
  [single]($FX + 74), [single]($FLOOR - 300),
  [single]($FX + 108), [single]($FLOOR - 286),
  [single]($FX + 138), [single]($FLOOR - 258))
$arm.AddBezier(
  [single]($FX + 148), [single]($FLOOR - 248),
  [single]($FX + 136), [single]($FLOOR - 238),
  [single]($FX + 122), [single]($FLOOR - 244),
  [single]($FX + 116), [single]($FLOOR - 252))
$arm.AddBezier(
  [single]($FX + 86), [single]($FLOOR - 274),
  [single]($FX + 56), [single]($FLOOR - 276),
  [single]($FX + 14), [single]($FLOOR - 272),
  [single]($FX + 14), [single]($FLOOR - 272))
$arm.CloseFigure()
$g.FillPath($fig, $arm); $arm.Dispose()

# far arm, hanging
$arm2 = New-Object System.Drawing.Drawing2D.GraphicsPath
$arm2.AddBezier(
  [single]($FX - 30), [single]($FLOOR - 294),
  [single]($FX - 46), [single]($FLOOR - 250),
  [single]($FX - 44), [single]($FLOOR - 216),
  [single]($FX - 34), [single]($FLOOR - 190))
$arm2.AddLine((PF ($FX - 14) ($FLOOR - 196)), (PF ($FX - 34) ($FLOOR - 190)))
$arm2.AddBezier(
  [single]($FX - 24), [single]($FLOOR - 224),
  [single]($FX - 26), [single]($FLOOR - 254),
  [single]($FX - 12), [single]($FLOOR - 288),
  [single]($FX - 12), [single]($FLOOR - 288))
$arm2.CloseFigure()
$g.FillPath($fig, $arm2); $arm2.Dispose()

# =========================================================
#  the membership card, snapped in two
# =========================================================
$CX = 296.0; $CY = 348.0; $CWD = 272.0; $CHT = 170.0

# crack profile: (t down the card 0..1, horizontal offset as a fraction of width)
$crack = @(
  @(0.00,  0.000),
  @(0.11, -0.055),
  @(0.24,  0.042),
  @(0.38, -0.030),
  @(0.52,  0.062),
  @(0.66, -0.048),
  @(0.80,  0.036),
  @(1.00,  0.000)
)

# Each half is a plain closed polygon — far more predictable than clipping.
# $mirror flips the crack so the two torn edges fit like real paper.
function New-CardHalf {
  param([double]$x0, [double]$y0, [double]$w, [double]$h, $crk, [bool]$mirror)
  $xc = $x0 + $w * 0.5
  $pts = New-Object System.Collections.ArrayList
  if (-not $mirror) {
    [void]$pts.Add((PF $x0 $y0))
    [void]$pts.Add((PF $xc $y0))
    foreach ($c in $crk) {
      [void]$pts.Add((PF ($xc + ([double]$c[1]) * $w) ($y0 + ([double]$c[0]) * $h)))
    }
    [void]$pts.Add((PF $x0 ($y0 + $h)))
  } else {
    # crack top -> bottom, then round the right edge back up, then close
    foreach ($c in $crk) {
      [void]$pts.Add((PF ($xc - ([double]$c[1]) * $w) ($y0 + ([double]$c[0]) * $h)))
    }
    [void]$pts.Add((PF ($x0 + $w) ($y0 + $h)))
    [void]$pts.Add((PF ($x0 + $w) $y0))
  }
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $p.AddPolygon($pts.ToArray())
  return $p
}

$cardL = New-CardHalf ($CX - $CWD / 2) ($CY - $CHT / 2) $CWD $CHT $crack $false
$b1 = New-Object System.Drawing.SolidBrush $cCard
$g.FillPath($b1, $cardL); $b1.Dispose()
$p1 = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(210, 108, 142, 184), 2)
$g.DrawPath($p1, $cardL); $p1.Dispose()
$cardL.Dispose()

# the chip, still seated in the left half
$chipX = $CX - $CWD / 2 + 26; $chipY = $CY - $CHT / 2 + 36
$chip = New-Object System.Drawing.SolidBrush $cCardL
$g.FillRectangle($chip, [single]$chipX, [single]$chipY, 48, 36)
$chip.Dispose()
$chipP = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(200, 158, 188, 220), 1)
$g.DrawRectangle($chipP, [single]$chipX, [single]$chipY, 48, 36)
$chipP.Dispose()
# two faint rules below the chip — a card face, no words
$rule = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(110, 150, 180, 214))
$g.FillRectangle($rule, [single]($CX - $CWD / 2 + 26), [single]($chipY + 56), 92, 4)
$g.FillRectangle($rule, [single]($CX - $CWD / 2 + 26), [single]($chipY + 70), 58, 4)
$rule.Dispose()

# right half — torn away, dropped lower, tipped over
$gap = 26.0
$rx = $CX + $CWD / 2 + $gap
$ry = $CY + 34
$st = $g.Save()
$g.TranslateTransform($rx, $ry)
$g.RotateTransform(8)
$cardR = New-CardHalf (-$CWD / 2) (-$CHT / 2) $CWD $CHT $crack $true
$b2 = New-Object System.Drawing.SolidBrush $cCard
$g.FillPath($b2, $cardR); $b2.Dispose()
$p2 = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(210, 108, 142, 184), 2)
$g.DrawPath($p2, $cardR); $p2.Dispose()
$cardR.Dispose()
$stripe = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(110, 150, 180, 214))
$g.FillRectangle($stripe, [single](-$CWD / 2 + 34), [single](-$CHT / 2 + 40), 76, 4)
$stripe.Dispose()
$g.Restore($st)

# ---------- a cool haze to settle everything ----------
$haze = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, $W, $H)),
  [System.Drawing.Color]::FromArgb(14, 110, 150, 210),
  [System.Drawing.Color]::FromArgb(0, 110, 150, 210), 0)
$g.FillRectangle($haze, (New-Object System.Drawing.Rectangle(0, 0, $W, $H))); $haze.Dispose()

# ---------- vignette ----------
$vg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, $W, 200)),
  [System.Drawing.Color]::FromArgb(200, 4, 7, 14),
  [System.Drawing.Color]::FromArgb(0, 4, 7, 14), 90)
$g.FillRectangle($vg, (New-Object System.Drawing.Rectangle(0, 0, $W, 200))); $vg.Dispose()
$vg2 = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, ($H - 240), $W, 240)),
  [System.Drawing.Color]::FromArgb(0, 4, 7, 14),
  [System.Drawing.Color]::FromArgb(190, 4, 7, 14), 90)
$g.FillRectangle($vg2, (New-Object System.Drawing.Rectangle(0, ($H - 240), $W, 240))); $vg2.Dispose()

$g.Dispose()
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $Out)