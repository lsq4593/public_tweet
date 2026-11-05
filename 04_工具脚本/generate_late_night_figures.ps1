# generate_late_night_figures.ps1
# Cover + body figures for:
#   03_独立文章/04_2026-10-26_1557_我总是深夜做决定，然后第二天假装没发生过.md
# Style: deep navy, gold accent, clean editorial infographic.
# Default: cover only. Use -AllFigures to also render the three body images.

param([switch]$AllFigures)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$OutDir = "C:\Users\cbs\Desktop\公众号推文\03_独立文章\_配图"
$CoverOut = Join-Path $OutDir "深夜做决定_封面.png"
$Body1Out = Join-Path $OutDir "深夜做决定_配图1_在吗.png"
$Body2Out = Join-Path $OutDir "深夜做决定_配图2_第二天早上.png"
$Body3Out = Join-Path $OutDir "深夜做决定_配图3_第三次.png"

$navyTop    = [System.Drawing.Color]::FromArgb(255, 7, 13, 26)
$navyBottom = [System.Drawing.Color]::FromArgb(255, 22, 35, 58)
$panel      = [System.Drawing.Color]::FromArgb(255, 12, 21, 36)
$panel2     = [System.Drawing.Color]::FromArgb(255, 16, 28, 46)
$line       = [System.Drawing.Color]::FromArgb(255, 42, 60, 86)
$white      = [System.Drawing.Color]::FromArgb(255, 245, 242, 234)
$mute       = [System.Drawing.Color]::FromArgb(255, 170, 186, 206)
$cyan       = [System.Drawing.Color]::FromArgb(255, 127, 212, 245)
$gold       = [System.Drawing.Color]::FromArgb(255, 232, 178, 96)
$warmPaper  = [System.Drawing.Color]::FromArgb(255, 240, 232, 218)
$warmPaper2 = [System.Drawing.Color]::FromArgb(255, 214, 194, 166)
$ink        = [System.Drawing.Color]::FromArgb(255, 22, 36, 58)
$inkMute    = [System.Drawing.Color]::FromArgb(255, 91, 106, 124)
$green      = [System.Drawing.Color]::FromArgb(255, 87, 181, 138)
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

function Draw-Centered {
  param($G, [string]$Text, $Font, $Brush, [float]$X, [float]$Y, [float]$W, [float]$H)
  $sf = New-Object System.Drawing.StringFormat
  $sf.Alignment = [System.Drawing.StringAlignment]::Center
  $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
  $rect = New-Object System.Drawing.RectangleF($X, $Y, $W, $H)
  $G.DrawString($Text, $Font, $Brush, $rect, $sf)
  $sf.Dispose()
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

# =========================================================
# COVER 1600 x 686
# =========================================================
$W = 1600
$H = 686
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $navyTop, $navyBottom, 20)
$g.FillRectangle($bg, $rect)
$bg.Dispose()

# soft glow behind the phone
for ($i = 10; $i -ge 1; $i--) {
  $a = [int](4 + (10 - $i) * 2)
  $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($a, 90, 190, 240), 18)
  Draw-Rounded $g $pen (150 - $i * 7) (72 - $i * 7) (210 + $i * 14) (330 + $i * 14) 30
  $pen.Dispose()
}

# ---------- window: morning ----------
$wx = 1120; $wy = 64; $ww = 380; $wh = 300
$shadow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(110, 0, 0, 0))
Fill-Rounded $g $shadow ($wx - 16) ($wy - 16) ($ww + 32) ($wh + 32) 18
$shadow.Dispose()

$skyRect = New-Object System.Drawing.Rectangle($wx, $wy, $ww, $wh)
$sky = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  $skyRect,
  [System.Drawing.Color]::FromArgb(255, 246, 235, 214),
  [System.Drawing.Color]::FromArgb(255, 190, 168, 136),
  90)
Fill-Rounded $g $sky $wx $wy $ww $wh 12
$sky.Dispose()

