# generate_cover_handbook_bars.ps1
# 21:9 (1792x768) cover with a two-bar comparison graphic on the right.
# Source file is ASCII-only: every CJK string is passed in as a parameter.
param(
  [string]$SourceMd = "",
  [string]$OutPng  = "",
  [string]$Subtitle = "",
  [string]$Header   = "",
  [string]$BarLabel1 = "", [string]$BarValue1 = "", [double]$Pct1 = 0.0,
  [string]$BarLabel2 = "", [string]$BarValue2 = "", [double]$Pct2 = 0.0,
  [string]$Kicker = ""
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$W = 1792
$H = 768

# ---------- read H1 from markdown ----------
if ($SourceMd.Length -eq 0) { throw "SourceMd is required" }
if ($OutPng.Length -eq 0) { throw "OutPng is required" }

$all = [System.IO.File]::ReadAllText($SourceMd, [System.Text.Encoding]::UTF8)
$h1 = ($all -split "`n" | Where-Object { $_ -match '^#\s' } | Select-Object -First 1)
if ($h1 -eq $null) { throw "no H1 found in $SourceMd" }
$h1 = ($h1 -replace '^#\s+', '').Trim()

$parts = $h1 -split [char]0xFF5C
$title = $parts[0].Trim()
$badge = ""
if ($parts.Count -gt 1) { $badge = $parts[1].Trim() }

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = [System.Drawing.StringAlignment]::Near
$sf.LineAlignment = [System.Drawing.StringAlignment]::Near
$sf.FormatFlags = $sf.FormatFlags -bor [System.Drawing.StringFormatFlags]::NoPadding
$sfB = New-Object System.Drawing.StringFormat
$sfB.Alignment = [System.Drawing.StringAlignment]::Far
$sfB.LineAlignment = [System.Drawing.StringAlignment]::Near
$sfB.FormatFlags = $sfB.FormatFlags -bor [System.Drawing.StringFormatFlags]::NoPadding

function Measure-W([string]$t, $f) {
  return $g.MeasureString($t, $f, (New-Object System.Drawing.SizeF(9999, 9999)), $sf).Width
}

# ---------- background gradient ----------
$top = [System.Drawing.Color]::FromArgb(255, 7, 20, 40)
$bot = [System.Drawing.Color]::FromArgb(255, 18, 56, 110)
$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $top, $bot, 90)
$g.FillRectangle($brush, $rect)

# ---------- subtle grid ----------
$gridPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(18, 120, 190, 255), 1)
for ($x = 0; $x -le $W; $x += 64) { $g.DrawLine($gridPen, $x, 0, $x, $H) }
for ($y = 0; $y -le $H; $y += 64) { $g.DrawLine($gridPen, 0, $y, $W, $y) }
$gridPen.Dispose()

# ---------- left vignette so the title stays readable ----------
$vigRect = New-Object System.Drawing.Rectangle(0, 0, 1150, $H)
$vigBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  $vigRect,
  [System.Drawing.Color]::FromArgb(235, 4, 12, 30),
  [System.Drawing.Color]::FromArgb(0, 4, 12, 30),
  0)
$g.FillRectangle($vigBrush, $vigRect)
$vigBrush.Dispose()

# ---------- right panel ----------
$panelX = 1044; $panelY = 60; $panelW = 704; $panelH = 648
$panelFill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(30, 3, 18, 42))
$g.FillRectangle($panelFill, $panelX, $panelY, $panelW, $panelH)
$panelFill.Dispose()
$panelPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(95, 0, 200, 255), 2)
$g.DrawRectangle($panelPen, $panelX, $panelY, $panelW, $panelH)
$panelPen.Dispose()

# soft cyan glow behind the panel
$gcx = $panelX + [int]($panelW / 2)
$gcy = $panelY + [int]($panelH / 2)
for ($r = 400; $r -gt 0; $r -= 8) {
  $a = [int](14 * [math]::Pow(1 - $r / 400, 2.2))
  if ($a -le 0) { continue }
  $gp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($a, 0, 200, 255), 8)
  $g.DrawEllipse($gp, ($gcx - $r), ($gcy - $r), (2 * $r), (2 * $r))
  $gp.Dispose()
}

# ---------- fonts ----------
$fontBadge = New-Object System.Drawing.Font ("Microsoft YaHei UI", 30, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fontSub = New-Object System.Drawing.Font ("Microsoft YaHei UI", 32, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fontHead = New-Object System.Drawing.Font ("Microsoft YaHei UI", 42, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fontLbl = New-Object System.Drawing.Font ("Microsoft YaHei UI", 30, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fontVal = New-Object System.Drawing.Font ("Microsoft YaHei UI", 28, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fontKick = New-Object System.Drawing.Font ("Microsoft YaHei UI", 38, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)

$white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 244, 248, 255))
$gold = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 232, 178, 92))
$cyan = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 126, 205, 255))
$mute = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(215, 168, 196, 226))

$textX = 110
$maxW = 872

# ---------- wrap helper ----------
function Wrap-Text([string]$t, $f, [int]$limitW, [int]$maxLines) {
  $lines = New-Object System.Collections.ArrayList
  $cur = ""
  foreach ($ch in $t.ToCharArray()) {
    $test = $cur + $ch
    if ((Measure-W $test $f) -gt $limitW -and $cur.Length -gt 0) {
      [void]$lines.Add($cur); $cur = $ch
    } else { $cur = $test }
  }
  if ($cur.Length -gt 0) { [void]$lines.Add($cur) }
  return ,@($lines)
}

