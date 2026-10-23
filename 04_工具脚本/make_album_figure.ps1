# make_album_figure.ps1
# Inline figure for 02: the 4312 / 540 / "kept" split, built from real photos.
param(
  [string]$OutPng = "C:\Users\cbs\Desktop\公众号推文\02_AI主题\_配图\15_清相册_配图1_4312与540.png",
  [string]$Photo1 = "C:\Users\cbs\Desktop\公众号推文\04_工具脚本\底图\海边.jpg",
  [string]$Photo2 = "C:\Users\cbs\Desktop\公众号推文\04_工具脚本\底图\雪景.jpg",
  [string]$Photo3 = "C:\Users\cbs\Desktop\公众号推文\04_工具脚本\底图\雪山.jpg"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$W = 1600
$H = 760

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

$bg = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 13, 20, 36))
$g.FillRectangle($bg, 0, 0, $W, $H)
$bg.Dispose()

$white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 240, 246, 252))
$dim   = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 96, 112, 134))
$cyan  = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 126, 200, 255))
$amber = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 236, 182, 96))
$red   = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 214, 96, 88))
$mute  = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(220, 158, 176, 196))

$fBig = New-Object System.Drawing.Font ("Microsoft YaHei UI", 84, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fMid = New-Object System.Drawing.Font ("Microsoft YaHei UI", 30, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fSm  = New-Object System.Drawing.Font ("Microsoft YaHei UI", 22, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fCap = New-Object System.Drawing.Font ("Microsoft YaHei UI", 20, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

# ============ left: the pile ============
$tile = 16
$gap = 4
$cols = 20
$rows = 16
$ox = 70
$oy = 210

# 4312 photos, 540 deleted = 12.5%. Mark exactly 40 tiles of 320 as deleted.
$marked = 40
$i = 0
for ($r = 0; $r -lt $rows; $r++) {
  for ($c = 0; $c -lt $cols; $c++) {
    $x = $ox + $c * ($tile + $gap)
    $y = $oy + $r * ($tile + $gap)
    if ($i -lt $marked) {
      $g.FillRectangle($red, $x, $y, $tile, $tile)
      $p = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(200, 255, 156, 136), 2)
      $g.DrawLine($p, ($x + 3), ($y + 3), ($x + $tile - 3), ($y + $tile - 3))
      $g.DrawLine($p, ($x + $tile - 3), ($y + 3), ($x + 3), ($y + $tile - 3))
      $p.Dispose()
    } else {
      $g.FillRectangle($dim, $x, $y, $tile, $tile)
    }
    $i++
  }
}
# fade the grid out to the right, implying "and thousands more"
$gridW = $cols * ($tile + $gap)
$gridH = $rows * ($tile + $gap)
$fadeRect = New-Object System.Drawing.Rectangle($ox, $oy, $gridW, $gridH)
$fg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  $fadeRect,
  [System.Drawing.Color]::FromArgb(0, 13, 20, 36),
  [System.Drawing.Color]::FromArgb(235, 13, 20, 36),
  0)
$g.FillRectangle($fg, $fadeRect)
$fg.Dispose()

# headline numbers
$g.DrawString("4312", $fBig, $white, 70, 66)
$gw = $g.MeasureString("4312", $fBig).Width
$g.DrawString("张照片", $fMid, $white, (70 + $gw + 14), 122)

$numY = $oy + $gridH + 44
$g.DrawString("删掉 540", $fMid, $red, 70, ($numY + 8))
$pw = $g.MeasureString("删掉 540", $fMid).Width
$g.DrawString("只有 12.5%", $fSm, $mute, (70 + $pw + 24), ($numY + 14))

$g.DrawString("剩下 3772 张，我一张都没删", $fSm, $mute, 70, ($numY + 52))

# ============ right: the ones that stayed ============
$px = 1000
$pw2 = 170
$ph = 190
$pgap = 22
$py = 250
$photos = @($Photo1, $Photo2, $Photo3)
$caps = @("2019 . 08", "2021 . 03", "2023 . 11")

$g.DrawString("留下来的，是这些", $fSm, $amber, $px, ($py - 46))

for ($k = 0; $k -lt 3; $k++) {
  $x = $px + $k * ($pw2 + $pgap)
  if (Test-Path -LiteralPath $photos[$k]) {
    $im = [System.Drawing.Image]::FromFile($photos[$k])
    $dst = New-Object System.Drawing.Rectangle($x, $py, $pw2, $ph)
    $imRatio = $im.Width / $im.Height
    $dstRatio = $pw2 / $ph
    if ($imRatio -gt $dstRatio) {
      $cw = [int]($im.Height * $dstRatio)
      $sr = New-Object System.Drawing.Rectangle([int](($im.Width - $cw) / 2), 0, $cw, $im.Height)
    } else {
      $ch = [int]($im.Width / $dstRatio)
      $sr = New-Object System.Drawing.Rectangle(0, [int](($im.Height - $ch) * 0.35), $im.Width, $ch)
    }
    $g.DrawImage($im, $dst, $sr, [System.Drawing.GraphicsUnit]::Pixel)
    $im.Dispose()
  }
  $fr = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(240, 236, 182, 96), 3)
  $g.DrawRectangle($fr, $x, $py, $pw2, $ph)
  $fr.Dispose()
  $g.DrawString($caps[$k], $fCap, $amber, $x, ($py + $ph + 12))
}

# a single clean connector from the pile to the kept photos
$ar = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(130, 236, 182, 96), 3)
$ax = 880; $ay = 330
$g.DrawLine($ar, $ax, $ay, ($ax + 84), ($ay - 40))
$g.DrawPolygon($ar, @(
  (New-Object System.Drawing.Point -ArgumentList ($ax + 84), ($ay - 40)),
  (New-Object System.Drawing.Point -ArgumentList ($ax + 70), ($ay - 36)),
  (New-Object System.Drawing.Point -ArgumentList ($ax + 80), ($ay - 26))))
$ar.Dispose()

$white.Dispose(); $dim.Dispose(); $cyan.Dispose(); $amber.Dispose(); $red.Dispose(); $mute.Dispose()
$fBig.Dispose(); $fMid.Dispose(); $fSm.Dispose(); $fCap.Dispose()
$g.Dispose()
$bmp.Save($OutPng, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $OutPng)