# city silhouette, clipped inside the window
$winPath = New-RoundedPath $wx $wy $ww $wh 12
$g.SetClip($winPath)
$buildings = @(
  @(1140, 300, 54, 64, 140, 122, 98),
  @(1196, 326, 40, 38, 168, 148, 118),
  @(1238, 276, 66, 88, 122, 106, 86),
  @(1306, 314, 44, 50, 158, 138, 110),
  @(1352, 288, 58, 76, 132, 114, 92),
  @(1412, 332, 38, 32, 172, 152, 122),
  @(1452, 306, 48, 58, 148, 128, 104)
)
foreach ($b in $buildings) {
  $bb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, $b[4], $b[5], $b[6]))
  $g.FillRectangle($bb, [int]$b[0], [int]$b[1], [int]$b[2], [int]$b[3])
  $bb.Dispose()
}
# lit windows on the buildings
$winDot = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(180, 255, 220, 160))
foreach ($b in $buildings) {
  $bx = [int]$b[0]; $by = [int]$b[1]; $bw = [int]$b[2]; $bh = [int]$b[3]
  for ($yy = $by + 12; $yy -lt ($by + $bh - 8); $yy += 16) {
    for ($xx = $bx + 10; $xx -lt ($bx + $bw - 8); $xx += 14) {
      if ((($xx + $yy) % 3) -ne 0) { $g.FillRectangle($winDot, $xx, $yy, 4, 6) }
    }
  }
}
$winDot.Dispose()
$g.ResetClip()
$winPath.Dispose()

# window frame
$framePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 24, 34, 50), 9)
Draw-Rounded $g $framePen $wx $wy $ww $wh 12
$g.DrawLine($framePen, ($wx + [int]($ww / 2)), $wy, ($wx + [int]($ww / 2)), ($wy + $wh))
$g.DrawLine($framePen, $wx, ($wy + [int]($wh * 0.44)), ($wx + $ww), ($wy + [int]($wh * 0.44)))
$framePen.Dispose()

# sill + cup
$sill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 52, 40, 28))
Fill-Rounded $g $sill ($wx - 12) ($wy + $wh) ($ww + 24) 16 4
$sill.Dispose()
$cup = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 246, 238, 224))
Fill-Rounded $g $cup ($wx + 272) ($wy + $wh - 40) 52 40 8
$cup.Dispose()
$cupRim = New-Object System.Drawing.Pen ($gold, 3)
Draw-Rounded $g $cupRim ($wx + 272) ($wy + $wh - 40) 52 40 8
$cupRim.Dispose()
$handle = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 246, 238, 224), 6)
$g.DrawArc($handle, ($wx + 318), ($wy + $wh - 32), 26, 24, 270, 180)
$handle.Dispose()
$steam = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(120, 255, 245, 230), 2)
$g.DrawArc($steam, ($wx + 284), ($wy + $wh - 66), 16, 22, 190, 120)
$g.DrawArc($steam, ($wx + 300), ($wy + $wh - 72), 16, 24, 190, 120)
$steam.Dispose()

$fSmall = New-Object System.Drawing.Font("Microsoft YaHei UI", 18, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bWarm = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(235, 218, 202, 178))
$g.DrawString("第二天 07:20", $fSmall, $bWarm, ($wx + 26), ($wy + $wh + 30))
$bWarm.Dispose()
$fSmall.Dispose()

# ---------- phone: night ----------
$px = 150; $py = 72; $pw = 210; $ph = 330
$phoneBody = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 8, 14, 24))
Fill-Rounded $g $phoneBody $px $py $pw $ph 28
$phoneBody.Dispose()
$phoneBorder = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 58, 78, 106), 3)
Draw-Rounded $g $phoneBorder $px $py $pw $ph 28
$phoneBorder.Dispose()

$screen = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 13, 23, 39))
Fill-Rounded $g $screen ($px + 10) ($py + 16) ($pw - 20) ($ph - 32) 20
$screen.Dispose()

