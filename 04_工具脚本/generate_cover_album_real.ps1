# generate_cover_album_real.ps1
# 21:9 (1792x768) cover built from a real photo.
# Grades it like an old print, then lays the title over it.
param(
  [string]$BasePng = "C:\Users\cbs\Desktop\公众号推文\04_工具脚本\底图\雪山.jpg",
  [string]$SourceMd = "C:\Users\cbs\Desktop\公众号推文\02_AI主题\15_AI动手手册02_我用AI帮我清了一次手机相册.md",
  [string]$OutPng  = "C:\Users\cbs\Desktop\公众号推文\02_AI主题\_配图\15_清相册_封面.png",
  [string]$Subtitle = "",
  [switch]$NoScrim
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$W = 1792
$H = 768
$rnd = New-Object System.Random 20260410

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# ---------- 1. crop the source to 21:9, anchored slightly high to keep the ridge line ----------
$src = [System.Drawing.Image]::FromFile($BasePng)
$targetRatio = $W / $H
$srcRatio = $src.Width / $src.Height
if ($srcRatio -gt $targetRatio) {
  $cropH = $src.Height
  $cropW = [int]($src.Height * $targetRatio)
  $cropX = [int](($src.Width - $cropW) / 2)
  $cropY = 0
} else {
  $cropW = $src.Width
  $cropH = [int]($src.Width / $targetRatio)
  $cropX = 0
  $cropY = [int](($src.Height - $cropH) * 0.42)
}
$destRect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$srcRect = New-Object System.Drawing.Rectangle($cropX, $cropY, $cropW, $cropH)
$g.DrawImage($src, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
$src.Dispose()

# ---------- 2. grade it: warm it, lift the blacks, cool the sky a touch ----------
# warm wash
$wash = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(40, 206, 158, 92))
$g.FillRectangle($wash, $destRect)
$wash.Dispose()
# faded contrast: milky overlay
$fade = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(30, 96, 84, 72))
$g.FillRectangle($fade, $destRect)
$fade.Dispose()

# ---------- 3. vignette ----------
for ($i = 0; $i -lt 110; $i++) {
  $p = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(3, 26, 18, 12), 14)
  $inset = $i * 5
  $g.DrawRectangle($p, $inset, [int]($inset * 0.55), ($W - 2 * $inset), [int]($H - $inset * 1.1))
  $p.Dispose()
}

# ---------- 4. dust and scratches ----------
for ($i = 0; $i -lt 700; $i++) {
  $x = $rnd.Next(0, $W); $y = $rnd.Next(0, $H)
  $a = $rnd.Next(10, 44)
  $sz = $rnd.Next(1, 3)
  $c = if ($rnd.Next(0, 2) -eq 0) { [System.Drawing.Color]::FromArgb($a, 255, 250, 235) } else { [System.Drawing.Color]::FromArgb($a, 58, 44, 32) }
  $d = New-Object System.Drawing.SolidBrush $c
  $g.FillEllipse($d, $x, $y, $sz, $sz)
  $d.Dispose()
}
for ($i = 0; $i -lt 12; $i++) {
  $x = $rnd.Next(0, $W); $y = $rnd.Next(0, $H)
  $len = $rnd.Next(30, 160); $ang = $rnd.Next(-35, 35)
  $p = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($rnd.Next(16, 36), 255, 248, 232), 1)
  $g.DrawLine($p, $x, $y, ($x + $len * [math]::Cos($ang * [math]::PI / 180)), ($y + $len * [math]::Sin($ang * [math]::PI / 180)))
  $p.Dispose()
}

# ---------- 5. light leak, top right ----------
for ($r = 400; $r -gt 0; $r -= 12) {
  $a = [int](11 * [math]::Pow(1 - $r / 400, 2.4))
  if ($a -le 0) { continue }
  $p = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($a, 255, 216, 152), 12)
  $g.DrawEllipse($p, ($W - 210 - $r), (-150 - $r), (2 * $r), (2 * $r))
  $p.Dispose()
}

# ---------- 6. white print border ----------
$bpen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(232, 238, 232, 220), 20)
$g.DrawRectangle($bpen, 10, 10, ($W - 20), ($H - 20))
$bpen.Dispose()

# ---------- 7. scrim so the title reads ----------
if (-not $NoScrim) {
  $scRect = New-Object System.Drawing.Rectangle(0, 0, 1120, $H)
  $sc = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $scRect,
    [System.Drawing.Color]::FromArgb(246, 8, 10, 16),
    [System.Drawing.Color]::FromArgb(0, 8, 10, 16),
    0)
  $g.FillRectangle($sc, $scRect)
  $sc.Dispose()
  # a touch more darkening under the text block
  $sbRect = New-Object System.Drawing.Rectangle(0, 180, 1120, 460)
  $sb = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $sbRect,
    [System.Drawing.Color]::FromArgb(0, 8, 10, 16),
    [System.Drawing.Color]::FromArgb(120, 8, 10, 16),
    90)
  $g.FillRectangle($sb, $sbRect)
  $sb.Dispose()
}

# ---------- 8. typography ----------
$all = [System.IO.File]::ReadAllText($SourceMd, [System.Text.Encoding]::UTF8)
$h1 = ($all -split "`n" | Where-Object { $_ -match '^#\s' } | Select-Object -First 1)
$h1 = ($h1 -replace '^#\s+', '').Trim()
$parts = $h1 -split [char]0xFF5C
$title = $parts[0].Trim()
$badge = ""
if ($parts.Count -gt 1) { $badge = $parts[1].Trim() }

$fBadge = New-Object System.Drawing.Font ("Consolas", 27, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fTitle = New-Object System.Drawing.Font ("Microsoft YaHei UI", 72, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fSub = New-Object System.Drawing.Font ("Microsoft YaHei UI", 30, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fStamp = New-Object System.Drawing.Font ("Consolas", 44, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fStampS = New-Object System.Drawing.Font ("Microsoft YaHei UI", 22, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 250, 247, 240))
$amber = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 246, 202, 126))
$mute = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(228, 224, 210, 190))

$tx = 104

if ($badge.Length -gt 0) {
  $bs = $g.MeasureString($badge, $fBadge)
  $pw = [int]$bs.Width + 52; $ph = 58; $py = 86
  $pb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(130, 26, 20, 16))
  $g.FillRectangle($pb, $tx, $py, $pw, $ph)
  $pb.Dispose()
  $pp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(190, 246, 202, 126), 2)
  $g.DrawRectangle($pp, $tx, $py, $pw, $ph)
  $pp.Dispose()
  $g.DrawString($badge, $fBadge, $amber, ($tx + 26), ($py + 13))
}

$maxW = 720
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
if ($lines.Count -gt 4) { $lines[0] = $lines[0] + $lines[1]; $lines.RemoveAt(1) }

$lh = 100
for ($i = 0; $i -lt $lines.Count; $i++) {
  $g.DrawString($lines[$i], $fTitle, $white, $tx, ($ty + $i * $lh))
}

$ry = $ty + $lines.Count * $lh - 4
$rp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(225, 246, 202, 126), 3)
$g.DrawLine($rp, $tx, $ry, ($tx + 150), $ry)
$rp.Dispose()

if ($Subtitle.Length -gt 0) {
  $g.DrawString($Subtitle, $fSub, $mute, $tx, ($ry + 36))
}

$white.Dispose(); $amber.Dispose(); $mute.Dispose()
$fBadge.Dispose(); $fTitle.Dispose(); $fSub.Dispose(); $fStamp.Dispose(); $fStampS.Dispose()
$g.Dispose()
$bmp.Save($OutPng, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $OutPng)