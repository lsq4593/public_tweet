# generate_jianshenfang_cover.ps1
# Cover for:
#   03_独立文章/15_2026-11-05_你越不去，健身房越赚钱.md
# Style: deep navy, gold accent, unused annual membership card.

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$OutDir = "C:\Users\cbs\Desktop\公众号推文\03_独立文章\_配图"
$CoverOut = Join-Path $OutDir "健身房_封面.png"

$navyTop    = [System.Drawing.Color]::FromArgb(255, 7, 13, 26)
$navyBottom = [System.Drawing.Color]::FromArgb(255, 22, 35, 58)
$white      = [System.Drawing.Color]::FromArgb(255, 245, 242, 234)
$cream      = [System.Drawing.Color]::FromArgb(255, 246, 228, 200)
$mute       = [System.Drawing.Color]::FromArgb(255, 176, 190, 208)
$gold       = [System.Drawing.Color]::FromArgb(255, 232, 178, 96)
$cyan       = [System.Drawing.Color]::FromArgb(255, 127, 212, 245)
$cardTop    = [System.Drawing.Color]::FromArgb(255, 32, 45, 63)
$cardBottom = [System.Drawing.Color]::FromArgb(255, 12, 20, 33)

function New-RoundedPath {
  param([float]$X, [float]$Y, [float]$W, [float]$H, [float]$R)
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $R * 2
  $p.AddArc($X, $Y, $d, $d, 180, 90)
  $p.AddArc(($X + $W - $d), $Y, $d, $d, 270, 90)
  $p.AddArc(($X + $W - $d), ($Y + $H - $d), $d, $d, 0, 90)
  $p.AddArc($X, ($Y + $H - $d), $d, $d, 90, 90)
  $p.CloseFigure()
  return $p
}

function Fill-Rounded {
  param($G, $Brush, [float]$X, [float]$Y, [float]$W, [float]$H, [float]$R)
  $p = New-RoundedPath $X $Y $W $H $R
  $G.FillPath($Brush, $p)
  $p.Dispose()
}

function Draw-Rounded {
  param($G, $Pen, [float]$X, [float]$Y, [float]$W, [float]$H, [float]$R)
  $p = New-RoundedPath $X $Y $W $H $R
  $G.DrawPath($Pen, $p)
  $p.Dispose()
}

function Draw-Centered {
  param($G, [string]$Text, $Font, $Brush, [float]$X, [float]$Y, [float]$W, [float]$H)
  $sf = New-Object System.Drawing.StringFormat
  $sf.Alignment = [System.Drawing.StringAlignment]::Center
  $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
  $rect = New-Object System.Drawing.RectangleF($X, $Y, $W, $H)
  $G.DrawString($Text, $Font, $Brush, $rect, $sf)
  $sf.Dispose()
}

function Draw-Glow {
  param($G, [float]$X, [float]$Y, [float]$R, [System.Drawing.Color]$Color, [int]$Steps = 16, [int]$MaxAlpha = 70)
  for ($i = $Steps; $i -ge 1; $i--) {
    $rr = $R * $i / $Steps
    $a = [int]($MaxAlpha * [Math]::Pow(1 - $i / ($Steps + 1), 2))
    $b = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($a, $Color.R, $Color.G, $Color.B))
    $G.FillEllipse($b, ($X - $rr), ($Y - $rr), ($rr * 2), ($rr * 2))
    $b.Dispose()
  }
}

function Add-Grain {
  param($G, [int]$W, [int]$H, [int]$Seed)
  $rnd = New-Object System.Random $Seed
  for ($i = 0; $i -lt 1900; $i++) {
    $x = $rnd.Next(0, $W)
    $y = $rnd.Next(0, $H)
    $a = $rnd.Next(4, 15)
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
  for ($i = 0; $i -lt 80; $i++) {
    $inset = $i * 7
    $rw = $W - 2 * $inset
    $rh = $H - [int]($inset * 1.4)
    if ($rw -le 0 -or $rh -le 0) { break }
    $p = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(3, 0, 0, 0), 14)
    $G.DrawRectangle($p, $inset, [int]($inset * 0.7), $rw, $rh)
    $p.Dispose()
  }
}

