# generate_xiaochitan_cover_night.ps1
# Alternative cinematic night-street cover for:
#   03_独立文章/13_2026-11-03_小吃摊为什么越来越多.md
# Style: dark night, warm cart lights, illustrated street, big type.

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$OutDir = "C:\Users\cbs\Desktop\公众号推文\03_独立文章\_配图"
$CoverOut = Join-Path $OutDir "小吃摊_封面_夜景版.png"

$skyTop     = [System.Drawing.Color]::FromArgb(255, 5, 9, 17)
$skyMid     = [System.Drawing.Color]::FromArgb(255, 14, 24, 40)
$horizon    = [System.Drawing.Color]::FromArgb(255, 52, 40, 30)
$groundTop  = [System.Drawing.Color]::FromArgb(255, 10, 15, 23)
$groundBot  = [System.Drawing.Color]::FromArgb(255, 5, 7, 11)
$silhouette = [System.Drawing.Color]::FromArgb(255, 8, 13, 21)
$silhouette2= [System.Drawing.Color]::FromArgb(255, 12, 19, 30)
$white      = [System.Drawing.Color]::FromArgb(255, 245, 242, 234)
$mute       = [System.Drawing.Color]::FromArgb(255, 176, 190, 208)
$gold       = [System.Drawing.Color]::FromArgb(255, 232, 178, 96)
$warm       = [System.Drawing.Color]::FromArgb(255, 255, 178, 88)
$warmLight  = [System.Drawing.Color]::FromArgb(255, 255, 220, 160)
$red        = [System.Drawing.Color]::FromArgb(255, 198, 78, 62)
$cyan       = [System.Drawing.Color]::FromArgb(255, 127, 212, 245)

function Add-Grain {
  param($G, [int]$W, [int]$H, [int]$Seed)
  $rnd = New-Object System.Random $Seed
  for ($i = 0; $i -lt 2200; $i++) {
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
  param($G, [float]$X, [float]$Y, [float]$R, [System.Drawing.Color]$Color, [int]$Steps = 16, [int]$MaxAlpha = 90)
  for ($i = $Steps; $i -ge 1; $i--) {
    $rr = $R * $i / $Steps
    $a = [int]($MaxAlpha * [Math]::Pow(1 - $i / ($Steps + 1), 2))
    $b = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($a, $Color.R, $Color.G, $Color.B))
    $G.FillEllipse($b, ($X - $rr), ($Y - $rr), ($rr * 2), ($rr * 2))
    $b.Dispose()
  }
}

# ---------- background ----------
$W = 1600
$H = 686
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

$skyRect = New-Object System.Drawing.Rectangle(0, 0, $W, 500)
$sky = New-Object System.Drawing.Drawing2D.LinearGradientBrush($skyRect, $skyTop, $skyMid, 90)
$g.FillRectangle($sky, $skyRect)
$sky.Dispose()

# warm haze at the horizon
$hazeRect = New-Object System.Drawing.Rectangle(0, 330, $W, 170)
$haze = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  $hazeRect,
  [System.Drawing.Color]::FromArgb(0, 255, 170, 90),
  [System.Drawing.Color]::FromArgb(70, 255, 150, 70),
  90)
$g.FillRectangle($haze, $hazeRect)
$haze.Dispose()

# ---------- distant skyline ----------
$rnd = New-Object System.Random 20261103
$baseY = 486
for ($i = 0; $i -lt 26; $i++) {
  $bw = $rnd.Next(50, 120)
  $bh = $rnd.Next(60, 220)
  $bx = $i * 66 - 30
  $by = $baseY - $bh
  $sb = New-Object System.Drawing.SolidBrush $silhouette2
  $g.FillRectangle($sb, $bx, $by, $bw, $bh)
  $sb.Dispose()
  for ($wy = $by + 16; $wy -lt ($baseY - 12); $wy += 26) {
    for ($wx = $bx + 10; $wx -lt ($bx + $bw - 10); $wx += 18) {
      if ((($wx + $wy + $i) % 5) -eq 0) {
        $wb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(150, 255, 206, 138))
        $g.FillRectangle($wb, $wx, $wy, 4, 6)
        $wb.Dispose()
      }
    }
  }
}

