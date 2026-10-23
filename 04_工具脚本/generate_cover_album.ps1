# generate_cover_album.ps1
# 21:9 (1792x768) cover for the phone-album article.
# Motif: a grid of photo thumbnails, most blanked out, one left in colour.
param(
  [string]$SourceMd = "C:\Users\cbs\Desktop\公众号推文\02_AI主题\15_AI动手手册02_我用AI帮我清了一次手机相册.md",
  [string]$OutPng  = "C:\Users\cbs\Desktop\公众号推文\02_AI主题\_配图\15_清相册_封面.png",
  [string]$Subtitle = ""
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$W = 1792
$H = 768

$all = [System.IO.File]::ReadAllText($SourceMd, [System.Text.Encoding]::UTF8)
$h1 = ($all -split "`n" | Where-Object { $_ -match '^#\s' } | Select-Object -First 1)
$h1 = ($h1 -replace '^#\s+', '').Trim()
$parts = $h1 -split [char]0xFF5C
$title = $parts[0].Trim()
$badge = ""
if ($parts.Count -gt 1) { $badge = $parts[1].Trim() }

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# ---------- background ----------
$top = [System.Drawing.Color]::FromArgb(255, 8, 16, 30)
$bot = [System.Drawing.Color]::FromArgb(255, 26, 40, 64)
$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $top, $bot, 75)
$g.FillRectangle($bg, $rect)
$bg.Dispose()

# ---------- photo grid on the right ----------
$cols = 5
$rows = 4
$tileW = 118
$tileH = 118
$gap = 12
$gridW = $cols * $tileW + ($cols - 1) * $gap
$gridH = $rows * $tileH + ($rows - 1) * $gap
$gx = $W - $gridW - 84
$gy = ($H - $gridH) / 2 + 34

# soft glow behind the grid
for ($r = 300; $r -gt 0; $r -= 8) {
  $a = [int](14 * [math]::Pow(1 - $r / 300, 2))
  if ($a -le 0) { continue }
  $p = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($a, 110, 180, 255), 8)
  $g.DrawEllipse($p, ($gx + $gridW / 2 - $r), ($gy + $gridH / 2 - $r), (2 * $r), (2 * $r))
  $p.Dispose()
}

# the one thumbnail we keep, in colour
$keepCol = 2
$keepRow = 1

function New-Photo([int]$x, [int]$y, [int]$w, [int]$h, [bool]$isKeep) {
  if ($isKeep) {
    # kept photo: warm light, a soft horizon glow and a small figure silhouette
    $pb = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
      (New-Object System.Drawing.Rectangle($x, $y, $w, $h)),
      [System.Drawing.Color]::FromArgb(255, 244, 198, 120),
      [System.Drawing.Color]::FromArgb(255, 186, 116, 92),
      90)
    $g.FillRectangle($pb, $x, $y, $w, $h)
    $pb.Dispose()
    # sun
    $sb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(120, 255, 250, 230))
    $g.FillEllipse($sb, ($x + $w * 0.58), ($y + $h * 0.2), 34, 34)
    $sb.Dispose()
    # two figures, small, looking out
    $fb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(215, 42, 34, 38))
    $g.FillEllipse($fb, ($x + $w * 0.24), ($y + $h * 0.52), 13, 13)
    $g.FillRectangle($fb, ($x + $w * 0.24 - 5), ($y + $h * 0.52 + 12), 23, 30)
    $g.FillEllipse($fb, ($x + $w * 0.40), ($y + $h * 0.55), 11, 11)
    $g.FillRectangle($fb, ($x + $w * 0.40 - 4), ($y + $h * 0.55 + 10), 19, 26)
    $fb.Dispose()
    # bright frame marks it as the one that stays
    $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 255, 214, 140), 4)
    $g.DrawRectangle($pen, ($x - 2), ($y - 2), ($w + 4), ($h + 4))
    $pen.Dispose()
  } else {
    # blanked-out photo: flat, cold, empty
    $pb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 30, 40, 58))
    $g.FillRectangle($pb, $x, $y, $w, $h)
    $pb.Dispose()
    $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(70, 120, 155, 200), 2)
    $g.DrawRectangle($pen, $x, $y, $w, $h)
    $pen.Dispose()
    # a faint diagonal = "no longer here"
    $lp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(38, 150, 185, 225), 1)
    for ($k = -$h; $k -lt $w; $k += 14) {
      $g.DrawLine($lp, ($x + $k), ($y + $h), ($x + $k + $h), $y)
    }
    $lp.Dispose()
  }
}

for ($r = 0; $r -lt $rows; $r++) {
  for ($c = 0; $c -lt $cols; $c++) {
    $x = $gx + $c * ($tileW + $gap)
    $y = $gy + $r * ($tileH + $gap)
    New-Photo $x $y $tileW $tileH (($c -eq $keepCol) -and ($r -eq $keepRow))
  }
}

