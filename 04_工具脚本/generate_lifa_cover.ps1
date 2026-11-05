# generate_lifa_cover.ps1
# Cover for:
#   03_独立文章/14_2026-11-04_39.9三次的理发店靠什么赚钱.md
# Style: deep navy, gold accent, red promo poster, barber pole.

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$OutDir = "C:\Users\cbs\Desktop\公众号推文\03_独立文章\_配图"
$CoverOut = Join-Path $OutDir "理发店39.9_封面.png"

$navyTop    = [System.Drawing.Color]::FromArgb(255, 7, 13, 26)
$navyBottom = [System.Drawing.Color]::FromArgb(255, 22, 35, 58)
$white      = [System.Drawing.Color]::FromArgb(255, 245, 242, 234)
$cream      = [System.Drawing.Color]::FromArgb(255, 246, 228, 200)
$mute       = [System.Drawing.Color]::FromArgb(255, 176, 190, 208)
$gold       = [System.Drawing.Color]::FromArgb(255, 232, 178, 96)
$cyan       = [System.Drawing.Color]::FromArgb(255, 127, 212, 245)
$red        = [System.Drawing.Color]::FromArgb(255, 185, 59, 46)
$redDark    = [System.Drawing.Color]::FromArgb(255, 128, 34, 28)
$blue       = [System.Drawing.Color]::FromArgb(255, 32, 70, 120)

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
  param($G, [float]$X, [float]$Y, [float]$R, [System.Drawing.Color]$Color, [int]$Steps = 16, [int]$MaxAlpha = 80)
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
  for ($i = 0; $i -lt 2000; $i++) {
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
$gridPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(14, 100, 180, 255), 1)
for ($x = 0; $x -le $W; $x += 80) { $g.DrawLine($gridPen, $x, 0, $x, $H) }
for ($y = 0; $y -le $H; $y += 80) { $g.DrawLine($gridPen, 0, $y, $W, $y) }
$gridPen.Dispose()

# warm glow behind poster
Draw-Glow $g 1230 330 420 $gold 18 55

# watermark number
$fMark = New-Object System.Drawing.Font("Consolas", 300, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bMark = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(12, 232, 178, 96))
$g.DrawString("39.9", $fMark, $bMark, 1010, 300)
$bMark.Dispose()
$fMark.Dispose()

# ---------- barber pole ----------
$px = 918; $py = 120; $pw = 36; $ph = 440
$polePath = New-RoundedPath $px $py $pw $ph 16
$poleBg = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(230, 238, 232, 220))
$g.FillPath($poleBg, $polePath)
$poleBg.Dispose()

$state = $g.Save()
$g.SetClip($polePath)
$stripePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(235, 185, 59, 46), 13)
$stripePen2 = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(200, 32, 70, 120), 9)
for ($i = -$ph; $i -lt ($pw + $ph); $i += 34) {
  $g.DrawLine($stripePen, ($px + $i), ($py - 20), ($px + $i + $ph * 0.55), ($py + $ph + 20))
  $g.DrawLine($stripePen2, ($px + $i + 16), ($py - 20), ($px + $i + 16 + $ph * 0.55), ($py + $ph + 20))
}
$stripePen.Dispose()
$stripePen2.Dispose()
$g.Restore($state)
$polePath.Dispose()

$polePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(180, 232, 178, 96), 2)
Draw-Rounded $g $polePen $px $py $pw $ph 16
$polePen.Dispose()
$capBrush = New-Object System.Drawing.SolidBrush $gold
$g.FillEllipse($capBrush, ($px - 6), ($py - 10), ($pw + 12), 22)
$g.FillEllipse($capBrush, ($px - 6), ($py + $ph - 12), ($pw + 12), 22)
$capBrush.Dispose()

# ---------- red promo poster (rotated) ----------
$cardW = 470; $cardH = 470
$state = $g.Save()
$g.TranslateTransform(1240, 344)
$g.RotateTransform(-4)

$shadow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(130, 0, 0, 0))
Fill-Rounded $g $shadow ((-$cardW / 2) + 14) ((-$cardH / 2) + 16) $cardW $cardH 18
$shadow.Dispose()

$cardBrush = New-Object System.Drawing.SolidBrush $red
Fill-Rounded $g $cardBrush (-$cardW / 2) (-$cardH / 2) $cardW $cardH 18
$cardBrush.Dispose()

$edgePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(200, 232, 178, 96), 3)
Draw-Rounded $g $edgePen (-$cardW / 2) (-$cardH / 2) $cardW $cardH 18
$edgePen.Dispose()

$innerPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(120, 246, 228, 200), 1)
Draw-Rounded $g $innerPen ((-$cardW / 2) + 14) ((-$cardH / 2) + 14) ($cardW - 28) ($cardH - 28) 12
$innerPen.Dispose()

$fTop = New-Object System.Drawing.Font("Microsoft YaHei UI", 20, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bCream = New-Object System.Drawing.SolidBrush $cream
Draw-Centered $g "新 店 开 业" $fTop $bCream (-$cardW / 2) (-$cardH / 2 + 26) $cardW 40
$fTop.Dispose()

$fPrice = New-Object System.Drawing.Font("Microsoft YaHei UI", 150, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bWhite = New-Object System.Drawing.SolidBrush $white
Draw-Centered $g "39.9" $fPrice $bWhite (-$cardW / 2) (-$cardH / 2 + 72) $cardW 190
$fPrice.Dispose()
$bWhite.Dispose()

$fTimes = New-Object System.Drawing.Font("Microsoft YaHei UI", 42, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bCream2 = New-Object System.Drawing.SolidBrush $cream
Draw-Centered $g "三次  洗剪吹" $fTimes $bCream2 (-$cardW / 2) (-$cardH / 2 + 250) $cardW 60
$fTimes.Dispose()
$bCream2.Dispose()

$divPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(150, 246, 228, 200), 2)
$g.DrawLine($divPen, (-$cardW / 2 + 50), (-$cardH / 2 + 326), ($cardW / 2 - 50), (-$cardH / 2 + 326))
$divPen.Dispose()

$fSingle = New-Object System.Drawing.Font("Microsoft YaHei UI", 24, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bCream3 = New-Object System.Drawing.SolidBrush $cream
Draw-Centered $g "单次只收 13.3" $fSingle $bCream3 (-$cardW / 2) (-$cardH / 2 + 342) $cardW 40
$fSingle.Dispose()

$fBottom = New-Object System.Drawing.Font("Microsoft YaHei UI", 22, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bGold = New-Object System.Drawing.SolidBrush $gold
Draw-Centered $g "剪发是门票  升单才是演出" $fBottom $bGold (-$cardW / 2) (-$cardH / 2 + 392) $cardW 40
$fBottom.Dispose()
$bGold.Dispose()
$bCream3.Dispose()
$bCream.Dispose()

$g.Restore($state)

# ---------- left text ----------
$fBadge = New-Object System.Drawing.Font("Microsoft YaHei UI", 16, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$badgeFill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(130, 20, 32, 51))
Fill-Rounded $g $badgeFill 96 48 196 38 8
$badgeFill.Dispose()
$badgePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(150, 232, 178, 96), 2)
Draw-Rounded $g $badgePen 96 48 196 38 8
$badgePen.Dispose()
$bGold = New-Object System.Drawing.SolidBrush $gold
$g.DrawString("行业账本 · 03", $fBadge, $bGold, 114, 56)
$fBadge.Dispose()
$bGold.Dispose()

$fKicker = New-Object System.Drawing.Font("Microsoft YaHei UI", 18, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bCyan = New-Object System.Drawing.SolidBrush $cyan
$g.DrawString("39.9三次的理发店", $fKicker, $bCyan, 98, 126)
$fKicker.Dispose()
$bCyan.Dispose()

$goldBar = New-Object System.Drawing.SolidBrush $gold
$g.FillRectangle($goldBar, 96, 184, 138, 5)
$goldBar.Dispose()

$fTitle = New-Object System.Drawing.Font("Microsoft YaHei UI", 72, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bWhite2 = New-Object System.Drawing.SolidBrush $white
$g.DrawString("剪一次13块3", $fTitle, $bWhite2, 92, 208)
$g.DrawString("它靠什么赚钱？", $fTitle, $bWhite2, 92, 298)
$bWhite2.Dispose()
$fTitle.Dispose()

$fSub = New-Object System.Drawing.Font("Microsoft YaHei UI", 27, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bSub = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(240, 210, 200, 184))
$g.DrawString("低价是门票，升单才是演出", $fSub, $bSub, 96, 430)
$bSub.Dispose()
$fSub.Dispose()

$fFoot = New-Object System.Drawing.Font("Microsoft YaHei UI", 18, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bFoot = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(200, 160, 176, 196))
$g.DrawString("每剪一次亏 12–17 块", $fFoot, $bFoot, 98, 506)
$bFoot.Dispose()
$fFoot.Dispose()

$fFoot2 = New-Object System.Drawing.Font("Microsoft YaHei UI", 20, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bFoot2 = New-Object System.Drawing.SolidBrush $gold
$g.DrawString("回本，只看升单率", $fFoot2, $bFoot2, 98, 548)
$bFoot2.Dispose()
$fFoot2.Dispose()

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
