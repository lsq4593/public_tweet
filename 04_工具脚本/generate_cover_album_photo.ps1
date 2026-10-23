# generate_cover_album_photo.ps1
# 21:9 (1792x768) cover, story style: a made-up aged photograph as the full-bleed background.
param(
  [string]$SourceMd = "C:\Users\cbs\Desktop\公众号推文\02_AI主题\15_AI动手手册02_我用AI帮我清了一次手机相册.md",
  [string]$OutPng  = "C:\Users\cbs\Desktop\公众号推文\02_AI主题\_配图\15_清相册_封面.png",
  [string]$Subtitle = ""
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$W = 1792
$H = 768
$rnd = New-Object System.Random 20260409

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

# ============ 1. build the fake old photo on its own layer ============
$photo = New-Object System.Drawing.Bitmap($W, $H)
$pg = [System.Drawing.Graphics]::FromImage($photo)

# sky: faded dusk, warm and dusty
$sky = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, $W, 520)),
  [System.Drawing.Color]::FromArgb(255, 214, 176, 132),
  [System.Drawing.Color]::FromArgb(255, 158, 118, 96),
  90)
$pg.FillRectangle($sky, (New-Object System.Drawing.Rectangle(0, 0, $W, 520)))
$sky.Dispose()

# low sun
$sb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(150, 255, 244, 214))
$pg.FillEllipse($sb, (1180), (300), 210, 210)
$sb.Dispose()
for ($r = 260; $r -gt 0; $r -= 10) {
  $a = [int](11 * [math]::Pow(1 - $r / 260, 2))
  if ($a -le 0) { continue }
  $p = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($a, 255, 236, 190), 10)
  $pg.DrawEllipse($p, (1185 - $r), (305 - $r), (2 * $r), (2 * $r))
  $p.Dispose()
}

# distant hills
$hills = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 120, 96, 88))
$h2 = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 92, 74, 72))
$pg.FillPolygon($hills, @(
  (New-Object System.Drawing.Point(0, 400)), (New-Object System.Drawing.Point(280, 316)),
  (New-Object System.Drawing.Point(520, 372)), (New-Object System.Drawing.Point(760, 330)),
  (New-Object System.Drawing.Point(1010, 386)), (New-Object System.Drawing.Point(1260, 344)),
  (New-Object System.Drawing.Point(1520, 392)), (New-Object System.Drawing.Point(1792, 356)),
  (New-Object System.Drawing.Point(1792, 560)), (New-Object System.Drawing.Point(0, 560))))
$pg.FillPolygon($h2, @(
  (New-Object System.Drawing.Point(0, 452)), (New-Object System.Drawing.Point(340, 414)),
  (New-Object System.Drawing.Point(660, 462)), (New-Object System.Drawing.Point(980, 424)),
  (New-Object System.Drawing.Point(1320, 470)), (New-Object System.Drawing.Point(1792, 434)),
  (New-Object System.Drawing.Point(1792, 560)), (New-Object System.Drawing.Point(0, 560))))
$hills.Dispose(); $h2.Dispose()

# ground
$gr = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 500, $W, 268)),
  [System.Drawing.Color]::FromArgb(255, 118, 98, 88),
  [System.Drawing.Color]::FromArgb(255, 62, 52, 54),
  90)
$pg.FillRectangle($gr, (New-Object System.Drawing.Rectangle(0, 500, $W, 268)))
$gr.Dispose()

# two figures standing together, seen from behind, sun low behind them on the right
function New-Pt([int]$x, [int]$y) {
  return (New-Object System.Drawing.Point -ArgumentList $x, $y)
}