# ---------- street ----------
$groundRect = New-Object System.Drawing.Rectangle(0, 486, $W, ($H - 486))
$ground = New-Object System.Drawing.Drawing2D.LinearGradientBrush($groundRect, $groundTop, $groundBot, 90)
$g.FillRectangle($ground, $groundRect)
$ground.Dispose()

# wet pavement reflections
$refRnd = New-Object System.Random 7
for ($i = 0; $i -lt 90; $i++) {
  $x = $refRnd.Next(600, 1600)
  $y = $refRnd.Next(500, 670)
  $len = $refRnd.Next(6, 34)
  $a = $refRnd.Next(8, 40)
  $p = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($a, 255, 190, 110), 2)
  $g.DrawLine($p, $x, $y, $x, ($y + $len))
  $p.Dispose()
}

# ---------- cart drawing ----------
function Draw-Cart {
  param(
    $G, [float]$X, [float]$Y, [float]$W, [float]$H,
    [bool]$Near = $false
  )

  $bodyTop = $Y + $H * 0.46
  $bodyH = $H * 0.42

  # shadow
  $sh = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(120, 0, 0, 0))
  $G.FillEllipse($sh, ($X - $W * 0.08), ($Y + $H * 0.86), ($W * 1.16), ($H * 0.18))
  $sh.Dispose()

  # body
  $body = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 16, 25, 38))
  $G.FillRectangle($body, $X, $bodyTop, $W, $bodyH)
  $body.Dispose()
  $bodyPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(120, 232, 178, 96), 2)
  $G.DrawRectangle($bodyPen, $X, $bodyTop, $W, $bodyH)
  $bodyPen.Dispose()

  # serving window (warm light inside)
  $winX = $X + $W * 0.08
  $winY = $bodyTop + $H * 0.06
  $winW = $W * 0.84
  $winH = $H * 0.2
  Draw-Glow $G ($X + $W / 2) ($winY + $winH / 2) ($W * 0.46) $warm 14 55
  $winRect = New-Object System.Drawing.Rectangle([int]$winX, [int]$winY, [int]$winW, [int]$winH)
  $win = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $winRect,
    [System.Drawing.Color]::FromArgb(255, 255, 214, 150),
    [System.Drawing.Color]::FromArgb(255, 224, 138, 62),
    90)
  $G.FillRectangle($win, $winX, $winY, $winW, $winH)
  $win.Dispose()

  # counter
  $counterPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 60, 42, 28), 4)
  $G.DrawLine($counterPen, $X, ($bodyTop + $H * 0.3), ($X + $W), ($bodyTop + $H * 0.3))
  $counterPen.Dispose()

  # awning
  $ax = $X - $W * 0.04
  $ay = $Y + $H * 0.24
  $aw = $W * 1.08
  $ah = $H * 0.2
  $redBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(235, 176, 62, 48))
  $G.FillRectangle($redBrush, $ax, $ay, $aw, $ah)
  $redBrush.Dispose()

  # awning stripes
  $stripeW = $aw / 9
  for ($s = 0; $s -lt 9; $s++) {
    if ($s % 2 -eq 0) {
      $sb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(220, 246, 226, 196))
      $G.FillRectangle($sb, ($ax + $s * $stripeW), $ay, $stripeW, $ah)
      $sb.Dispose()
    }
  }

  # awning scalloped edge
  $scallop = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(235, 176, 62, 48))
  for ($s = 0; $s -lt 9; $s++) {
    $G.FillEllipse($scallop, ($ax + $s * $stripeW), ($ay + $ah - $ah * 0.18), $stripeW, ($ah * 0.36))
  }
  $scallop.Dispose()

  # posts
  $postPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 44, 34, 26), [float]([Math]::Max(3, $W * 0.012)))
  $G.DrawLine($postPen, ($X + $W * 0.03), ($ay + $ah), ($X + $W * 0.03), ($bodyTop + $H * 0.1))
  $G.DrawLine($postPen, ($X + $W * 0.97), ($ay + $ah), ($X + $W * 0.97), ($bodyTop + $H * 0.1))
  $postPen.Dispose()

  # bulb string
  $bulbY = $ay + $ah + $H * 0.05
  $bulbPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(160, 255, 220, 160), 2)
  $G.DrawLine($bulbPen, ($ax + $aw * 0.06), $bulbY, ($ax + $aw * 0.94), $bulbY)
  $bulbPen.Dispose()
  for ($b = 0; $b -lt 6; $b++) {
    $bx = $ax + $aw * (0.1 + $b * 0.16)
    Draw-Glow $G $bx ($bulbY + 6) ($W * 0.06) $warmLight 10 100
    $bb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 236, 190))
    $G.FillEllipse($bb, ($bx - 3), ($bulbY + 3), 6, 6)
    $bb.Dispose()
  }

  # wheels
  $wheelR = $H * 0.075
  $wheelPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 30, 22, 18), 6)
  $G.DrawEllipse($wheelPen, ($X + $W * 0.16), ($Y + $H * 0.82), ($wheelR * 2), ($wheelR * 2))
  $G.DrawEllipse($wheelPen, ($X + $W * 0.68), ($Y + $H * 0.82), ($wheelR * 2), ($wheelR * 2))
  $wheelPen.Dispose()

  # steam above
  $steamPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(38, 255, 240, 214), 3)
  for ($st = 0; $st -lt 3; $st++) {
    $sx = $X + $W * (0.3 + $st * 0.18)
    $G.DrawArc($steamPen, $sx, ($ay - $H * 0.16), ($W * 0.1), ($H * 0.14), 200, 140)
    $G.DrawArc($steamPen, $sx, ($ay - $H * 0.24), ($W * 0.12), ($H * 0.16), 190, 130)
  }
  $steamPen.Dispose()

  # reflection under cart
  $refRect = New-Object System.Drawing.Rectangle([int]$X, [int]($Y + $H * 0.9), [int]$W, [int]($H * 0.35))
  $refBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $refRect,
    [System.Drawing.Color]::FromArgb(45, 255, 180, 90),
    [System.Drawing.Color]::FromArgb(0, 255, 180, 90),
    90)
  $G.FillRectangle($refBrush, $X, ($Y + $H * 0.9), $W, ($H * 0.35))
  $refBrush.Dispose()
}

