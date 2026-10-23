# generate_cover_street.ps1
# 21:9 (1792x768) cover for the "同一条街" article.
# Motif: one row of shopfronts. Left: four identical chain signs. Right: two
#        hand-named shops, gold-lit, bracketed as the ones that never moved.
param(
  [string]$OutPng = "C:\Users\cbs\Desktop\公众号推文\01_精准深耕系列\_配图\街景对比_封面.png",
  [string]$CoverTitle = "同一条街",
  [string]$CoverSub = "为什么有的店越开越大，有的店越开越小",
  [string]$Badge = "行业内幕 · 01"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$W = 1792
$H = 768

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# ---------- background ----------
$top = [System.Drawing.Color]::FromArgb(255, 8, 16, 30)
$bot = [System.Drawing.Color]::FromArgb(255, 24, 37, 60)
$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $top, $bot, 78)
$g.FillRectangle($bg, $rect)
$bg.Dispose()

$white= [System.Drawing.Color]::FromArgb(255, 244, 248, 252)
$cyan = [System.Drawing.Color]::FromArgb(255, 96, 196, 245)
$gold = [System.Drawing.Color]::FromArgb(255, 232, 178, 96)
$mute = [System.Drawing.Color]::FromArgb(210, 162, 186, 212)

# =========================================================
#  right side: the row of shopfronts
# =========================================================
$shopW = 106
$shopH = 248
$gap = 15
$n = 6
$rowW = $n * $shopW + ($n - 1) * $gap
$gx = $W - $rowW - 76
$gy = 292

$fShop  = New-Object System.Drawing.Font ("Microsoft YaHei UI", 19, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fNum   = New-Object System.Drawing.Font ("Microsoft YaHei UI", 14, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fCapL  = New-Object System.Drawing.Font ("Microsoft YaHei UI", 27, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)

$cCenter = New-Object System.Drawing.StringFormat
$cCenter.Alignment = [System.Drawing.StringAlignment]::Center
$cCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

function New-Shop {
  param([int]$X, [int]$Y, [bool]$IsChain, [string]$Name, [string]$Num, [int]$Seed)

  # --- body ---
  $body = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 26, 37, 56))
  $g.FillRectangle($body, $X, $Y, $shopW, $shopH)
  $body.Dispose()
  $bodyPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(150, 70, 92, 122), 2)
  $g.DrawRectangle($bodyPen, $X, $Y, $shopW, $shopH)
  $bodyPen.Dispose()

  # --- signboard ---
  $signY = $Y + 16
  $signH = 46
  if ($IsChain) {
    $sbFill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 12, 62, 92))
    $g.FillRectangle($sbFill, $X + 8, $signY, ($shopW - 16), $signH); $sbFill.Dispose()
    $sbPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 64, 196, 240), 2)
    $g.DrawRectangle($sbPen, $X + 8, $signY, ($shopW - 16), $signH); $sbPen.Dispose()
    # uniform glow = identical signs
    for ($r = 26; $r -gt 0; $r -= 4) {
      $a = [int](16 * [math]::Pow(1 - $r / 26, 2))
      if ($a -le 0) { continue }
      $gl = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($a, 90, 200, 250), 5)
      $g.DrawEllipse($gl, ($X + $shopW / 2 - $r), ($signY + $signH / 2 - $r), (2 * $r), (2 * $r))
      $gl.Dispose()
    }
    $tb = New-Object System.Drawing.SolidBrush ($white)
    $r1 = New-Object System.Drawing.RectangleF([single]($X + 8), [single]$signY, [single]($shopW - 16), [single]$signH)
    $g.DrawString("全国连锁", $fShop, $tb, $r1, $cCenter)
    $tb.Dispose()
  } else {
    $sbFill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 58, 42, 18))
    $g.FillRectangle($sbFill, $X + 8, $signY, ($shopW - 16), $signH); $sbFill.Dispose()
    $sbPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 232, 178, 96), 2)
    $g.DrawRectangle($sbPen, $X + 8, $signY, ($shopW - 16), $signH); $sbPen.Dispose()
    $tb = New-Object System.Drawing.SolidBrush ($gold)
    $r1 = New-Object System.Drawing.RectangleF([single]($X + 8), [single]$signY, [single]($shopW - 16), [single]$signH)
    $g.DrawString($Name, $fShop, $tb, $r1, $cCenter)
    $tb.Dispose()
  }

  # --- awning ---
  $awY = $signY + $signH + 8
  $awC = if ($IsChain) { [System.Drawing.Color]::FromArgb(255, 16, 76, 110) } else { [System.Drawing.Color]::FromArgb(255, 92, 66, 34) }
  $awB = New-Object System.Drawing.SolidBrush $awC
  $g.FillRectangle($awB, ($X + 8), $awY, ($shopW - 16), 16)
  $awB.Dispose()

  # --- glass door ---
  $dY = $awY + 24
  $dH = $Y + $shopH - $dY - 34
  $glass = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle(($X + 12), $dY, ($shopW - 24), $dH)),
    [System.Drawing.Color]::FromArgb(255, 44, 66, 92),
    [System.Drawing.Color]::FromArgb(255, 18, 28, 44),
    90)
  $g.FillRectangle($glass, ($X + 12), $dY, ($shopW - 24), $dH)
  $glass.Dispose()
  $dPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(170, 90, 120, 150), 2)
  $g.DrawRectangle($dPen, ($X + 12), $dY, ($shopW - 24), $dH)
  $dPen.Dispose()

  # --- small plate under the door: shop number / "第 N 家" ---
  $pY = $Y + $shopH - 28
  $pl = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 40, 54, 76))
  $g.FillRectangle($pl, ($X + 12), $pY, ($shopW - 24), 20)
  $pl.Dispose()
  $pb2 = New-Object System.Drawing.SolidBrush $(if ($IsChain) { $cyan } else { $gold })
  $r2 = New-Object System.Drawing.RectangleF([single]($X + 12), [single]$pY, [single]($shopW - 24), [single]20)
  $g.DrawString($Num, $fNum, $pb2, $r2, $cCenter)
  $pb2.Dispose()
}