$notch = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 34, 49, 73))
Fill-Rounded $g $notch ($px + 76) ($py + 26) 58 7 3
$notch.Dispose()

$fClock = New-Object System.Drawing.Font("Consolas", 20, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bCyan = New-Object System.Drawing.SolidBrush $cyan
$g.DrawString("02:17", $fClock, $bCyan, ($px + 58), ($py + 48))
$bCyan.Dispose()
$fClock.Dispose()

$fMsg = New-Object System.Drawing.Font("Microsoft YaHei UI", 13, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fMsgS = New-Object System.Drawing.Font("Microsoft YaHei UI", 11, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$bubbleGray = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 28, 42, 64))
Fill-Rounded $g $bubbleGray ($px + 22) ($py + 96) 122 34 16
$bubbleGray.Dispose()
$bMsgMute = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 169, 184, 204))
$g.DrawString("最近怎么样", $fMsg, $bMsgMute, ($px + 34), ($py + 105))
$bMsgMute.Dispose()

$bSystem = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(180, 110, 127, 150))
$g.DrawString("3 个月没有回复", $fMsgS, $bSystem, ($px + 62), ($py + 146))
$bSystem.Dispose()

$bubbleCyan = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 30, 92, 120))
Fill-Rounded $g $bubbleCyan ($px + 96) ($py + 178) 88 32 16
$bubbleCyan.Dispose()
$bMsgWhite = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 234, 247, 255))
$g.DrawString("在吗", $fMsg, $bMsgWhite, ($px + 124), ($py + 186))
$bMsgWhite.Dispose()

$bSystem2 = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(180, 110, 127, 150))
$g.DrawString("你撤回了一条消息", $fMsgS, $bSystem2, ($px + 50), ($py + 226))
$bSystem2.Dispose()

$inputFill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 18, 30, 48))
Fill-Rounded $g $inputFill ($px + 14) ($py + 260) ($pw - 28) 48 12
$inputFill.Dispose()
$inputPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 39, 58, 84), 2)
Draw-Rounded $g $inputPen ($px + 14) ($py + 260) ($pw - 28) 48 12
$inputPen.Dispose()
$bInputText = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 143, 163, 186))
$g.DrawString("那五千块…", $fMsgS, $bInputText, ($px + 26), ($py + 277))
$bInputText.Dispose()
$cursor = New-Object System.Drawing.Pen ($cyan, 2)
$g.DrawLine($cursor, ($px + 102), ($py + 272), ($px + 102), ($py + 296))
$cursor.Dispose()

$fMsg.Dispose(); $fMsgS.Dispose()

# ---------- dashed arrow: one night ----------
$arrowPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(150, 232, 178, 96), 2)
$arrowPen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
$g.DrawLine($arrowPen, ($px + $pw + 34), 238, ($wx - 34), 238)
$arrowPen.Dispose()
$arrowHead = New-Object System.Drawing.SolidBrush $gold
$g.FillPolygon($arrowHead, @(
  (New-Object System.Drawing.Point(($wx - 34), 238)),
  (New-Object System.Drawing.Point(($wx - 54), 229)),
  (New-Object System.Drawing.Point(($wx - 54), 247))
))
$arrowHead.Dispose()
$fNight = New-Object System.Drawing.Font("Microsoft YaHei UI", 16, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bGold = New-Object System.Drawing.SolidBrush $gold
$bArrowBg = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(220, 7, 13, 26))
Fill-Rounded $g $bArrowBg 560 216 76 44 10
$bArrowBg.Dispose()
$g.DrawString("一夜", $fNight, $bGold, 580, 225)
$fNight.Dispose()
$bGold.Dispose()

# ---------- badge ----------
$fBadge = New-Object System.Drawing.Font("Microsoft YaHei UI", 16, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bGoldLine = New-Object System.Drawing.SolidBrush $gold
$badgeFill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(120, 20, 32, 51))
Fill-Rounded $g $badgeFill 96 48 176 38 8
$badgeFill.Dispose()
$badgePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(150, 232, 178, 96), 2)
Draw-Rounded $g $badgePen 96 48 176 38 8
$badgePen.Dispose()
$g.DrawString("独立文章 · 04", $fBadge, $bGoldLine, 114, 57)
$fBadge.Dispose()
$bGoldLine.Dispose()