function New-Figure([int]$baseX, [int]$baseY, [double]$scale, [bool]$isLongHair, [int]$tilt) {
  $ink = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(238, 40, 33, 36))
  $rim = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(175, 255, 206, 142), [float](2.4 * $scale))
  $rim.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

  $hd = 11.5 * $scale
  $headY = [int]($baseY - 74 * $scale)
  $hipY = [int]($baseY - 44 * $scale)
  $footY = [int]($baseY - 2 * $scale)
  $shY = [int]($headY + $hd * 0.95)
  $handY = [int]($baseY - 40 * $scale)
  $neckY = [int]($headY + $hd * 0.55)

  # ground contact shadow
  $sh = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(115, 34, 28, 30))
  $pg.FillEllipse($sh, [int]($baseX - 26 * $scale), [int]($baseY - 5 * $scale), [int](52 * $scale), [int](13 * $scale))
  $sh.Dispose()

  # legs, slightly apart with a small weight shift
  $pg.FillPolygon($ink, @(
    (New-Pt ([int]($baseX - 9 * $scale)) $hipY),
    (New-Pt ([int]($baseX - 0.5 * $scale)) $hipY),
    (New-Pt ([int]($baseX - 3 * $scale + $tilt)) $footY),
    (New-Pt ([int]($baseX - 13 * $scale + $tilt)) $footY)))
  $pg.FillPolygon($ink, @(
    (New-Pt ([int]($baseX + 1 * $scale)) $hipY),
    (New-Pt ([int]($baseX + 10.5 * $scale)) $hipY),
    (New-Pt ([int]($baseX + 9 * $scale + $tilt)) $footY),
    (New-Pt ([int]($baseX + 0.5 * $scale + $tilt)) $footY)))

  # torso
  $pg.FillPolygon($ink, @(
    (New-Pt ([int]($baseX - 13 * $scale)) $shY),
    (New-Pt ([int]($baseX + 13 * $scale)) $shY),
    (New-Pt ([int]($baseX + 11 * $scale)) $hipY),
    (New-Pt ([int]($baseX - 11 * $scale)) $hipY)))

  # arms
  $pg.FillPolygon($ink, @(
    (New-Pt ([int]($baseX - 14 * $scale)) ([int]($headY + $hd))),
    (New-Pt ([int]($baseX - 10 * $scale)) ([int]($headY + $hd))),
    (New-Pt ([int]($baseX - 9 * $scale)) $handY),
    (New-Pt ([int]($baseX - 14 * $scale)) $handY)))
  $pg.FillPolygon($ink, @(
    (New-Pt ([int]($baseX + 10 * $scale)) ([int]($headY + $hd))),
    (New-Pt ([int]($baseX + 14 * $scale)) ([int]($headY + $hd))),
    (New-Pt ([int]($baseX + 14 * $scale)) $handY),
    (New-Pt ([int]($baseX + 9 * $scale)) $handY)))

  # neck
  $pg.FillRectangle($ink, [int]($baseX - 4 * $scale), $neckY, [int](8 * $scale), [int]($hd * 0.5))

  # head
  $pg.FillEllipse($ink, [int]($baseX - $hd), [int]($headY - $hd), [int](2 * $hd), [int](2 * $hd))

  if ($isLongHair) {
    $pg.FillPie($ink, [int]($baseX - $hd - 1.5 * $scale), [int]($headY - $hd - 1 * $scale), [int](2 * $hd + 3 * $scale), [int](2 * $hd + 2 * $scale), 180, 180)
    $pg.FillPolygon($ink, @(
      (New-Pt ([int]($baseX - $hd - 1 * $scale)) ([int]($headY + $hd * 0.2))),
      (New-Pt ([int]($baseX - $hd + 2 * $scale)) ([int]($headY + $hd * 0.2))),
      (New-Pt ([int]($baseX - $hd + 3.5 * $scale)) ([int]($headY + $hd * 1.7))),
      (New-Pt ([int]($baseX - $hd - 1 * $scale)) ([int]($headY + $hd * 1.5)))))
    $pg.FillPolygon($ink, @(
      (New-Pt ([int]($baseX + $hd - 2 * $scale)) ([int]($headY + $hd * 0.2))),
      (New-Pt ([int]($baseX + $hd + 1 * $scale)) ([int]($headY + $hd * 0.2))),
      (New-Pt ([int]($baseX + $hd + 1 * $scale)) ([int]($headY + $hd * 1.5))),
      (New-Pt ([int]($baseX + $hd - 3.5 * $scale)) ([int]($headY + $hd * 1.7)))))
  } else {
    $pg.FillPie($ink, [int]($baseX - $hd - 1 * $scale), [int]($headY - $hd - 2 * $scale), [int](2 * $hd + 2 * $scale), [int](2 * $hd + 1.5 * $scale), 180, 180)
  }

  # rim light down the sun-facing edge
  $pg.DrawLine($rim, [int]($baseX + $hd * 0.72), [int]($headY - $hd * 0.6), [int]($baseX + $hd * 0.78), [int]($headY + $hd * 0.85))
  $pg.DrawLine($rim, [int]($baseX + 13 * $scale), [int]($headY + $hd * 1.15), [int]($baseX + 11.5 * $scale), $hipY)
  $pg.DrawLine($rim, [int]($baseX + 14 * $scale), [int]($headY + $hd * 1.05), [int]($baseX + 14 * $scale), $handY)
  $pg.DrawLine($rim, [int]($baseX + 8.5 * $scale), ($hipY + 1), [int]($baseX + 7.5 * $scale + $tilt), [int]($footY - 2))

  $ink.Dispose(); $rim.Dispose()
}