$chainNames = @(
  @("全国连锁", "第 3 家"),
  @("全国连锁", "第 7 家"),
  @("全国连锁", "第 11 家"),
  @("全国连锁", "第 12 家")
)
$singleNames = @(
  @("老李修车", "三年"),
  @("胖姐包子", "三年")
)

for ($i = 0; $i -lt 4; $i++) {
  $x = $gx + $i * ($shopW + $gap)
  New-Shop -X $x -Y $gy -IsChain $true -Name $chainNames[$i][0] -Num $chainNames[$i][1] -Seed $i
}
$singleX0 = $gx + 4 * ($shopW + $gap)
for ($i = 0; $i -lt 2; $i++) {
  $x = $singleX0 + $i * ($shopW + $gap)
  New-Shop -X $x -Y $gy -IsChain $false -Name $singleNames[$i][0] -Num $singleNames[$i][1] -Seed $i
}

# --- street ground line ---
$roadY = $gy + $shopH + 26
$road = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(140, 88, 116, 150), 2)
$g.DrawLine($road, ($gx - 26), $roadY, ($gx + $rowW + 26), $roadY)
$road.Dispose()
$dash = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(90, 88, 116, 150), 2)
for ($d = $gx - 26; $d -lt ($gx + $rowW + 26); $d += 26) {
  $g.DrawLine($dash, $d, ($roadY + 12), ($d + 14), ($roadY + 12))
}
$dash.Dispose()

# --- caption above the chain block: they keep changing ---
$cabA = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(235, 130, 205, 245))
$g.DrawString("两年，换了两轮", $fCapL, $cabA, ($gx + 2), ($gy - 62))
$cabA.Dispose()

# --- caption under the single block: they never moved ---
$cU = New-Object System.Drawing.RectangleF([single]$singleX0, [single]($roadY + 36), [single](2 * $shopW + $gap), [single]44)
$cabB = New-Object System.Drawing.SolidBrush $gold
$g.DrawString("三年没动", $fCapL, $cabB, $cU, $cCenter)
$cabB.Dispose()

# --- bracket marking the two survivors ---
$bk = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(240, 232, 178, 96), 4)
$bx1 = $singleX0 - 6
$bx2 = $singleX0 + 2 * $shopW + $gap + 6
$by1 = $gy + $shopH + 30
$by2 = $by1 - 26
$g.DrawLine($bk, $bx1, $by1, ($bx1 + 22), $by1)
$g.DrawLine($bk, $bx1, $by1, $bx1, $by2)
$g.DrawLine($bk, $bx2, $by1, ($bx2 - 22), $by1)
$g.DrawLine($bk, $bx2, $by1, $bx2, $by2)
$bk.Dispose()

# ---------- left vignette for text legibility ----------
# fades out past the first shop so no hard edge lands on empty background
$vigW = 1130
$vg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, $vigW, $H)),
  [System.Drawing.Color]::FromArgb(243, 5, 10, 20),
  [System.Drawing.Color]::FromArgb(0, 5, 10, 20),
  0)
$g.FillRectangle($vg, (New-Object System.Drawing.Rectangle(0, 0, $vigW, $H)))
$vg.Dispose()

# soft floor gradient to seat the whole composition
$fRect = New-Object System.Drawing.Rectangle(0, ($H - 190), $W, 190)
$fGrad = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  $fRect,
  [System.Drawing.Color]::FromArgb(0, 5, 10, 20),
  [System.Drawing.Color]::FromArgb(120, 5, 10, 20),
  90)
$g.FillRectangle($fGrad, $fRect)
$fGrad.Dispose()

