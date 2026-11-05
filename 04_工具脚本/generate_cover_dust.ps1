# generate_cover_dust.ps1
# Cover type: 精准深耕「戒掉内耗」layout — centered badge / title / subtitle / keyword line.
# Background is this article's own plate (balcony, boxes, dust), not the 内耗 graphic.

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$Plate  = "C:\Users\cbs\Desktop\公众号推文\03_独立文章\_配图\收藏落灰_封面底图.jpg"
$OutPng = "C:\Users\cbs\Desktop\公众号推文\03_独立文章\_配图\收藏落灰_封面.png"

$W = 3360
$H = 1440

$white = [System.Drawing.Color]::FromArgb(255, 250, 248, 242)
$mute  = [System.Drawing.Color]::FromArgb(255, 214, 204, 186)
$gold  = [System.Drawing.Color]::FromArgb(255, 214, 176, 110)

function New-RoundedPath {
  param([float]$X, [float]$Y, [float]$W, [float]$H, [float]$R)
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = [Math]::Max(2, $R * 2)
  $p.AddArc($X, $Y, $d, $d, 180, 90)
  $p.AddArc(($X + $W - $d), $Y, $d, $d, 270, 90)
  $p.AddArc(($X + $W - $d), ($Y + $H - $d), $d, $d, 0, 90)
  $p.AddArc($X, ($Y + $H - $d), $d, $d, 90, 90)
  $p.CloseFigure()
  return $p
}

$src = [System.Drawing.Image]::FromFile($Plate)
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# cover-scale 16:9 plate into 21:9, keep the lower balcony
$scale = $W / [double]$src.Width
$dw = $W
$dh = [int]($src.Height * $scale)
$dy = $H - $dh + 120
$g.DrawImage($src, 0, $dy, $dw, $dh)
$src.Dispose()

# top/center dark veil so white type reads, fade out over the floor
$veil = New-Object System.Drawing.Bitmap($W, $H)
$vg = [System.Drawing.Graphics]::FromImage($veil)
for ($y = 0; $y -lt $H; $y++) {
  $t = $y / [double]$H
  if ($t -lt 0.42) { $a = 150 }
  elseif ($t -lt 0.62) { $a = [int](150 * (1 - ($t - 0.42) / 0.20)) }
  else { $a = 0 }
  if ($a -le 0) { continue }
  $b = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($a, 8, 10, 14))
  $vg.FillRectangle($b, 0, $y, $W, 1)
  $b.Dispose()
}
$vg.Dispose()
$g.DrawImage($veil, 0, 0)
$veil.Dispose()

$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = [System.Drawing.StringAlignment]::Center
$sf.LineAlignment = [System.Drawing.StringAlignment]::Center
$sf.FormatFlags = $sf.FormatFlags -bor [System.Drawing.StringFormatFlags]::NoWrap

# badge
$fBadge = New-Object System.Drawing.Font("Microsoft YaHei UI", 36, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$badgeText = "独立文章"
$badgeSize = $g.MeasureString($badgeText, $fBadge, [System.Drawing.PointF]::Empty, $sf)
$bw = [int]($badgeSize.Width + 56)
$bh = 64
$bx = [int](($W - $bw) / 2)
$by = 168
$pen = New-Object System.Drawing.Pen $gold, 3
$path = New-RoundedPath $bx $by $bw $bh 6
$g.DrawPath($pen, $path)
$path.Dispose()
$pen.Dispose()
$bGold = New-Object System.Drawing.SolidBrush $gold
$g.DrawString($badgeText, $fBadge, $bGold, (New-Object System.Drawing.RectangleF($bx, $by, $bw, $bh)), $sf)
$fBadge.Dispose()

# title
$fTitle = New-Object System.Drawing.Font("Microsoft YaHei UI", 168, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bWhite = New-Object System.Drawing.SolidBrush $white
$g.DrawString("后来都落了灰", $fTitle, $bWhite, (New-Object System.Drawing.RectangleF(0, 270, $W, 240)), $sf)
$fTitle.Dispose()

# subtitle
$fSub = New-Object System.Drawing.Font("Microsoft YaHei UI", 48, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString("我收藏了很多「以后」", $fSub, $bWhite, (New-Object System.Drawing.RectangleF(0, 520, $W, 80)), $sf)
$fSub.Dispose()
$bWhite.Dispose()

# keyword rule
$kwY = 640
$linePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(160, 214, 176, 110), 2)
$g.DrawLine($linePen, 980, ($kwY + 28), 1240, ($kwY + 28))
$g.DrawLine($linePen, 2120, ($kwY + 28), 2380, ($kwY + 28))
$linePen.Dispose()
$fKw = New-Object System.Drawing.Font("Microsoft YaHei UI", 32, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString("纸箱  ·  截图  ·  收藏夹  ·  网课  ·  旧物", $fKw, $bGold, (New-Object System.Drawing.RectangleF(0, $kwY, $W, 56)), $sf)
$fKw.Dispose()
$bGold.Dispose()

$sf.Dispose()
$g.Dispose()
$bmp.Save($OutPng, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $OutPng)