# ---------- badge pill ----------
if ($badge.Length -gt 0) {
  $bSize = $g.MeasureString($badge, $fontBadge, (New-Object System.Drawing.SizeF(9999, 9999)), $sf)
  $pillW = [int]$bSize.Width + 56
  $pillY = 92
  $pillBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(46, 0, 200, 255))
  $g.FillRectangle($pillBrush, $textX, $pillY, $pillW, 62)
  $pillBrush.Dispose()
  $pillPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(190, 0, 200, 255), 2)
  $g.DrawRectangle($pillPen, $textX, $pillY, $pillW, 62)
  $pillPen.Dispose()
  $g.DrawString($badge, $fontBadge, $cyan, ($textX + 28), ($pillY + 15), $sf)
}

# ---------- title: shrink until it fits 3 lines ----------
$sizes = @(78, 72, 66, 60, 54, 48)
$fontTitle = $null
$titleLines = @()
foreach ($s in $sizes) {
  $f = New-Object System.Drawing.Font ("Microsoft YaHei UI", $s, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $ls = Wrap-Text $title $f $maxW 3
  if ($ls.Count -le 3) { $fontTitle = $f; $titleLines = $ls; break }
  $f.Dispose()
}
if ($fontTitle -eq $null) {
  $fontTitle = New-Object System.Drawing.Font ("Microsoft YaHei UI", 48, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $titleLines = Wrap-Text $title $fontTitle $maxW 3
}

$titleY = 226
$lineH = [int]($fontTitle.SizeInPoints * 4)
if ($lineH -lt 86) { $lineH = 86 }
if ($lineH -gt 112) { $lineH = 112 }
for ($i = 0; $i -lt $titleLines.Count; $i++) {
  $g.DrawString($titleLines[$i], $fontTitle, $white, $textX, ($titleY + $i * $lineH), $sf)
}

$blockBottom = $titleY + $titleLines.Count * $lineH

$ruleY = $blockBottom - 6
$rulePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 232, 178, 92), 4)
$g.DrawLine($rulePen, $textX, $ruleY, ($textX + 180), $ruleY)
$rulePen.Dispose()

if ($Subtitle.Length -gt 0) {
  $subLines = Wrap-Text $Subtitle $fontSub $maxW 2
  $subY = $ruleY + 42
  for ($i = 0; $i -lt $subLines.Count; $i++) {
    $g.DrawString($subLines[$i], $fontSub, $mute, $textX, ($subY + $i * 46), $sf)
  }
}

# ---------- right panel content ----------
$inX = $panelX + 48
$inW = $panelW - 96
$barMaxW = 560
$barH = 34

$y = 112
if ($Header.Length -gt 0) {
  $g.DrawString($Header, $fontHead, $gold, $inX, $y, $sf)
  $y += 62
}

function Draw-Row([int]$rowY, [string]$label, [string]$value, [double]$pct) {
  $g.DrawString($label, $fontLbl, $white, $inX, $rowY, $sf)
  $g.DrawString($value, $fontVal, $mute, $inX, ($rowY + 46), $sf)
  $barY = $rowY + 88
  $track = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(34, 130, 195, 255))
  $g.FillRectangle($track, $inX, $barY, $barMaxW, $barH)
  $track.Dispose()
  $trackPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(70, 130, 195, 255), 1)
  $g.DrawRectangle($trackPen, $inX, $barY, $barMaxW, $barH)
  $trackPen.Dispose()
  $fillW = [int]([math]::Round($barMaxW * $pct))
  if ($fillW -lt 8) { $fillW = 8 }
  if ($fillW -gt $barMaxW) { $fillW = $barMaxW }
  $fill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 232, 178, 92))
  $g.FillRectangle($fill, $inX, $barY, $fillW, $barH)
  $fill.Dispose()
  $tickPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(120, 150, 205, 255), 1)
  $g.DrawLine($tickPen, ($inX + $barMaxW), ($barY - 8), ($inX + $barMaxW), ($barY + $barH + 8))
  $tickPen.Dispose()
}

Draw-Row ($y + 26) $BarLabel1 $BarValue1 $Pct1
Draw-Row ($y + 226) $BarLabel2 $BarValue2 $Pct2

if ($Kicker.Length -gt 0) {
  $ky = 570
  $kPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(90, 232, 178, 92), 2)
  $g.DrawLine($kPen, $inX, ($ky - 22), ($inX + $inW), ($ky - 22))
  $kPen.Dispose()
  $g.DrawString($Kicker, $fontKick, $white, $inX, $ky, $sf)
}

# ---------- cleanup ----------
$white.Dispose(); $gold.Dispose(); $cyan.Dispose(); $mute.Dispose()
$fontBadge.Dispose(); $fontSub.Dispose(); $fontHead.Dispose()
$fontLbl.Dispose(); $fontVal.Dispose(); $fontKick.Dispose(); $fontTitle.Dispose()
$brush.Dispose()
$g.Dispose()

$bmp.Save($OutPng, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $OutPng)