# ---------- title ----------
$goldBar = New-Object System.Drawing.SolidBrush $gold
$g.FillRectangle($goldBar, 96, 396, 150, 5)
$goldBar.Dispose()

$fTitle = New-Object System.Drawing.Font("Microsoft YaHei UI", 68, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bWhite = New-Object System.Drawing.SolidBrush $white
$g.DrawString("我总是深夜做决定", $fTitle, $bWhite, 94, 416)
$g.DrawString("然后第二天假装没发生过", $fTitle, $bWhite, 94, 500)
$bWhite.Dispose()

$fSub = New-Object System.Drawing.Font("Microsoft YaHei UI", 26, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bMute = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(235, 201, 191, 174))
$g.DrawString("深夜适合看见问题，不适合解决问题", $fSub, $bMute, 96, 610)
$bMute.Dispose()
$fTitle.Dispose()
$fSub.Dispose()

# ---------- corner marks ----------
$cm = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(70, 232, 178, 96), 2)
$g.DrawLine($cm, 40, 40, 120, 40)
$g.DrawLine($cm, 40, 40, 40, 120)
$g.DrawLine($cm, ($W - 40), ($H - 40), ($W - 120), ($H - 40))
$g.DrawLine($cm, ($W - 40), ($H - 40), ($W - 40), ($H - 120))
$cm.Dispose()

Add-Vignette $g $W $H
Add-Grain $g $W $H 20261026
$g.Dispose()
$bmp.Save($CoverOut, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $CoverOut)

if ($AllFigures) {

# =========================================================
# BODY 1: 在吗 (1200 x 750)
# =========================================================
$W = 1200; $H = 750
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $navyTop, $navyBottom, 25)
$g.FillRectangle($bg, $rect)
$bg.Dispose()

