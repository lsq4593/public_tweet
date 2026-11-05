# generate_xiaochitan_cover_market.ps1
# Bustling night-market cover for:
#   03_独立文章/13_2026-11-03_小吃摊为什么越来越多.md
# Style: crowded street, rows of stalls, string lights, crowd silhouettes.

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$OutDir = "C:\Users\cbs\Desktop\公众号推文\03_独立文章\_配图"
$CoverOut = Join-Path $OutDir "小吃摊_封面_闹市版.png"

$skyTop     = [System.Drawing.Color]::FromArgb(255, 5, 9, 17)
$skyMid     = [System.Drawing.Color]::FromArgb(255, 15, 26, 43)
$groundTop  = [System.Drawing.Color]::FromArgb(255, 12, 18, 27)
$groundBot  = [System.Drawing.Color]::FromArgb(255, 5, 7, 11)
$silhouette = [System.Drawing.Color]::FromArgb(255, 9, 14, 23)
$silhouette2= [System.Drawing.Color]::FromArgb(255, 14, 22, 34)
$white      = [System.Drawing.Color]::FromArgb(255, 245, 242, 234)
$mute       = [System.Drawing.Color]::FromArgb(255, 176, 190, 208)
$gold       = [System.Drawing.Color]::FromArgb(255, 232, 178, 96)
$warm       = [System.Drawing.Color]::FromArgb(255, 255, 176, 84)
$warmLight  = [System.Drawing.Color]::FromArgb(255, 255, 222, 164)
$red        = [System.Drawing.Color]::FromArgb(255, 196, 72, 58)
$cream      = [System.Drawing.Color]::FromArgb(255, 246, 228, 200)
$cyan       = [System.Drawing.Color]::FromArgb(255, 127, 212, 245)

function Add-Grain {
  param($G, [int]$W, [int]$H, [int]$Seed)
  $rnd = New-Object System.Random $Seed
  for ($i = 0; $i -lt 2400; $i++) {
    $x = $rnd.Next(0, $W)
    $y = $rnd.Next(0, $H)
    $a = $rnd.Next(4, 16)
    if ($rnd.Next(0, 2) -eq 0) {
      $c = [System.Drawing.Color]::FromArgb($a, 255, 250, 236)
    } else {
      $c = [System.Drawing.Color]::FromArgb($a, 40, 30, 20)
    }
    $b = New-Object System.Drawing.SolidBrush $c
    $G.FillEllipse($b, $x, $y, 2, 2)
    $b.Dispose()
  }
}

function Add-Vignette {
  param($G, [int]$W, [int]$H)
  for ($i = 0; $i -lt 90; $i++) {
    $inset = $i * 6
    $rw = $W - 2 * $inset
    $rh = $H - [int]($inset * 1.4)
    if ($rw -le 0 -or $rh -le 0) { break }
    $p = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(3, 0, 0, 0), 12)
    $G.DrawRectangle($p, $inset, [int]($inset * 0.7), $rw, $rh)
    $p.Dispose()
  }
}

function Draw-Glow {
  param($G, [float]$X, [float]$Y, [float]$R, [System.Drawing.Color]$Color, [int]$Steps = 14, [int]$MaxAlpha = 80)
  for ($i = $Steps; $i -ge 1; $i--) {
    $rr = $R * $i / $Steps
    $a = [int]($MaxAlpha * [Math]::Pow(1 - $i / ($Steps + 1), 2))
    $b = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($a, $Color.R, $Color.G, $Color.B))
    $G.FillEllipse($b, ($X - $rr), ($Y - $rr), ($rr * 2), ($rr * 2))
    $b.Dispose()
  }
}

