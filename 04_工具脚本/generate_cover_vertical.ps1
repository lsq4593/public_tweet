# generate_cover_vertical.ps1
# 9:16 (1080x1920) vertical cover from a real photo.
param(
  [string]$BasePng = "C:\Users\cbs\Desktop\公众号推文\04_工具脚本\底图\海边.jpg",
  [string]$SourceMd = "C:\Users\cbs\Desktop\公众号推文\02_AI主题\15_AI动手手册02_我用AI帮我清了一次手机相册.md",
  [string]$OutPng  = "C:\Users\cbs\Desktop\公众号推文\02_AI主题\_配图\15_清相册_封面_竖版.png",
  [string]$Subtitle = "",
  [int]$CropBias = 0.42
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$W = 1080
$H = 1920
$rnd = New-Object System.Random 20260411

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# ---------- 1. crop to 9:16 ----------
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
  $cropY = [int](($src.Height - $cropH) * $CropBias)
}
$destRect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$srcRect = New-Object System.Drawing.Rectangle($cropX, $cropY, $cropW, $cropH)
$g.DrawImage($src, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
$src.Dispose()

# ---------- 2. vignette ----------
for ($i = 0; $i -lt 130; $i++) {
  $p = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(3, 30, 20, 12), 14)
  $inset = $i * 6
  $g.DrawRectangle($p, $inset, [int]($inset * 0.8), ($W - 2 * $inset), ($H - $inset * 1.6))
  $p.Dispose()
}

# ---------- 3. film grain ----------
for ($i = 0; $i -lt 1600; $i++) {
  $x = $rnd.Next(0, $W); $y = $rnd.Next(0, $H)
  $a = $rnd.Next(6, 26)
  $c = if ($rnd.Next(0, 2) -eq 0) { [System.Drawing.Color]::FromArgb($a, 255, 250, 236) } else { [System.Drawing.Color]::FromArgb($a, 60, 46, 32) }
  $d = New-Object System.Drawing.SolidBrush $c
  $g.FillEllipse($d, $x, $y, 2, 2)
  $d.Dispose()
}

# ---------- 4. soft scrim, top and bottom only ----------
$topRect = New-Object System.Drawing.Rectangle(0, 0, $W, 900)
$tg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  $topRect,
  [System.Drawing.Color]::FromArgb(190, 24, 14, 12),
  [System.Drawing.Color]::FromArgb(0, 24, 14, 12),
  90)
$g.FillRectangle($tg, $topRect)
$tg.Dispose()

$botRect = New-Object System.Drawing.Rectangle(0, ($H - 820), $W, 820)
$bg2 = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  $botRect,
  [System.Drawing.Color]::FromArgb(0, 18, 12, 12),
  [System.Drawing.Color]::FromArgb(225, 18, 12, 12),
  90)
$g.FillRectangle($bg2, $botRect)
$bg2.Dispose()

# ---------- 5. typography ----------
$all = [System.IO.File]::ReadAllText($SourceMd, [System.Text.Encoding]::UTF8)
$h1 = ($all -split "`n" | Where-Object { $_ -match '^#\s' } | Select-Object -First 1)
$h1 = ($h1 -replace '^#\s+', '').Trim()
$parts = $h1 -split [char]0xFF5C
$title = $parts[0].Trim()
$badge = ""
if ($parts.Count -gt 1) { $badge = $parts[1].Trim() }

$fBadge = New-Object System.Drawing.Font ("Consolas", 32, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fTitle = New-Object System.Drawing.Font ("Microsoft YaHei UI", 96, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fSub = New-Object System.Drawing.Font ("Microsoft YaHei UI", 40, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 252, 246))
$amber = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 214, 150))
$mute = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(235, 240, 226, 206))

$tx = 96

# badge at the top
if ($badge.Length -gt 0) {
  $bs = $g.MeasureString($badge, $fBadge)
  $pw = [int]$bs.Width + 60; $ph = 66; $py = 130
  $pb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(120, 28, 20, 16))
  $g.FillRectangle($pb, $tx, $py, $pw, $ph)
  $pb.Dispose()
  $pp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(195, 255, 214, 150), 2)
  $g.DrawRectangle($pp, $tx, $py, $pw, $ph)
  $pp.Dispose()
  $g.DrawString($badge, $fBadge, $amber, ($tx + 30), ($py + 15))
}

# title sits in the lower third, over the darkened sand
$maxW = $W - 2 * $tx
$lines = New-Object System.Collections.ArrayList
$cur = ""
foreach ($ch in $title.ToCharArray()) {
  $t = $cur + $ch
  if ($g.MeasureString($t, $fTitle).Width -gt $maxW -and $cur.Length -gt 0) {
    [void]$lines.Add($cur); $cur = $ch
  } else { $cur = $t }
}
if ($cur.Length -gt 0) { [void]$lines.Add($cur) }

$lh = 132
$blockH = $lines.Count * $lh
$ty = $H - 300 - $blockH
if ($Subtitle.Length -gt 0) { $ty -= 76 }

for ($i = 0; $i -lt $lines.Count; $i++) {
  $g.DrawString($lines[$i], $fTitle, $white, $tx, ($ty + $i * $lh))
}

$ry = $ty + $blockH - 14
$rp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(235, 255, 214, 150), 4)
$g.DrawLine($rp, $tx, $ry, ($tx + 170), $ry)
$rp.Dispose()

if ($Subtitle.Length -gt 0) {
  $subLines = New-Object System.Collections.ArrayList
  $cur = ""
  foreach ($ch in $Subtitle.ToCharArray()) {
    $t = $cur + $ch
    if ($g.MeasureString($t, $fSub).Width -gt $maxW -and $cur.Length -gt 0) {
      [void]$subLines.Add($cur); $cur = $ch
    } else { $cur = $t }
  }
  if ($cur.Length -gt 0) { [void]$subLines.Add($cur) }
  for ($i = 0; $i -lt $subLines.Count; $i++) {
    $g.DrawString($subLines[$i], $fSub, $mute, $tx, ($ry + 40 + $i * 56))
  }
}

$white.Dispose(); $amber.Dispose(); $mute.Dispose()
$fBadge.Dispose(); $fTitle.Dispose(); $fSub.Dispose()
$g.Dispose()
$bmp.Save($OutPng, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $OutPng)