$fBadge = New-Object System.Drawing.Font("Microsoft YaHei UI", 14, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bGold = New-Object System.Drawing.SolidBrush $gold
$g.DrawString("独立文章 · 04", $fBadge, $bGold, 80, 52)
$fBadge.Dispose()
$bGold.Dispose()

$fTitle = New-Object System.Drawing.Font("Microsoft YaHei UI", 54, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bWhite = New-Object System.Drawing.SolidBrush $white
$g.DrawString("在吗", $fTitle, $bWhite, 78, 78)
$fTitle.Dispose()
$bWhite.Dispose()

$fSub = New-Object System.Drawing.Font("Microsoft YaHei UI", 18, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bMute = New-Object System.Drawing.SolidBrush $mute
$g.DrawString("打了三行，删了两行，最后撤回", $fSub, $bMute, 80, 148)
$fSub.Dispose()
$bMute.Dispose()

$div = New-Object System.Drawing.Pen $line, 2
$g.DrawLine($div, 80, 192, 1120, 192)
$div.Dispose()

# transfer card
$cardFill = New-Object System.Drawing.SolidBrush $panel
Fill-Rounded $g $cardFill 80 232 390 220 16
$cardFill.Dispose()
$cardPen = New-Object System.Drawing.Pen $line, 2
Draw-Rounded $g $cardPen 80 232 390 220 16
$cardPen.Dispose()

$fLabel = New-Object System.Drawing.Font("Microsoft YaHei UI", 15, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bMute2 = New-Object System.Drawing.SolidBrush $mute
$g.DrawString("转账给 阿亮", $fLabel, $bMute2, 108, 258)
$fLabel.Dispose()

$fAmount = New-Object System.Drawing.Font("Microsoft YaHei UI", 40, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bGold = New-Object System.Drawing.SolidBrush $gold
$g.DrawString("¥5,000.00", $fAmount, $bGold, 108, 298)
$fAmount.Dispose()
$bGold.Dispose()

$fNote = New-Object System.Drawing.Font("Microsoft YaHei UI", 15, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bMute3 = New-Object System.Drawing.SolidBrush $mute
$g.DrawString("应急 · 半年前 · 说好一个月", $fNote, $bMute3, 108, 366)
$fNote.Dispose()
$bMute3.Dispose()

$stampPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(210, 201, 76, 67), 2)
Draw-Rounded $g $stampPen 354 258 84 34 8
$stampPen.Dispose()
$fStamp = New-Object System.Drawing.Font("Microsoft YaHei UI", 15, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bRed = New-Object System.Drawing.SolidBrush $red
$g.DrawString("未还", $fStamp, $bRed, 372, 266)
$fStamp.Dispose()
$bRed.Dispose()

$bMute2.Dispose()

# chat panel
$chatFill = New-Object System.Drawing.SolidBrush $panel2
Fill-Rounded $g $chatFill 540 232 580 420 18
$chatFill.Dispose()
$chatPen = New-Object System.Drawing.Pen $line, 2
Draw-Rounded $g $chatPen 540 232 580 420 18
$chatPen.Dispose()

$fName = New-Object System.Drawing.Font("Microsoft YaHei UI", 19, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bWhite = New-Object System.Drawing.SolidBrush $white
$g.DrawString("阿亮", $fName, $bWhite, 570, 256)
$fName.Dispose()

$fTime = New-Object System.Drawing.Font("Microsoft YaHei UI", 13, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bMute = New-Object System.Drawing.SolidBrush $mute
$g.DrawString("昨晚 02:17", $fTime, $bMute, 1000, 262)
$fTime.Dispose()

$div2 = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(180, 42, 60, 86), 2)
$g.DrawLine($div2, 560, 300, 1100, 300)
$div2.Dispose()

$bubbleGray = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 28, 42, 64))
Fill-Rounded $g $bubbleGray 570 326 190 44 16
$bubbleGray.Dispose()
$fMsg = New-Object System.Drawing.Font("Microsoft YaHei UI", 16, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bMsg = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 188, 202, 220))
$g.DrawString("最近怎么样", $fMsg, $bMsg, 590, 336)
$bMsg.Dispose()

$fSys = New-Object System.Drawing.Font("Microsoft YaHei UI", 13, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bSys = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(180, 120, 138, 162))
Draw-Centered $g "3 个月没有回复" $fSys $bSys 560 398 560 24
$bSys.Dispose()

$bubbleCyan = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 30, 92, 120))
Fill-Rounded $g $bubbleCyan 880 440 190 44 16
$bubbleCyan.Dispose()
$bMsgWhite = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 234, 247, 255))
$g.DrawString("在吗", $fMsg, $bMsgWhite, 950, 450)
$bMsgWhite.Dispose()

$bSys2 = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(180, 120, 138, 162))
Draw-Centered $g "你撤回了一条消息" $fSys $bSys2 560 508 560 24
$bSys2.Dispose()

$inputFill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 18, 30, 48))
Fill-Rounded $g $inputFill 564 566 532 64 12
$inputFill.Dispose()
$inputPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 39, 58, 84), 2)
Draw-Rounded $g $inputPen 564 566 532 64 12
$inputPen.Dispose()
$bInput = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 143, 163, 186))
$g.DrawString("阿亮，那五千块你看什么时候方便", $fSys, $bInput, 584, 588)
$bInput.Dispose()
$cursor = New-Object System.Drawing.Pen ($cyan, 2)
$g.DrawLine($cursor, 874, 584, 874, 610)
$cursor.Dispose()

$fMsg.Dispose(); $fSys.Dispose()

$fCap = New-Object System.Drawing.Font("Microsoft YaHei UI", 20, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bCap = New-Object System.Drawing.SolidBrush $gold
$g.DrawString("夜里算的是账", $fCap, $bCap, 80, 690)
$fCap.Dispose()
$bCap.Dispose()

Add-Vignette $g $W $H
Add-Grain $g $W $H 20261027
$g.Dispose()
$bmp.Save($Body1Out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $Body1Out)

# =========================================================
# BODY 2: 第二天早上 (1200 x 750)
# =========================================================
$W = 1200; $H = 750
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $warmPaper, $warmPaper2, 20)
$g.FillRectangle($bg, $rect)
$bg.Dispose()