# ---------- typography ----------
$fTitle = New-Object System.Drawing.Font ("Microsoft YaHei UI", 82, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fBadge = New-Object System.Drawing.Font ("Microsoft YaHei UI", 28, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fSub   = New-Object System.Drawing.Font ("Microsoft YaHei UI", 32, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$bWhite = New-Object System.Drawing.SolidBrush $white
$bCyan  = New-Object System.Drawing.SolidBrush $cyan
$bGold  = New-Object System.Drawing.SolidBrush $gold
$bMute  = New-Object System.Drawing.SolidBrush $mute

$tx = 96

if ($Badge.Length -gt 0) {
  $bs = $g.MeasureString($Badge, $fBadge)
  $pw = [int]$bs.Width + 52
  $ph = 58
  $py = 84
  $pb2 = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(46, 0, 190, 255))
  $g.FillRectangle($pb2, $tx, $py, $pw, $ph)
  $pb2.Dispose()
  $pp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(190, 0, 190, 255), 2)
  $g.DrawRectangle($pp, $tx, $py, $pw, $ph)
  $pp.Dispose()
  $g.DrawString($Badge, $fBadge, $bCyan, ($tx + 26), ($py + 13))
}

# title: wrap manually
$maxW = 700
$ty = 234
$lines = New-Object System.Collections.ArrayList
$cur = ""
foreach ($ch in $CoverTitle.ToCharArray()) {
  $t = $cur + $ch
  if ($g.MeasureString($t, $fTitle).Width -gt $maxW -and $cur.Length -gt 0) {
    [void]$lines.Add($cur); $cur = $ch
  } else { $cur = $t }
}
if ($cur.Length -gt 0) { [void]$lines.Add($cur) }

$lh = 108
for ($i = 0; $i -lt $lines.Count; $i++) {
  $g.DrawString($lines[$i], $fTitle, $bWhite, $tx, ($ty + $i * $lh))
}

$ry = $ty + $lines.Count * $lh - 4
$rp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 232, 178, 96), 4)
$g.DrawLine($rp, $tx, $ry, ($tx + 170), $ry)
$rp.Dispose()

# subtitle wrapped to two lines max
$sMaxW = 640
$slines = New-Object System.Collections.ArrayList
$sc = ""
foreach ($ch in $CoverSub.ToCharArray()) {
  $t = $sc + $ch
  if ($g.MeasureString($t, $fSub).Width -gt $sMaxW -and $sc.Length -gt 0) {
    [void]$slines.Add($sc); $sc = $ch
  } else { $sc = $t }
}
if ($sc.Length -gt 0) { [void]$slines.Add($sc) }
if ($slines.Count -gt 3) {
  $slines[0] = $slines[0] + $slines[1]; $slines.RemoveAt(1)
}
for ($i = 0; $i -lt $slines.Count; $i++) {
  $g.DrawString($slines[$i], $fSub, $bMute, $tx, ($ry + 44 + $i * 44))
}

# ---------- the cover's one-line takeaway, fills the lower-left ----------
$ky0 = $ry + 44 + $slines.Count * 44 + 40

function New-Takeaway {
  param([int]$Y, [System.Drawing.Color]$Accent, [string]$Tag, [string]$Text)
  $barW = 5
  $barH = 58
  $bar = New-Object System.Drawing.SolidBrush $Accent
  $g.FillRectangle($bar, $tx, $Y, $barW, $barH)
  $bar.Dispose()
  $fTag = New-Object System.Drawing.Font ("Microsoft YaHei UI", 20, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $fTxt = New-Object System.Drawing.Font ("Microsoft YaHei UI", 26, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
  $bTag = New-Object System.Drawing.SolidBrush $Accent
  $bTxt = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(228, 226, 234, 244))
  $g.DrawString($Tag, $fTag, $bTag, ($tx + 20), ($Y + 2))
  $g.DrawString($Text, $fTxt, $bTxt, ($tx + 20), ($Y + 26))
  $fTag.Dispose(); $fTxt.Dispose(); $bTag.Dispose(); $bTxt.Dispose()
}

New-Takeaway $ky0 $cyan "连锁的招牌" "统一底色 · 统一字体 · 写「第 12 家」"
New-Takeaway ($ky0 + 78) $gold "单店的招牌" "老板自己起名 · 有一边灯不亮"

# ---------- decorative corner marks ----------
$cm = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(70, 232, 178, 96), 2)
$g.DrawLine($cm, 40, 40, 120, 40)
$g.DrawLine($cm, 40, 40, 40, 120)
$g.DrawLine($cm, ($W - 40), ($H - 40), ($W - 120), ($H - 40))
$g.DrawLine($cm, ($W - 40), ($H - 40), ($W - 40), ($H - 120))
$cm.Dispose()

$bWhite.Dispose(); $bCyan.Dispose(); $bGold.Dispose(); $bMute.Dispose()
$fTitle.Dispose(); $fBadge.Dispose(); $fSub.Dispose(); $fShop.Dispose(); $fNum.Dispose(); $fCapL.Dispose()
$cCenter.Dispose()
$g.Dispose()
$bmp.Save($OutPng, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $OutPng)