# bracket showing "one left"
$bk = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(230, 232, 178, 92), 4)
$kx = $gx + $keepCol * ($tileW + $gap) - 12
$ky = $gy + $keepRow * ($tileH + $gap) - 12
$kw = $tileW + 24
$kh = $tileH + 24
$bl = 22
$g.DrawLine($bk, $kx - 2, $ky, $kx + $bl, $ky)
$g.DrawLine($bk, $kx - 2, $ky, $kx - 2, $ky + $bl)
$g.DrawLine($bk, $kx + $kw - $bl, $ky, $kx + $kw + 2, $ky)
$g.DrawLine($bk, $kx + $kw + 2, $ky, $kx + $kw + 2, $ky + $bl)
$g.DrawLine($bk, $kx - 2, $ky + $kh, $kx + $bl, $ky + $kh)
$g.DrawLine($bk, $kx - 2, $ky + $kh, $kx - 2, $ky + $kh - $bl)
$g.DrawLine($bk, $kx + $kw - $bl, $ky + $kh, $kx + $kw + 2, $ky + $kh)
$g.DrawLine($bk, $kx + $kw + 2, $ky + $kh, $kx + $kw + 2, $ky + $kh - $bl)
$bk.Dispose()

# ---------- left vignette for text legibility ----------
$vg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, 1000, $H)),
  [System.Drawing.Color]::FromArgb(240, 5, 10, 20),
  [System.Drawing.Color]::FromArgb(0, 5, 10, 20),
  0)
$g.FillRectangle($vg, (New-Object System.Drawing.Rectangle(0, 0, 1000, $H)))
$vg.Dispose()

# ---------- typography ----------
$fTitle = New-Object System.Drawing.Font ("Microsoft YaHei UI", 74, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fBadge = New-Object System.Drawing.Font ("Microsoft YaHei UI", 30, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fSub = New-Object System.Drawing.Font ("Microsoft YaHei UI", 31, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 245, 248, 252))
$cyan = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 126, 200, 255))
$gold = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 235, 182, 96))
$mute = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(215, 168, 190, 214))

$tx = 100

if ($badge.Length -gt 0) {
  $bs = $g.MeasureString($badge, $fBadge)
  $pw = [int]$bs.Width + 56
  $ph = 62
  $py = 88
  $pb2 = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(44, 0, 195, 255))
  $g.FillRectangle($pb2, $tx, $py, $pw, $ph)
  $pb2.Dispose()
  $pp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(185, 0, 195, 255), 2)
  $g.DrawRectangle($pp, $tx, $py, $pw, $ph)
  $pp.Dispose()
  $g.DrawString($badge, $fBadge, $cyan, ($tx + 28), ($py + 14))
}

$maxW = 760
$ty = 236
$lines = New-Object System.Collections.ArrayList
$cur = ""
foreach ($ch in $title.ToCharArray()) {
  $t = $cur + $ch
  if ($g.MeasureString($t, $fTitle).Width -gt $maxW -and $cur.Length -gt 0) {
    [void]$lines.Add($cur); $cur = $ch
  } else { $cur = $t }
}
if ($cur.Length -gt 0) { [void]$lines.Add($cur) }
if ($lines.Count -gt 3) {
  $merged = $lines[0] + $lines[1]
  $lines[0] = $merged; $lines.RemoveAt(1)
}

$lh = 104
for ($i = 0; $i -lt $lines.Count; $i++) {
  $g.DrawString($lines[$i], $fTitle, $white, $tx, ($ty + $i * $lh))
}

$ry = $ty + $lines.Count * $lh - 6
$rp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 235, 182, 96), 4)
$g.DrawLine($rp, $tx, $ry, ($tx + 180), $ry)
$rp.Dispose()

if ($Subtitle.Length -gt 0) {
  $g.DrawString($Subtitle, $fSub, $mute, $tx, ($ry + 40))
}

# count marker above the grid, left-aligned with it
$fCount = New-Object System.Drawing.Font ("Microsoft YaHei UI", 42, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString("4312", $fCount, $gold, $gx, ($gy - 76))
$fSm = New-Object System.Drawing.Font ("Microsoft YaHei UI", 24, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString("张，删了 540", $fSm, $mute, ($gx + 112), ($gy - 62))
$fCount.Dispose(); $fSm.Dispose()

$white.Dispose(); $cyan.Dispose(); $gold.Dispose(); $mute.Dispose()
$fTitle.Dispose(); $fBadge.Dispose(); $fSub.Dispose()
$g.Dispose()
$bmp.Save($OutPng, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $OutPng)