$fBadge = New-Object System.Drawing.Font("Microsoft YaHei UI", 14, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bGold = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 160, 112, 48))
$g.DrawString("独立文章 · 04", $fBadge, $bGold, 80, 52)
$fBadge.Dispose()
$bGold.Dispose()

$fTitle = New-Object System.Drawing.Font("Microsoft YaHei UI", 54, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bInk = New-Object System.Drawing.SolidBrush $ink
$g.DrawString("第二天早上", $fTitle, $bInk, 78, 78)
$fTitle.Dispose()
$bInk.Dispose()

$fSub = New-Object System.Drawing.Font("Microsoft YaHei UI", 18, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bInkMute = New-Object System.Drawing.SolidBrush $inkMute
$g.DrawString("那五千块，我又没说", $fSub, $bInkMute, 80, 148)
$fSub.Dispose()
$bInkMute.Dispose()

$div = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 185, 168, 142), 2)
$g.DrawLine($div, 80, 192, 1120, 192)
$div.Dispose()

# clock
$fClock = New-Object System.Drawing.Font("Microsoft YaHei UI", 72, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bInk = New-Object System.Drawing.SolidBrush $ink
$g.DrawString("07:20", $fClock, $bInk, 80, 250)
$fClock.Dispose()
$bInk.Dispose()

$fNote = New-Object System.Drawing.Font("Microsoft YaHei UI", 16, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bInkMute = New-Object System.Drawing.SolidBrush $inkMute
$g.DrawString("闹钟响了两遍", $fNote, $bInkMute, 84, 348)
$fNote.Dispose()
$bInkMute.Dispose()

# cup and bun
$plate = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 250, 245, 234))
$g.FillEllipse($plate, 84, 470, 180, 62)
$plate.Dispose()
$platePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 185, 168, 142), 2)
$g.DrawEllipse($platePen, 84, 470, 180, 62)
$platePen.Dispose()
$bun = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 230, 204, 160))
$g.FillEllipse($bun, 132, 448, 84, 58)
$bun.Dispose()
$bunPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 198, 164, 112), 2)
$g.DrawEllipse($bunPen, 132, 448, 84, 58)
$bunPen.Dispose()

$cupFill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 250, 245, 234))
Fill-Rounded $g $cupFill 84 560 74 58 8
$cupFill.Dispose()
$cupPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 185, 168, 142), 2)
Draw-Rounded $g $cupPen 84 560 74 58 8
$cupPen.Dispose()
$handle = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 185, 168, 142), 5)
$g.DrawArc($handle, 152, 574, 30, 28, 270, 180)
$handle.Dispose()

# group chat panel
$panelFill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(235, 252, 248, 240))
Fill-Rounded $g $panelFill 540 232 580 460 18
$panelFill.Dispose()
$panelPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 201, 185, 158), 2)
Draw-Rounded $g $panelPen 540 232 580 460 18
$panelPen.Dispose()

$fName = New-Object System.Drawing.Font("Microsoft YaHei UI", 18, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bInk = New-Object System.Drawing.SolidBrush $ink
$g.DrawString("老同学群（12）", $fName, $bInk, 570, 256)
$fName.Dispose()
$bInk.Dispose()

$div2 = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 201, 185, 158), 2)
$g.DrawLine($div2, 560, 300, 1100, 300)
$div2.Dispose()