function Draw-LightString {
  param($G, [float]$X1, [float]$Y1, [float]$X2, [float]$Y2, [float]$Sag, [int]$Bulbs, [float]$BulbR)
  $prevX = $X1; $prevY = $Y1
  $wirePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(90, 255, 220, 160), 1)
  for ($i = 1; $i -le $Bulbs; $i++) {
    $t = $i / $Bulbs
    $x = $X1 + ($X2 - $X1) * $t
    $y = $Y1 + ($Y2 - $Y1) * $t + $Sag * 4 * $t * (1 - $t)
    $G.DrawLine($wirePen, $prevX, $prevY, $x, $y)
    $prevX = $x; $prevY = $y
    Draw-Glow $G $x $y ($BulbR * 6) $warmLight 8 80
    $b = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 236, 190))
    $G.FillEllipse($b, ($x - $BulbR), ($y - $BulbR), ($BulbR * 2), ($BulbR * 2))
    $b.Dispose()
  }
  $wirePen.Dispose()
}

function Draw-Lantern {
  param($G, [float]$X, [float]$Y, [float]$R)
  Draw-Glow $G $X $Y ($R * 4) $red 10 90
  $b = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 214, 78, 60))
  $G.FillEllipse($b, ($X - $R), ($Y - $R * 0.8), ($R * 2), ($R * 1.6))
  $b.Dispose()
  $cap = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 232, 178, 96))
  $G.FillRectangle($cap, ($X - $R * 0.35), ($Y - $R * 0.95), ($R * 0.7), ($R * 0.2))
  $G.FillRectangle($cap, ($X - $R * 0.35), ($Y + $R * 0.75), ($R * 0.7), ($R * 0.2))
  $cap.Dispose()
  $linePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(120, 255, 220, 160), 2)
  $G.DrawLine($linePen, $X, ($Y - $R * 1.4), $X, ($Y - $R * 0.95))
  $linePen.Dispose()
}