# cast shadows toward the viewer, away from the sun
$cs = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(52, 36, 30, 32))
$pg.FillPolygon($cs, @(
  (New-Pt 830 562), (New-Pt 872 562), (New-Pt 720 726), (New-Pt 664 726)))
$pg.FillPolygon($cs, @(
  (New-Pt 908 556), (New-Pt 946 556), (New-Pt 852 726), (New-Pt 792 726)))
$cs.Dispose()

New-Figure 851 566 1.52 $true  -4
New-Figure 927 560 1.38 $false 6

# ============ ageing pass ============
# 1) colour wash: old prints drift yellow-brown
$wash = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(46, 196, 148, 78))
$pg.FillRectangle($wash, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)))
$wash.Dispose()
# 2) lifted blacks = faded contrast
$lift = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(34, 92, 78, 64))
$pg.FillRectangle($lift, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)))
$lift.Dispose()

# 3) vignette
for ($i = 0; $i -lt 90; $i++) {
  $a = 3
  $p = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($a, 40, 26, 18), 14)
  $inset = $i * 5
  $pg.DrawRectangle($p, $inset, ($inset * 0.55), ($W - 2 * $inset), ($H - $inset * 1.1))
  $p.Dispose()
}

# 4) dust and small scratches
for ($i = 0; $i -lt 900; $i++) {
  $x = $rnd.Next(0, $W); $y = $rnd.Next(0, $H)
  $a = $rnd.Next(10, 48)
  $sz = $rnd.Next(1, 3)
  $c = if ($rnd.Next(0, 2) -eq 0) { [System.Drawing.Color]::FromArgb($a, 255, 250, 235) } else { [System.Drawing.Color]::FromArgb($a, 60, 44, 32) }
  $d = New-Object System.Drawing.SolidBrush $c
  $pg.FillEllipse($d, $x, $y, $sz, $sz)
  $d.Dispose()
}
for ($i = 0; $i -lt 16; $i++) {
  $x = $rnd.Next(0, $W); $y = $rnd.Next(0, $H)
  $len = $rnd.Next(30, 190); $ang = $rnd.Next(-40, 40)
  $p = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($rnd.Next(18, 42), 255, 248, 232), 1)
  $pg.DrawLine($p, $x, $y, ($x + $len * [math]::Cos($ang * [math]::PI / 180)), ($y + $len * [math]::Sin($ang * [math]::PI / 180)))
  $p.Dispose()
}

# 5) light leak in the top-right corner
for ($r = 420; $r -gt 0; $r -= 12) {
  $a = [int](13 * [math]::Pow(1 - $r / 420, 2.4))
  if ($a -le 0) { continue }
  $p = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($a, 255, 214, 150), 12)
  $pg.DrawEllipse($p, ($W - 200 - $r), (-140 - $r), (2 * $r), (2 * $r))
  $p.Dispose()
}

