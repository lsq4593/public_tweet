# generate_xiaochitan_cover.ps1
# Cover for:
#   03_独立文章/13_2026-11-03_小吃摊为什么越来越多.md
# Style: deep navy, gold accent, editorial ledger card.

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$OutDir = "C:\Users\cbs\Desktop\公众号推文\03_独立文章\_配图"
$CoverOut = Join-Path $OutDir "小吃摊_封面.png"

$navyTop    = [System.Drawing.Color]::FromArgb(255, 7, 13, 26)
$navyBottom = [System.Drawing.Color]::FromArgb(255, 22, 35, 58)
$panel      = [System.Drawing.Color]::FromArgb(255, 12, 21, 36)
$panel2     = [System.Drawing.Color]::FromArgb(255, 16, 28, 46)
$line       = [System.Drawing.Color]::FromArgb(255, 42, 60, 86)
$white      = [System.Drawing.Color]::FromArgb(255, 245, 242, 234)
$mute       = [System.Drawing.Color]::FromArgb(255, 170, 186, 206)
$cyan       = [System.Drawing.Color]::FromArgb(255, 127, 212, 245)
$gold       = [System.Drawing.Color]::FromArgb(255, 232, 178, 96)
$red        = [System.Drawing.Color]::FromArgb(255, 201, 76, 67)

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

function Add-Grain {
  param($G, [int]$W, [int]$H, [int]$Seed)
  $rnd = New-Object System.Random $Seed
  for ($i = 0; $i -lt 1800; $i++) {
    $x = $rnd.Next(0, $W)
    $y = $rnd.Next(0, $H)
    $a = $rnd.Next(4, 18)
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
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# background
$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $navyTop, $navyBottom, 18)
$g.FillRectangle($bg, $rect)
$bg.Dispose()

# grid
$gridPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(16, 100, 180, 255), 1)
for ($x = 0; $x -le $W; $x += 80) { $g.DrawLine($gridPen, $x, 0, $x, $H) }
for ($y = 0; $y -le $H; $y += 80) { $g.DrawLine($gridPen, 0, $y, $W, $y) }
$gridPen.Dispose()

# warm glow behind ledger
for ($i = 14; $i -ge 1; $i--) {
  $a = [int](3 + (14 - $i) * 1.5)
  $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($a, 232, 178, 96), 26)
  Draw-Rounded $g $pen (1030 - $i * 9) (90 - $i * 9) (430 + $i * 18) (500 + $i * 18) 26
  $pen.Dispose()
}

# watermark yen
$fMark = New-Object System.Drawing.Font("Consolas", 300, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bMark = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(13, 232, 178, 96))
$g.DrawString("Y", $fMark, $bMark, 1190, 190)
$bMark.Dispose()
$fMark.Dispose()

# ---------- ledger card ----------
$lx = 1010; $ly = 96; $lw = 470; $lh = 480
$shadow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(120, 0, 0, 0))
Fill-Rounded $g $shadow ($lx - 18) ($ly + 10) ($lw + 36) ($lh + 36) 22
$shadow.Dispose()

$cardFill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(248, 12, 21, 36))
Fill-Rounded $g $cardFill $lx $ly $lw $lh 20
$cardFill.Dispose()

$cardPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(150, 232, 178, 96), 2)
Draw-Rounded $g $cardPen $lx $ly $lw $lh 20
$cardPen.Dispose()

$goldBar = New-Object System.Drawing.SolidBrush $gold
$g.FillRectangle($goldBar, ($lx + 26), ($ly + 22), 74, 4)
$goldBar.Dispose()