function Draw-Stall {
  param(
    $G, [float]$X, [float]$Base, [float]$W, [float]$H,
    [string]$Label, [int]$Tone = 0
  )

  $top = $Base - $H
  $bodyTop = $Base - $H * 0.56
  $bodyH = $H * 0.56

  # body shadow
  $sh = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(110, 0, 0, 0))
  $G.FillRectangle($sh, ($X + 6), ($bodyTop + 8), $W, $bodyH)
  $sh.Dispose()

  # body
  $body = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 16, 25, 38))
  $G.FillRectangle($body, $X, $bodyTop, $W, $bodyH)
  $body.Dispose()
  $bodyPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(110, 232, 178, 96), 2)
  $G.DrawRectangle($bodyPen, $X, $bodyTop, $W, $bodyH)
  $bodyPen.Dispose()

  # warm serving window
  $winX = $X + $W * 0.1
  $winY = $bodyTop + $H * 0.08
  $winW = $W * 0.8
  $winH = $H * 0.24
  Draw-Glow $G ($X + $W / 2) ($winY + $winH / 2) ($W * 0.5) $warm 10 45
  $winRect = New-Object System.Drawing.Rectangle([int]$winX, [int]$winY, [int]$winW, [int]$winH)
  $win = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $winRect,
    [System.Drawing.Color]::FromArgb(255, 255, 218, 158),
    [System.Drawing.Color]::FromArgb(255, 222, 132, 58),
    90)
  $G.FillRectangle($win, $winRect)
  $win.Dispose()

  # counter
  $counterPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 62, 42, 28), 4)
  $G.DrawLine($counterPen, $X, ($bodyTop + $H * 0.34), ($X + $W), ($bodyTop + $H * 0.34))
  $counterPen.Dispose()

  # awnings
  $ax = $X - $W * 0.05
  $ay = $top + $H * 0.18
  $aw = $W * 1.1
  $ah = $H * 0.24
  $redBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(235, 176, 62, 48))
  $G.FillRectangle($redBrush, $ax, $ay, $aw, $ah)
  $redBrush.Dispose()

  $stripeCount = 8
  $stripeW = $aw / $stripeCount
  for ($s = 0; $s -lt $stripeCount; $s++) {
    if ($s % 2 -eq 0) {
      $sb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(225, 246, 226, 196))
      $G.FillRectangle($sb, ($ax + $s * $stripeW), $ay, $stripeW, $ah)
      $sb.Dispose()
    }
  }

  # awning scallops
  $scallop = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(235, 176, 62, 48))
  for ($s = 0; $s -lt $stripeCount; $s++) {
    $G.FillEllipse($scallop, ($ax + $s * $stripeW), ($ay + $ah - $ah * 0.18), $stripeW, ($ah * 0.36))
  }
  $scallop.Dispose()

  # sign board
  $signW = $W * 0.62
  $signH = $H * 0.13
  $signX = $X + ($W - $signW) / 2
  $signY = $top + $H * 0.01
  $signFill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 24, 16, 14))
  $G.FillRectangle($signFill, $signX, $signY, $signW, $signH)
  $signFill.Dispose()
  $signPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(220, 232, 178, 96), 2)
  $G.DrawRectangle($signPen, $signX, $signY, $signW, $signH)
  $signPen.Dispose()
  $fSign = New-Object System.Drawing.Font("Microsoft YaHei UI", [float]([Math]::Max(12, $H * 0.075)), [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $sf = New-Object System.Drawing.StringFormat
  $sf.Alignment = [System.Drawing.StringAlignment]::Center
  $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
  $bSign = New-Object System.Drawing.SolidBrush $cream
  $signRect = New-Object System.Drawing.RectangleF($signX, $signY, $signW, $signH)
  $G.DrawString($Label, $fSign, $bSign, $signRect, $sf)
  $bSign.Dispose(); $sf.Dispose(); $fSign.Dispose()

  # bulbs under awning
  $bulbY = $ay + $ah + $H * 0.03
  for ($b = 0; $b -lt 4; $b++) {
    $bx = $ax + $aw * (0.14 + $b * 0.24)
    Draw-Glow $G $bx ($bulbY + 3) ($W * 0.05) $warmLight 6 80
    $bb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 236, 190))
    $G.FillEllipse($bb, ($bx - 2), ($bulbY + 2), 4, 4)
    $bb.Dispose()
  }

  # steam
  $steamPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(34, 255, 240, 214), 2)
  for ($st = 0; $st -lt 2; $st++) {
    $sx = $X + $W * (0.3 + $st * 0.3)
    $G.DrawArc($steamPen, $sx, ($ay - $H * 0.14), ($W * 0.12), ($H * 0.12), 200, 140)
    $G.DrawArc($steamPen, $sx, ($ay - $H * 0.21), ($W * 0.14), ($H * 0.14), 190, 130)
  }
  $steamPen.Dispose()
}

function Draw-Person {
  param($G, [float]$Cx, [float]$Base, [float]$H, [System.Drawing.Color]$Color, [bool]$Phone = $false)
  $headR = $H * 0.1
  $headY = $Base - $H + $headR
  $b = New-Object System.Drawing.SolidBrush $Color
  $G.FillEllipse($b, ($Cx - $headR), ($headY - $headR), ($headR * 2), ($headR * 2))
  $shoulderY = $headY + $headR * 0.8
  $bodyW = $H * 0.24
  $pts = @(
    (New-Object System.Drawing.PointF(($Cx - $headR * 0.55), $shoulderY)),
    (New-Object System.Drawing.PointF(($Cx + $headR * 0.55), $shoulderY)),
    (New-Object System.Drawing.PointF(($Cx + $bodyW), $Base)),
    (New-Object System.Drawing.PointF(($Cx - $bodyW), $Base))
  )
  $G.FillPolygon($b, $pts)
  $b.Dispose()
  if ($Phone) {
    Draw-Glow $G ($Cx + $bodyW * 0.55) ($Base - $H * 0.52) 18 $cyan 6 90
    $pb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(230, 190, 235, 255))
    $G.FillRectangle($pb, ($Cx + $bodyW * 0.5), ($Base - $H * 0.57), 6, 10)
    $pb.Dispose()
  }
}

