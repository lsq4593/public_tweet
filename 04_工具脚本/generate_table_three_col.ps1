# generate_table_three_col.ps1
# 21:9 (1792x768) three-column table figure, dark + gold, matching the ledger cover.
# Source file is ASCII-only: every CJK string arrives as a parameter.
#   -Headers "h1","h2","h3"
#   -Rows    "col1|col2|col3","col1|col2|col3",...
param(
  [string]$OutPng = "",
  [string]$Headers = "",
  [string]$Rows = "",
  [string]$HeaderNote = "",
  [string]$CornerNote = "",
  [int]$HighlightLast = 1,
  [int]$RowH = 110,
  [int]$Top = 62,
  [string]$FontUI = "Microsoft YaHei UI",
  [string]$FontMono = "Consolas"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$W = 1792
$H = 768

if ($OutPng.Length -eq 0) { throw "OutPng is required" }

$hdr = $Headers -split ","
if ($hdr.Count -lt 3) { throw "need 3 headers" }
$rowLines = $Rows -split ",\s*"
if ($rowLines.Count -lt 1) { throw "need rows" }

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = [System.Drawing.StringAlignment]::Near
$sf.LineAlignment = [System.Drawing.StringAlignment]::Near
$sf.FormatFlags = $sf.FormatFlags -bor [System.Drawing.StringFormatFlags]::NoPadding

function Measure-W([string]$t, $f) {
  return $g.MeasureString($t, $f, (New-Object System.Drawing.SizeF(9999, 9999)), $sf).Width
}

# ================= background =================
$cTop = [System.Drawing.Color]::FromArgb(255, 9, 10, 14)
$cBot = [System.Drawing.Color]::FromArgb(255, 24, 25, 31)
$bgb = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, $W, $H)), $cTop, $cBot, 90)
$g.FillRectangle($bgb, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)))
$bgb.Dispose()

$spotPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$spotPath.AddEllipse(-300, -640, 2400, 1900)
$spot = New-Object System.Drawing.Drawing2D.PathGradientBrush($spotPath)
$spot.CenterPoint = New-Object System.Drawing.PointF(700, 40)
$spot.CenterColor = [System.Drawing.Color]::FromArgb(38, 255, 232, 196)
$spot.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 255, 232, 196))
$g.FillRectangle($spot, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)))
$spot.Dispose(); $spotPath.Dispose()

# ================= geometry =================
$margin = 64
$gap = 64
$colW = @(372, 606, 558)
$colX = @($margin, ($margin + $colW[0] + $gap), ($margin + $colW[0] + $gap + $colW[1] + $gap))
$padX = 22

$headH = 62
$rowGap = 6

# ================= fonts =================
$fHead = New-Object System.Drawing.Font ($FontUI, 29, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fIdx = New-Object System.Drawing.Font ($FontMono, 19, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fKey = New-Object System.Drawing.Font ($FontUI, 28, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fBody = New-Object System.Drawing.Font ($FontUI, 25, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fNote = New-Object System.Drawing.Font ($FontUI, 21, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 248, 247, 245))
$goldB = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 238, 190, 104))
$mute = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(205, 172, 170, 166))
$dim = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(150, 116, 116, 120))

# ================= header =================
$headFill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(28, 238, 190, 104))
$g.FillRectangle($headFill, $margin, $top, ($colW[0] + $colW[1] + $colW[2] + 2 * $gap), $headH)
$headFill.Dispose()
$headPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(90, 238, 190, 104)), 1
$g.DrawRectangle($headPen, $margin, $top, ($colW[0] + $colW[1] + $colW[2] + 2 * $gap), $headH)
$headPen.Dispose()

for ($c = 0; $c -lt 3; $c++) {
  $b = if ($c -eq 2) { $goldB } else { $white }
  $g.DrawString($hdr[$c], $fHead, $b, ($colX[$c] + $padX), ($top + 16), $sf)
}

# ================= wrap helper =================
$noStartCodes = @(0x3002, 0xFF0C, 0x3001, 0xFF1F, 0xFF01, 0xFF1A, 0xFF1B, 0x300D, 0x300F, 0x3011, 0x300B, 0x3009, 0xFF09, 0x002C, 0x002E)
$NO_START = ""
foreach ($cp in $noStartCodes) { $NO_START += [char]$cp }