# 6) white print border, slightly uneven
$bpen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(235, 238, 232, 220), 22)
$pg.DrawRectangle($bpen, 11, 11, ($W - 22), ($H - 22))
$bpen.Dispose()
# corner wear on the border
for ($i = 0; $i -lt 40; $i++) {
  $corner = $rnd.Next(0, 4)
  $cx = 0
  $cy = 0
  if ($corner -eq 1) { $cx = $W - 90; $cy = 0 }
  elseif ($corner -eq 2) { $cx = 0; $cy = $H - 90 }
  elseif ($corner -eq 3) { $cx = $W - 90; $cy = $H - 90 }
  $x = $cx + $rnd.Next(0, 90); $y = $cy + $rnd.Next(0, 90)
  $c = [System.Drawing.Color]::FromArgb($rnd.Next(60, 140), 150, 130, 110)
  $d = New-Object System.Drawing.SolidBrush $c
  $pg.FillEllipse($d, $x, $y, $rnd.Next(2, 7), $rnd.Next(2, 7))
  $d.Dispose()
}

$pg.Dispose()

# ============ composite ============
$g.DrawImage($photo, 0, 0, $W, $H)
$photo.Dispose()

# dark scrim on the left third so the text reads
$sc = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, 1080, $H)),
  [System.Drawing.Color]::FromArgb(248, 10, 8, 10),
  [System.Drawing.Color]::FromArgb(0, 10, 8, 10),
  0)
$g.FillRectangle($sc, (New-Object System.Drawing.Rectangle(0, 0, 1080, $H)))
$sc.Dispose()
# overall slight darkening at the very bottom for the date stamp
$btRect = New-Object System.Drawing.Rectangle(0, ($H - 150), $W, 150)
$bt = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  $btRect,
  [System.Drawing.Color]::FromArgb(0, 12, 8, 8),
  [System.Drawing.Color]::FromArgb(140, 12, 8, 8),
  90)
$g.FillRectangle($bt, $btRect)
$bt.Dispose()

# ============ typography ============
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
$fStamp = New-Object System.Drawing.Font ("Consolas", 46, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fStampS = New-Object System.Drawing.Font ("Microsoft YaHei UI", 22, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 250, 246, 238))
$amber = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 244, 196, 116))
$mute = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(225, 226, 206, 180))

$tx = 104

# badge, styled like a film canister label
if ($badge.Length -gt 0) {
  $bs = $g.MeasureString($badge, $fBadge)
  $pw = [int]$bs.Width + 52; $ph = 58; $py = 86
  $pb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(120, 30, 22, 18))
  $g.FillRectangle($pb, $tx, $py, $pw, $ph)
  $pb.Dispose()
  $pp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(180, 244, 196, 116), 2)
  $g.DrawRectangle($pp, $tx, $py, $pw, $ph)
  $pp.Dispose()
  $g.DrawString($badge, $fBadge, $amber, ($tx + 26), ($py + 13))
}

$maxW = 700
$ty = 232
$lines = New-Object System.Collections.ArrayList
$cur = ""
foreach ($ch in $title.ToCharArray()) {
  $t = $cur + $ch
  if ($g.MeasureString($t, $fTitle).Width -gt $maxW -and $cur.Length -gt 0) {
    [void]$lines.Add($cur); $cur = $ch
  } else { $cur = $t }
}
if ($cur.Length -gt 0) { [void]$lines.Add($cur) }
if ($lines.Count -gt 4) {
  $lines[0] = $lines[0] + $lines[1]; $lines.RemoveAt(1)
}

$lh = 100
for ($i = 0; $i -lt $lines.Count; $i++) {
  $g.DrawString($lines[$i], $fTitle, $white, $tx, ($ty + $i * $lh))
}

$ry = $ty + $lines.Count * $lh - 4
$rp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(220, 244, 196, 116), 3)
$g.DrawLine($rp, $tx, $ry, ($tx + 150), $ry)
$rp.Dispose()

if ($Subtitle.Length -gt 0) {
  $g.DrawString($Subtitle, $fSub, $mute, $tx, ($ry + 36))
}

# camera date stamp in the corner, like a printed photo
$g.DrawString("2023 . 11 . 04", $fStamp, $amber, ($W - 430), ($H - 96))
$g.DrawString("4312 photos, deleted 540", $fStampS, $mute, ($W - 430), ($H - 44))

$white.Dispose(); $amber.Dispose(); $mute.Dispose()
$fBadge.Dispose(); $fTitle.Dispose(); $fSub.Dispose(); $fStamp.Dispose(); $fStampS.Dispose()
$g.Dispose()
$bmp.Save($OutPng, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $OutPng)