# ---------- canvas ----------
$W = 1600
$H = 686
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# sky
$skyRect = New-Object System.Drawing.Rectangle(0, 0, $W, 470)
$sky = New-Object System.Drawing.Drawing2D.LinearGradientBrush($skyRect, $skyTop, $skyMid, 90)
$g.FillRectangle($sky, $skyRect)
$sky.Dispose()

# warm haze
$hazeRect = New-Object System.Drawing.Rectangle(0, 250, $W, 300)
$haze = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  $hazeRect,
  [System.Drawing.Color]::FromArgb(0, 255, 170, 90),
  [System.Drawing.Color]::FromArgb(82, 255, 146, 66),
  90)
$g.FillRectangle($haze, $hazeRect)
$haze.Dispose()

# distant skyline
$rnd = New-Object System.Random 20261103
for ($i = 0; $i -lt 30; $i++) {
  $bw = $rnd.Next(50, 130)
  $bh = $rnd.Next(70, 250)
  $bx = $i * 58 - 30
  $by = 470 - $bh
  $sb = New-Object System.Drawing.SolidBrush $silhouette2
  $g.FillRectangle($sb, $bx, $by, $bw, $bh)
  $sb.Dispose()
  for ($wy = $by + 18; $wy -lt 450; $wy += 28) {
    for ($wx = $bx + 12; $wx -lt ($bx + $bw - 10); $wx += 20) {
      if ((($wx + $wy + $i) % 6) -eq 0) {
        $wb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(130, 255, 206, 138))
        $g.FillRectangle($wb, $wx, $wy, 4, 6)
        $wb.Dispose()
      }
    }
  }
}

# far stall row
Draw-Stall $g 560 420 120 118 "糖水" 0
Draw-Stall $g 700 426 132 124 "凉皮" 0
Draw-Stall $g 850 424 126 120 "肠粉" 0
Draw-Stall $g 988 428 140 130 "炸串" 0
Draw-Stall $g 1140 422 128 122 "烤肠" 0
Draw-Stall $g 1290 426 140 130 "炒粉" 0
Draw-Stall $g 1450 420 130 120 "生蚝" 0

# ground
$groundRect = New-Object System.Drawing.Rectangle(0, 440, $W, ($H - 440))
$ground = New-Object System.Drawing.Drawing2D.LinearGradientBrush($groundRect, $groundTop, $groundBot, 90)
$g.FillRectangle($ground, $groundRect)
$ground.Dispose()

# mid stall row
Draw-Stall $g 500 508 170 178 "烤串" 1
Draw-Stall $g 700 516 190 192 "糖水" 1
Draw-Stall $g 920 510 180 184 "凉皮" 1
Draw-Stall $g 1130 518 200 198 "炸串" 1
Draw-Stall $g 1360 512 190 190 "臭豆腐" 1

# crowd (mid, behind foreground)
$crowdRnd = New-Object System.Random 42
$crowd = @()
for ($i = 0; $i -lt 46; $i++) {
  $cx = $crowdRnd.Next(430, 1590)
  $ph = $crowdRnd.Next(78, 138)
  $crowd += [pscustomobject]@{ X = $cx; H = $ph; Seed = $crowdRnd.Next(0, 100) }
}
$crowd = $crowd | Sort-Object H
foreach ($p in $crowd) {
  $shade = 9 + [int]($p.H / 18)
  $col = [System.Drawing.Color]::FromArgb(255, $shade, ($shade + 5), ($shade + 12))
  $phone = ($p.Seed % 9 -eq 0)
  Draw-Person $g $p.X 690 $p.H $col $phone
}

# foreground cart, right
Draw-Stall $g 1330 686 320 300 "小吃" 2

# string lights overhead
Draw-LightString $g 300 92 900 128 40 18 4
Draw-LightString $g 760 70 1300 118 50 20 4
Draw-LightString $g 1080 96 1600 84 34 16 4
Draw-Lantern $g 1040 150 18
Draw-Lantern $g 1220 132 16
Draw-Lantern $g 1460 168 20