function Wrap-Text([string]$t, $f, [int]$limitW) {
  $lines = New-Object System.Collections.ArrayList
  $cur = ""
  foreach ($ch in $t.ToCharArray()) {
    $test = $cur + $ch
    if ((Measure-W $test $f) -gt $limitW -and $cur.Length -gt 0) {
      if ($NO_START.IndexOf($ch) -ge 0) { $cur = $test; continue }
      [void]$lines.Add($cur); $cur = $ch
    } else { $cur = $test }
  }
  if ($cur.Length -gt 0) { [void]$lines.Add($cur) }
  return ,@($lines)
}

# ================= body rows =================
$edgePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(38, 150, 152, 160)), 1
$accentPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 238, 190, 104), 4)

for ($i = 0; $i -lt $rowLines.Count; $i++) {
  $y = $top + $headH + 12 + $i * ($rowH + $rowGap)
  $isLast = ($HighlightLast -eq 1 -and $i -eq $rowLines.Count - 1)

  $bg = if ($isLast) {
    [System.Drawing.Color]::FromArgb(255, 34, 29, 22)
  } elseif ($i % 2 -eq 0) {
    [System.Drawing.Color]::FromArgb(255, 18, 19, 25)
  } else {
    [System.Drawing.Color]::FromArgb(255, 13, 14, 19)
  }
  $bf = New-Object System.Drawing.SolidBrush $bg
  $g.FillRectangle($bf, $margin, $y, ($colW[0] + $colW[1] + $colW[2] + 2 * $gap), $rowH)
  $bf.Dispose()
  $g.DrawRectangle($edgePen, $margin, $y, ($colW[0] + $colW[1] + $colW[2] + 2 * $gap), $rowH)

  if ($isLast) { $g.DrawLine($accentPen, ($margin - 6), $y, ($margin - 6), ($y + $rowH)) }

  $idx = "{0:d2}" -f ($i + 1)
  $g.DrawString($idx, $fIdx, $dim, ($margin - 46), ($y + 22), $sf)

  $cells = $rowLines[$i] -split "\|"
  for ($c = 0; $c -lt 3; $c++) {
    if ($c -ge $cells.Count) { continue }
    $txt = $cells[$c]
    $tw = $colW[$c] - 2 * $padX
    $font = if ($c -eq 0) { $fKey } else { $fBody }
    $brush = if ($c -eq 2) { $goldB } elseif ($c -eq 0) { $white } else { $mute }
    $ls = Wrap-Text $txt $font $tw
    $lh = if ($c -eq 0) { 40 } else { 38 }
    $startY = $y + [int](($rowH - $ls.Count * $lh) / 2)
    if ($startY -lt $y + 14) { $startY = $y + 14 }
    for ($k = 0; $k -lt $ls.Count; $k++) {
      if ($startY + $k * $lh -gt $y + $rowH - 8) { break }
      $g.DrawString($ls[$k], $font, $brush, ($colX[$c] + $padX), ($startY + $k * $lh), $sf)
    }
  }
}
$edgePen.Dispose(); $accentPen.Dispose()

# ================= notes =================
if ($HeaderNote.Length -gt 0) {
  $tableRight = $margin + $colW[0] + $colW[1] + $colW[2] + 2 * $gap
  $noteW = (Measure-W $HeaderNote $fNote)
  $noteX = [int]($tableRight - $noteW)
  if ($noteX -lt $margin) { $noteX = $margin }
  $g.DrawString($HeaderNote, $fNote, $dim, ([single]$noteX), ([single]($top - 32)), $sf)
}
if ($CornerNote.Length -gt 0) {
  $g.DrawString($CornerNote, $fNote, $goldB, $margin, ($top + $headH + 12 + $rowLines.Count * ($rowH + $rowGap) + 20), $sf)
}

# grain
$rnd = New-Object System.Random 20261014
for ($i = 0; $i -lt 5200; $i++) {
  $x = $rnd.Next(0, $W); $y = $rnd.Next(0, $H)
  $a = $rnd.Next(3, 11)
  $col = if ($rnd.Next(0, 2) -eq 0) { [System.Drawing.Color]::FromArgb($a, 255, 242, 224) } else { [System.Drawing.Color]::FromArgb($a, 0, 0, 0) }
  $d = New-Object System.Drawing.SolidBrush $col
  $g.FillEllipse($d, $x, $y, 2, 2)
  $d.Dispose()
}

$white.Dispose(); $goldB.Dispose(); $mute.Dispose(); $dim.Dispose()
$fHead.Dispose(); $fIdx.Dispose(); $fKey.Dispose(); $fBody.Dispose(); $fNote.Dispose()
$bgb.Dispose()
$g.Dispose()
$bmp.Save($OutPng, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $OutPng)