$fCardHead = New-Object System.Drawing.Font("Microsoft YaHei UI", 20, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bWhite = New-Object System.Drawing.SolidBrush $white
$g.DrawString("一辆小吃车的月度账本", $fCardHead, $bWhite, ($lx + 26), ($ly + 40))
$fCardHead.Dispose()

$fCardSub = New-Object System.Drawing.Font("Microsoft YaHei UI", 13, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bMute = New-Object System.Drawing.SolidBrush $mute
$g.DrawString("做的还不算差的那两三成", $fCardSub, $bMute, ($lx + 26), ($ly + 80))
$fCardSub.Dispose()

$divPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(120, 42, 60, 86), 1)
$g.DrawLine($divPen, ($lx + 26), ($ly + 112), ($lx + $lw - 26), ($ly + 112))
$divPen.Dispose()

function Draw-Row {
  param($G, [string]$Label, [string]$Value, [float]$X, [float]$Y, [float]$W, [System.Drawing.Color]$ValueColor)
  $fL = New-Object System.Drawing.Font("Microsoft YaHei UI", 17, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
  $fV = New-Object System.Drawing.Font("Consolas", 21, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $bL = New-Object System.Drawing.SolidBrush $mute
  $bV = New-Object System.Drawing.SolidBrush $ValueColor
  $G.DrawString($Label, $fL, $bL, $X, ($Y + 2))
  $sz = $G.MeasureString($Value, $fV)
  $G.DrawString($Value, $fV, $bV, ($X + $W - $sz.Width), $Y)
  $fL.Dispose(); $fV.Dispose(); $bL.Dispose(); $bV.Dispose()
}

Draw-Row $g "月流水" "¥15,000" ($lx + 26) ($ly + 138) ($lw - 52) $white
Draw-Row $g "毛利率" "60%" ($lx + 26) ($ly + 182) ($lw - 52) $cyan
Draw-Row $g "净得" "¥7,500" ($lx + 26) ($ly + 226) ($lw - 52) $white
Draw-Row $g "出摊" "26天 × 10小时" ($lx + 26) ($ly + 270) ($lw - 52) $white

$divPen2 = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(120, 42, 60, 86), 1)
$g.DrawLine($divPen2, ($lx + 26), ($ly + 322), ($lx + $lw - 26), ($ly + 322))
$divPen2.Dispose()

$fLabel = New-Object System.Drawing.Font("Microsoft YaHei UI", 15, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bMute2 = New-Object System.Drawing.SolidBrush $mute
$g.DrawString("算到最后，只剩这一个数", $fLabel, $bMute2, ($lx + 26), ($ly + 340))
$fLabel.Dispose()

$fBig = New-Object System.Drawing.Font("Microsoft YaHei UI", 58, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bGold = New-Object System.Drawing.SolidBrush $gold
$g.DrawString("¥29", $fBig, $bGold, ($lx + 20), ($ly + 364))
$fBig.Dispose()

$fUnit = New-Object System.Drawing.Font("Microsoft YaHei UI", 24, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString("/ 小时", $fUnit, $bGold, ($lx + 248), ($ly + 408))
$fUnit.Dispose()
$bGold.Dispose()

$fNote = New-Object System.Drawing.Font("Microsoft YaHei UI", 13, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bMute3 = New-Object System.Drawing.SolidBrush $mute
$g.DrawString("多数人算上备货损耗：十几块", $fNote, $bMute3, ($lx + 26), ($ly + 436))
$fNote.Dispose()
$bMute3.Dispose()

# red stamp (rotated)
$state = $g.Save()
$g.TranslateTransform(($lx + 292), ($ly + 386))
$g.RotateTransform(-14)
$stampPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(210, 201, 76, 67), 2)
Draw-Rounded $g $stampPen 0 0 148 42 8
$stampPen.Dispose()
$fStamp = New-Object System.Drawing.Font("Microsoft YaHei UI", 16, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bRed = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(220, 201, 76, 67))
$g.DrawString("不如送外卖", $fStamp, $bRed, 12, 8)
$fStamp.Dispose()
$bRed.Dispose()
$g.Restore($state)

$bMute.Dispose()

# ---------- left text ----------
$fBadge = New-Object System.Drawing.Font("Microsoft YaHei UI", 16, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$badgeFill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(120, 20, 32, 51))
Fill-Rounded $g $badgeFill 96 48 196 38 8
$badgeFill.Dispose()
$badgePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(150, 232, 178, 96), 2)
Draw-Rounded $g $badgePen 96 48 196 38 8
$badgePen.Dispose()
$bGold = New-Object System.Drawing.SolidBrush $gold
$g.DrawString("行业账本 · 02", $fBadge, $bGold, 114, 56)
$fBadge.Dispose()
$bGold.Dispose()

$fKicker = New-Object System.Drawing.Font("Microsoft YaHei UI", 18, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bCyan = New-Object System.Drawing.SolidBrush $cyan
$g.DrawString("小吃摊为什么越来越多", $fKicker, $bCyan, 98, 128)
$fKicker.Dispose()
$bCyan.Dispose()

$goldBar2 = New-Object System.Drawing.SolidBrush $gold
$g.FillRectangle($goldBar2, 96, 186, 140, 5)
$goldBar2.Dispose()

$fTitle = New-Object System.Drawing.Font("Microsoft YaHei UI", 74, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bWhite2 = New-Object System.Drawing.SolidBrush $white
$g.DrawString("摆摊月入两万？", $fTitle, $bWhite2, 92, 214)
$g.DrawString("时薪只有29块", $fTitle, $bWhite2, 92, 306)
$bWhite2.Dispose()
$fTitle.Dispose()

$fSub = New-Object System.Drawing.Font("Microsoft YaHei UI", 28, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bSub = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(235, 201, 191, 174))
$g.DrawString("不是风口，是退路", $fSub, $bSub, 96, 428)
$bSub.Dispose()
$fSub.Dispose()

$fFoot = New-Object System.Drawing.Font("Microsoft YaHei UI", 18, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bFoot = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(190, 143, 163, 186))
$g.DrawString("卖车的比开车的不慌", $fFoot, $bFoot, 98, 508)
$bFoot.Dispose()
$fFoot.Dispose()

# ---------- corner marks ----------
$cm = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(70, 232, 178, 96), 2)
$g.DrawLine($cm, 40, 40, 120, 40)
$g.DrawLine($cm, 40, 40, 40, 120)
$g.DrawLine($cm, ($W - 40), ($H - 40), ($W - 120), ($H - 40))
$g.DrawLine($cm, ($W - 40), ($H - 40), ($W - 40), ($H - 120))
$cm.Dispose()

Add-Vignette $g $W $H
Add-Grain $g $W $H 20261103

$g.Dispose()
$bmp.Save($CoverOut, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $CoverOut)