# street reflections
$refRnd = New-Object System.Random 9
for ($i = 0; $i -lt 140; $i++) {
  $x = $refRnd.Next(430, 1600)
  $y = $refRnd.Next(520, 675)
  $len = $refRnd.Next(8, 40)
  $a = $refRnd.Next(8, 38)
  $p = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($a, 255, 190, 110), 2)
  $g.DrawLine($p, $x, $y, $x, ($y + $len))
  $p.Dispose()
}

# foreground vignette bottom
$fgRect = New-Object System.Drawing.Rectangle(0, 590, $W, 96)
$fg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  $fgRect,
  [System.Drawing.Color]::FromArgb(0, 0, 0, 0),
  [System.Drawing.Color]::FromArgb(160, 4, 6, 10),
  90)
$g.FillRectangle($fg, $fgRect)
$fg.Dispose()

# left overlay for text
$ovRect = New-Object System.Drawing.Rectangle(0, 0, 900, $H)
$ov = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  $ovRect,
  [System.Drawing.Color]::FromArgb(215, 4, 7, 12),
  [System.Drawing.Color]::FromArgb(0, 4, 7, 12),
  0)
$g.FillRectangle($ov, $ovRect)
$ov.Dispose()

# ---------- text ----------
$fBadge = New-Object System.Drawing.Font("Microsoft YaHei UI", 16, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$badgeFill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(150, 20, 28, 40))
$g.FillRectangle($badgeFill, 96, 48, 196, 36)
$badgeFill.Dispose()
$bGold = New-Object System.Drawing.SolidBrush $gold
$g.FillRectangle($bGold, 96, 48, 5, 36)
$g.DrawString("行业账本 · 02", $fBadge, $bGold, 116, 55)
$fBadge.Dispose()

$fKicker = New-Object System.Drawing.Font("Microsoft YaHei UI", 18, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bCyan = New-Object System.Drawing.SolidBrush $cyan
$g.DrawString("小吃摊为什么越来越多", $fKicker, $bCyan, 98, 126)
$fKicker.Dispose()
$bCyan.Dispose()

$goldBar = New-Object System.Drawing.SolidBrush $gold
$g.FillRectangle($goldBar, 96, 184, 138, 5)
$goldBar.Dispose()

$fTitle = New-Object System.Drawing.Font("Microsoft YaHei UI", 72, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bWhite = New-Object System.Drawing.SolidBrush $white
$g.DrawString("摆摊月入两万？", $fTitle, $bWhite, 92, 208)
$g.DrawString("时薪只有", $fTitle, $bWhite, 92, 298)
$bWhite.Dispose()
$bGold2 = New-Object System.Drawing.SolidBrush $gold
$g.DrawString("29块", $fTitle, $bGold2, 392, 298)
$bGold2.Dispose()
$fTitle.Dispose()

$fSub = New-Object System.Drawing.Font("Microsoft YaHei UI", 27, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bSub = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(240, 210, 200, 184))
$g.DrawString("不是风口，是退路", $fSub, $bSub, 96, 412)
$bSub.Dispose()
$fSub.Dispose()

$fFoot = New-Object System.Drawing.Font("Microsoft YaHei UI", 18, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bFoot = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(200, 160, 176, 196))
$g.DrawString("卖车的，比开车的不慌", $fFoot, $bFoot, 98, 486)
$bFoot.Dispose()
$fFoot.Dispose()

# corner marks
$cm = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(60, 232, 178, 96), 2)
$g.DrawLine($cm, 40, 40, 120, 40)
$g.DrawLine($cm, 40, 40, 40, 120)
$g.DrawLine($cm, ($W - 40), ($H - 40), ($W - 120), ($H - 40))
$g.DrawLine($cm, ($W - 40), ($H - 40), ($W - 40), ($H - 120))
$cm.Dispose()

Add-Vignette $g $W $H
Add-Grain $g $W $H 20261105

$g.Dispose()
$bmp.Save($CoverOut, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $CoverOut)