$W = 1600
$H = 686
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# background
$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $navyTop, $navyBottom, 18)
$g.FillRectangle($bg, $rect)
$bg.Dispose()

# grid
$gridPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(13, 100, 180, 255), 1)
for ($x = 0; $x -le $W; $x += 80) { $g.DrawLine($gridPen, $x, 0, $x, $H) }
for ($y = 0; $y -le $H; $y += 80) { $g.DrawLine($gridPen, 0, $y, $W, $y) }
$gridPen.Dispose()

# glow behind card
Draw-Glow $g 1200 350 410 $gold 18 50

# watermark 1999
$fMark = New-Object System.Drawing.Font("Consolas", 290, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bMark = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(11, 232, 178, 96))
$g.DrawString("1999", $fMark, $bMark, 985, 315)
$bMark.Dispose()
$fMark.Dispose()

# ---------- membership card ----------
$cardW = 540
$cardH = 340
$state = $g.Save()
$g.TranslateTransform(1210, 350)
$g.RotateTransform(-6)

$shadow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(150, 0, 0, 0))
Fill-Rounded $g $shadow ((-$cardW / 2) + 16) ((-$cardH / 2) + 18) $cardW $cardH 24
$shadow.Dispose()

$cardRect = New-Object System.Drawing.RectangleF((- $cardW / 2), (- $cardH / 2), $cardW, $cardH)
$cardBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($cardRect, $cardTop, $cardBottom, 28)
Fill-Rounded $g $cardBrush (- $cardW / 2) (- $cardH / 2) $cardW $cardH 24
$cardBrush.Dispose()

$edgePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(210, 232, 178, 96), 2.5)
Draw-Rounded $g $edgePen (- $cardW / 2) (- $cardH / 2) $cardW $cardH 24
$edgePen.Dispose()

$innerPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(80, 232, 178, 96), 1)
Draw-Rounded $g $innerPen ((- $cardW / 2) + 12) ((- $cardH / 2) + 12) ($cardW - 24) ($cardH - 24) 16
$innerPen.Dispose()