# far, mid, near carts
Draw-Cart $g 760 300 190 150 $false
Draw-Cart $g 930 268 270 200 $false
Draw-Cart $g 1180 230 360 265 $true

# street lamp
Draw-Glow $g 690 250 150 $warm 18 70
$lampPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 24, 28, 36), 7)
$g.DrawLine($lampPen, 690, 250, 690, 520)
$g.DrawLine($lampPen, 690, 250, 640, 250)
$lampPen.Dispose()
$lamp = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 226, 170))
$g.FillEllipse($lamp, 626, 240, 20, 20)
$lamp.Dispose()

# foreground gradient
$fgRect = New-Object System.Drawing.Rectangle(0, 560, $W, 126)
$fg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  $fgRect,
  [System.Drawing.Color]::FromArgb(0, 0, 0, 0),
  [System.Drawing.Color]::FromArgb(170, 4, 6, 10),
  90)
$g.FillRectangle($fg, $fgRect)
$fg.Dispose()

# ---------- left overlay for text ----------
$ovRect = New-Object System.Drawing.Rectangle(0, 0, 880, $H)
$ov = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  $ovRect,
  [System.Drawing.Color]::FromArgb(200, 4, 7, 12),
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

# ---------- corner marks ----------
$cm = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(60, 232, 178, 96), 2)
$g.DrawLine($cm, 40, 40, 120, 40)
$g.DrawLine($cm, 40, 40, 40, 120)
$g.DrawLine($cm, ($W - 40), ($H - 40), ($W - 120), ($H - 40))
$g.DrawLine($cm, ($W - 40), ($H - 40), ($W - 40), ($H - 120))
$cm.Dispose()

Add-Vignette $g $W $H
Add-Grain $g $W $H 20261104

$g.Dispose()
$bmp.Save($CoverOut, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $CoverOut)