# red envelope
$envFill = New-Object System.Drawing.SolidBrush $red
Fill-Rounded $g $envFill 570 326 520 96 14
$envFill.Dispose()
$fEnvSmall = New-Object System.Drawing.Font("Microsoft YaHei UI", 13, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bCream = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 240, 220))
$g.DrawString("阿亮 发出的红包", $fEnvSmall, $bCream, 594, 342)
$fEnvSmall.Dispose()
$fEnv = New-Object System.Drawing.Font("Microsoft YaHei UI", 22, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString("恭喜发财，大吉大利", $fEnv, $bCream, 594, 370)
$fEnv.Dispose()
$bCream.Dispose()

$fReply = New-Object System.Drawing.Font("Microsoft YaHei UI", 16, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bubbleReply = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 220, 239, 231))
Fill-Rounded $g $bubbleReply 880 446 210 42 16
$bubbleReply.Dispose()
$bGreen = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 28, 107, 74))
$g.DrawString("谢谢老板", $fReply, $bGreen, 930, 455)
$bGreen.Dispose()

$fSmall = New-Object System.Drawing.Font("Microsoft YaHei UI", 13, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bInkMute = New-Object System.Drawing.SolidBrush $inkMute
$g.DrawString("我抢了 3.20", $fSmall, $bInkMute, 882, 496)
$fSmall.Dispose()

# ghost transfer card
$ghostFill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(90, 255, 248, 235))
Fill-Rounded $g $ghostFill 570 540 520 110 14
$ghostFill.Dispose()
$ghostPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(160, 160, 112, 48), 2)
$ghostPen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
Draw-Rounded $g $ghostPen 570 540 520 110 14
$ghostPen.Dispose()
$fGhostAmt = New-Object System.Drawing.Font("Microsoft YaHei UI", 26, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bGhost = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(190, 160, 112, 48))
$g.DrawString("¥5,000.00  未还", $fGhostAmt, $bGhost, 594, 562)
$fGhostAmt.Dispose()
$fGhostNote = New-Object System.Drawing.Font("Microsoft YaHei UI", 14, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString("半年前 · 应急", $fGhostNote, $bGhost, 594, 610)
$fGhostNote.Dispose()
$bGhost.Dispose()

$fReply.Dispose()
$bInkMute.Dispose()

$fCap = New-Object System.Drawing.Font("Microsoft YaHei UI", 20, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bCap = New-Object System.Drawing.SolidBrush $ink
$g.DrawString("白天算的是关系", $fCap, $bCap, 80, 690)
$fCap.Dispose()
$bCap.Dispose()

Add-Vignette $g $W $H
Add-Grain $g $W $H 20261028
$g.Dispose()
$bmp.Save($Body2Out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $Body2Out)

# =========================================================
# BODY 3: 第三次 (1200 x 750)
# =========================================================
$W = 1200; $H = 750
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $navyTop, $navyBottom, 25)
$g.FillRectangle($bg, $rect)
$bg.Dispose()

$fBadge = New-Object System.Drawing.Font("Microsoft YaHei UI", 14, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bGold = New-Object System.Drawing.SolidBrush $gold
$g.DrawString("独立文章 · 04", $fBadge, $bGold, 80, 52)
$fBadge.Dispose()
$bGold.Dispose()

$fTitle = New-Object System.Drawing.Font("Microsoft YaHei UI", 54, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bWhite = New-Object System.Drawing.SolidBrush $white
$g.DrawString("第三次", $fTitle, $bWhite, 78, 78)
$fTitle.Dispose()
$bWhite.Dispose()

$fSub = New-Object System.Drawing.Font("Microsoft YaHei UI", 18, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bMute = New-Object System.Drawing.SolidBrush $mute
$g.DrawString("这次我没有在深夜回他", $fSub, $bMute, 80, 148)
$fSub.Dispose()
$bMute.Dispose()

$div = New-Object System.Drawing.Pen $line, 2
$g.DrawLine($div, 80, 192, 1120, 192)
$div.Dispose()

# call card
$cardFill = New-Object System.Drawing.SolidBrush $panel
Fill-Rounded $g $cardFill 80 232 410 230 16
$cardFill.Dispose()
$cardPen = New-Object System.Drawing.Pen $line, 2
Draw-Rounded $g $cardPen 80 232 410 230 16
$cardPen.Dispose()

$fName = New-Object System.Drawing.Font("Microsoft YaHei UI", 24, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bWhite = New-Object System.Drawing.SolidBrush $white
$g.DrawString("阿亮", $fName, $bWhite, 110, 258)
$fName.Dispose()

$fCall = New-Object System.Drawing.Font("Microsoft YaHei UI", 17, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bCyan = New-Object System.Drawing.SolidBrush $cyan
$g.DrawString("通话中 02:14", $fCall, $bCyan, 110, 302)
$fCall.Dispose()
$bCyan.Dispose()

# call button
$callCircle = New-Object System.Drawing.SolidBrush $green
$g.FillEllipse($callCircle, 110, 352, 58, 58)
$callCircle.Dispose()
$phonePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 245, 255, 250), 5)
$g.DrawArc($phonePen, 128, 370, 22, 22, 200, 160)
$phonePen.Dispose()

$fNote = New-Object System.Drawing.Font("Microsoft YaHei UI", 14, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bMute = New-Object System.Drawing.SolidBrush $mute
$g.DrawString("第二天上午 10:06", $fNote, $bMute, 190, 370)
$fNote.Dispose()
$bMute.Dispose()

# timeline
$timeline = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 42, 60, 86), 3)
$g.DrawLine($timeline, 560, 250, 560, 600)
$timeline.Dispose()

function New-TimelineCard {
  param($G, [float]$X, [float]$Y, [string]$Title, [string]$Tag, [string]$Note, [System.Drawing.Color]$TagColor)
  $fill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 16, 28, 46))
  Fill-Rounded $G $fill $X $Y 500 86 14
  $fill.Dispose()
  $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 42, 60, 86), 2)
  Draw-Rounded $G $pen $X $Y 500 86 14
  $pen.Dispose()
  $fT = New-Object System.Drawing.Font("Microsoft YaHei UI", 19, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $bT = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 232, 238, 246))
  $G.DrawString($Title, $fT, $bT, ($X + 22), ($Y + 18))
  $fT.Dispose(); $bT.Dispose()
  $fTag = New-Object System.Drawing.Font("Microsoft YaHei UI", 14, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $bTag = New-Object System.Drawing.SolidBrush $TagColor
  $G.DrawString($Tag, $fTag, $bTag, ($X + 330), ($Y + 22))
  $fTag.Dispose(); $bTag.Dispose()
  $fN = New-Object System.Drawing.Font("Microsoft YaHei UI", 13, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
  $bN = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 143, 163, 186))
  $G.DrawString($Note, $fN, $bN, ($X + 22), ($Y + 54))
  $fN.Dispose(); $bN.Dispose()
}

$dot1 = New-Object System.Drawing.SolidBrush $green
$g.FillEllipse($dot1, 548, 280, 24, 24)
$dot1.Dispose()
New-TimelineCard $g 590 250 "转账 ¥3,000.00" "已到账" "两天后" $green

$dot2 = New-Object System.Drawing.SolidBrush $green
$g.FillEllipse($dot2, 548, 404, 24, 24)
$dot2.Dispose()
New-TimelineCard $g 590 374 "转账 ¥2,000.00" "已到账" "下个月" $green

$dot3 = New-Object System.Drawing.SolidBrush $red
$g.FillEllipse($dot3, 548, 528, 24, 24)
$dot3.Dispose()
New-TimelineCard $g 590 498 "对方已不是你的好友" "删除" "剩下的两千，换了一个答案" $red

$fCap = New-Object System.Drawing.Font("Microsoft YaHei UI", 18, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bCap = New-Object System.Drawing.SolidBrush $gold
$g.DrawString("有些话，过了一夜还想说，才值得说", $fCap, $bCap, 80, 690)
$fCap.Dispose()
$bCap.Dispose()

Add-Vignette $g $W $H
Add-Grain $g $W $H 20261029
$g.Dispose()
$bmp.Save($Body3Out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $Body3Out)

}