# top labels
$fTop = New-Object System.Drawing.Font("Consolas", 17, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bGold = New-Object System.Drawing.SolidBrush $gold
$g.DrawString("ANNUAL PASS", $fTop, $bGold, (- $cardW / 2 + 28), (- $cardH / 2 + 24))
$bGold.Dispose()

$fTop2 = New-Object System.Drawing.Font("Consolas", 14, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bMute = New-Object System.Drawing.SolidBrush $mute
$sfRight = New-Object System.Drawing.StringFormat
$sfRight.Alignment = [System.Drawing.StringAlignment]::Far
$g.DrawString("NO. 0001", $fTop2, $bMute, (New-Object System.Drawing.RectangleF((- $cardW / 2 + 300), (- $cardH / 2 + 26), 210, 24)), $sfRight)
$sfRight.Dispose()
$fTop.Dispose()
$fTop2.Dispose()

# card title
$fCardTitle = New-Object System.Drawing.Font("Microsoft YaHei UI", 24, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bCream = New-Object System.Drawing.SolidBrush $cream
$g.DrawString("健身年卡", $fCardTitle, $bCream, (- $cardW / 2 + 28), (- $cardH / 2 + 56))
$fCardTitle.Dispose()
$bCream.Dispose()

# price
$fPrice = New-Object System.Drawing.Font("Microsoft YaHei UI", 104, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bWhite = New-Object System.Drawing.SolidBrush $white
$g.DrawString("1999", $fPrice, $bWhite, (- $cardW / 2 + 24), (- $cardH / 2 + 88))
$fPrice.Dispose()
$bWhite.Dispose()

$fYen = New-Object System.Drawing.Font("Microsoft YaHei UI", 22, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bGold2 = New-Object System.Drawing.SolidBrush $gold
$g.DrawString("¥ / 年", $fYen, $bGold2, (- $cardW / 2 + 270), (- $cardH / 2 + 162))
$fYen.Dispose()
$bGold2.Dispose()

# chip
$chipRect = New-Object System.Drawing.RectangleF((- $cardW / 2 + 28), (- $cardH / 2 + 210), 52, 38)
$chipBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($chipRect, [System.Drawing.Color]::FromArgb(255, 246, 210, 140), [System.Drawing.Color]::FromArgb(255, 180, 120, 40), 35)
Fill-Rounded $g $chipBrush (- $cardW / 2 + 28) (- $cardH / 2 + 210) 52 38 7
$chipBrush.Dispose()
$chipPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(180, 120, 80, 30), 1)
$g.DrawLine($chipPen, (- $cardW / 2 + 28), (- $cardH / 2 + 229), (- $cardW / 2 + 80), (- $cardH / 2 + 229))
$g.DrawLine($chipPen, (- $cardW / 2 + 54), (- $cardH / 2 + 210), (- $cardW / 2 + 54), (- $cardH / 2 + 248))
$chipPen.Dispose()

# attendance label
$fLabel = New-Object System.Drawing.Font("Microsoft YaHei UI", 15, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bMute2 = New-Object System.Drawing.SolidBrush $mute
$g.DrawString("12 个月到店记录", $fLabel, $bMute2, (- $cardW / 2 + 96), (- $cardH / 2 + 218))
$fLabel.Dispose()
$bMute2.Dispose()

# 12 month boxes, mostly empty
$fCheck = New-Object System.Drawing.Font("Microsoft YaHei UI", 15, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
for ($i = 0; $i -lt 12; $i++) {
  $bx = (- $cardW / 2 + 28) + $i * 40
  $by = (- $cardH / 2 + 252)
  $bw = 30
  $bh = 30
  if ($i -eq 0 -or $i -eq 3) {
    $fb = New-Object System.Drawing.SolidBrush $gold
    Fill-Rounded $g $fb $bx $by $bw $bh 5
    $fb.Dispose()
    $bDark = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(200, 15, 22, 34))
    Draw-Centered $g "✓" $fCheck $bDark $bx $by $bw $bh
    $bDark.Dispose()
  } else {
    $eb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(60, 232, 178, 96))
    Fill-Rounded $g $eb $bx $by $bw $bh 5
    $eb.Dispose()
    $ep = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(70, 232, 178, 96), 1)
    Draw-Rounded $g $ep $bx $by $bw $bh 5
    $ep.Dispose()
  }
}
$fCheck.Dispose()

# barcode
$barX = (- $cardW / 2 + 28)
$barY = (- $cardH / 2 + 298)
$barPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(180, 232, 178, 96), 2)
$barPen2 = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(180, 232, 178, 96), 4)
for ($i = 0; $i -lt 22; $i++) {
  $lineX = $barX + $i * 5
  if ($i % 3 -eq 0) {
    $g.DrawLine($barPen2, $lineX, $barY, $lineX, ($barY + 22))
  } else {
    $g.DrawLine($barPen, $lineX, $barY, $lineX, ($barY + 22))
  }
}
$barPen.Dispose()
$barPen2.Dispose()

$fValid = New-Object System.Drawing.Font("Consolas", 12, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bMute3 = New-Object System.Drawing.SolidBrush $mute
$g.DrawString("VALID 12 MONTHS", $fValid, $bMute3, (- $cardW / 2 + 160), (- $cardH / 2 + 298))
$fValid.Dispose()

$fHolder = New-Object System.Drawing.Font("Microsoft YaHei UI", 14, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bMute4 = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(190, 176, 190, 208))
$g.DrawString("持卡人：那个总说「下周一定去」的人", $fHolder, $bMute4, (- $cardW / 2 + 28), (- $cardH / 2 + 320))
$fHolder.Dispose()
$bMute4.Dispose()
$bMute3.Dispose()

$g.Restore($state)

# ---------- left text ----------
$fTitle = New-Object System.Drawing.Font("Microsoft YaHei UI", 92, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bWhite2 = New-Object System.Drawing.SolidBrush $white
$g.DrawString("你越不去", $fTitle, $bWhite2, 90, 238)
$bWhite2.Dispose()
$fTitle.Dispose()

$fTitle2 = New-Object System.Drawing.Font("Microsoft YaHei UI", 92, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bGold4 = New-Object System.Drawing.SolidBrush $gold
$g.DrawString("它越赚钱", $fTitle2, $bGold4, 90, 348)
$bGold4.Dispose()
$fTitle2.Dispose()

# corner marks
$cm = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(65, 232, 178, 96), 2)
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
