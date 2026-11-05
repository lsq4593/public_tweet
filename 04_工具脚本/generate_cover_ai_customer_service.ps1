# generate_cover_ai_customer_service.ps1
# 21:9 (1792x768) cover for "AI 客服上线后，人工客服去了哪".
# Motif: a 10x10 grid of 100 callers. The bottom two rows (20) are gold and
#        bracketed - the only ones that make it through to a human.
param(
  [string]$OutPng = "C:\Users\cbs\Desktop\公众号推文\02_AI主题\_配图\AI客服_封面.png",
  [string]$CoverEyebrow = "AI 客服上线后",
  [string]$CoverTitle = "人工客服去了哪",
  [string]$CoverSub = "从第一道门，挪到最后一道门",
  [string]$Badge = ""
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

$white = [System.Drawing.Color]::FromArgb(255, 244, 248, 252)
$cyan  = [System.Drawing.Color]::FromArgb(255, 96, 196, 245)
$gold  = [System.Drawing.Color]::FromArgb(255, 232, 178, 96)
$mute  = [System.Drawing.Color]::FromArgb(210, 162, 186, 212)
$dim   = [System.Drawing.Color]::FromArgb(255, 52, 72, 98)

# =========================================================
#  right side: 100 callers, 20 get through
# =========================================================
$x0 = 1032
$y0 = 176
$gapX = 62
$gapY = 46
$r = 12

for ($row = 0; $row -lt 10; $row++) {
  for ($col = 0; $col -lt 10; $col++) {
    $cx = $x0 + $col * $gapX
    $cy = $y0 + $row * $gapY
    if ($row -ge 8) {
      # glow around the ones that get through
      for ($rr = 22; $rr -gt 0; $rr -= 4) {
        $a = [int](26 * [math]::Pow(1 - $rr / 22, 2))
        if ($a -le 0) { continue }
        $gb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($a, 232, 178, 96))
        $g.FillEllipse($gb, ($cx - $rr), ($cy - $rr), (2 * $rr), (2 * $rr))
        $gb.Dispose()
      }
      $gb = New-Object System.Drawing.SolidBrush $gold
      $g.FillEllipse($gb, ($cx - $r), ($cy - $r), (2 * $r), (2 * $r))
      $gb.Dispose()
    } else {
      $gb = New-Object System.Drawing.SolidBrush $dim
      $g.FillEllipse($gb, ($cx - $r), ($cy - $r), (2 * $r), (2 * $r))
      $gb.Dispose()
    }
  }
}

# ---- bracket: only these twenty reach a human ----
$bx = $x0 - 26
$by = $y0 + 8 * $gapY - 26
$bw = 9 * $gapX + 52
$bh = $gapY + 52
$bp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(150, 232, 178, 96), 2)
$g.DrawRectangle($bp, $bx, $by, $bw, $bh)
$bp.Dispose()

$fCap = New-Object System.Drawing.Font ("Microsoft YaHei UI", 30, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fSmall = New-Object System.Drawing.Font ("Microsoft YaHei UI", 20, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$bCyan = New-Object System.Drawing.SolidBrush $cyan
$bGold = New-Object System.Drawing.SolidBrush $gold
$bMute = New-Object System.Drawing.SolidBrush $mute

$g.DrawString("一百个人打进来", $fCap, $bCyan, $x0, 78)
$g.DrawString("八十个停在机器人这里", $fSmall, $bMute, ($x0 + 2), 122)

# ---- the twenty, labelled ----
$g.DrawString("二十个走到人工", $fCap, $bGold, $x0, 632)
$g.DrawString("平均要等四十分钟", $fSmall, $bMute, ($x0 + 2), 670)

# =========================================================
#  left vignette for text legibility
# =========================================================
$vigW = 1000
$vg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle(0, 0, $vigW, $H)),
  [System.Drawing.Color]::FromArgb(246, 5, 10, 20),
  [System.Drawing.Color]::FromArgb(0, 5, 10, 20),
  0)
$g.FillRectangle($vg, (New-Object System.Drawing.Rectangle(0, 0, $vigW, $H)))
$vg.Dispose()

# =========================================================
#  typography
# =========================================================
$fTitle = New-Object System.Drawing.Font ("Microsoft YaHei UI", 84, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fBadge = New-Object System.Drawing.Font ("Microsoft YaHei UI", 28, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fSub   = New-Object System.Drawing.Font ("Microsoft YaHei UI", 32, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$bWhite = New-Object System.Drawing.SolidBrush $white

$tx = 96

if ($Badge.Length -gt 0) {
  $bs = $g.MeasureString($Badge, $fBadge)
  $pw = [int]$bs.Width + 52
  $ph = 58
  $py = 84
  $pb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(46, 0, 190, 255))
  $g.FillRectangle($pb, $tx, $py, $pw, $ph)
  $pb.Dispose()
  $pp = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(190, 0, 190, 255), 2)
  $g.DrawRectangle($pp, $tx, $py, $pw, $ph)
  $pp.Dispose()
  $g.DrawString($Badge, $fBadge, $bCyan, ($tx + 26), ($py + 13))
}

# title: wrap to keep it inside the vignette
$maxW = 700
$ty = 260

if ($CoverEyebrow.Length -gt 0) {
  $fEye = New-Object System.Drawing.Font ("Microsoft YaHei UI", 52, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $bEye = New-Object System.Drawing.SolidBrush $cyan
  $g.DrawString($CoverEyebrow, $fEye, $bEye, $tx, 176)
  $bEye.Dispose()
  $fEye.Dispose()
}
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

# subtitle
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

for ($i = 0; $i -lt $slines.Count; $i++) {
  $g.DrawString($slines[$i], $fSub, $bMute, $tx, ($ry + 44 + $i * 44))
}

# ---------- takeaways ----------
$ky0 = $ry + 44 + $slines.Count * 44 + 38

function New-Takeaway {
  param([int]$Y, [System.Drawing.Color]$Accent, [string]$Tag, [string]$Text)
  $bar = New-Object System.Drawing.SolidBrush $Accent
  $g.FillRectangle($bar, $tx, $Y, 5, 58)
  $bar.Dispose()
  $fTag = New-Object System.Drawing.Font ("Microsoft YaHei UI", 20, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $fTxt = New-Object System.Drawing.Font ("Microsoft YaHei UI", 26, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
  $bTag = New-Object System.Drawing.SolidBrush $Accent
  $bTxt = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(228, 226, 234, 244))
  $g.DrawString($Tag, $fTag, $bTag, ($tx + 20), ($Y + 2))
  $g.DrawString($Text, $fTxt, $bTxt, ($tx + 20), ($Y + 26))
  $fTag.Dispose(); $fTxt.Dispose(); $bTag.Dispose(); $bTxt.Dispose()
}

New-Takeaway $ky0 $cyan "AI 客服" "挡住 · 登记 · 48 小时"
New-Takeaway ($ky0 + 78) $gold "人工客服" "权限 · 破例 · 四十秒"

# ---------- decorative corner marks ----------
$cm = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(70, 232, 178, 96), 2)
$g.DrawLine($cm, 40, 40, 120, 40)
$g.DrawLine($cm, 40, 40, 40, 120)
$g.DrawLine($cm, ($W - 40), ($H - 40), ($W - 120), ($H - 40))
$g.DrawLine($cm, ($W - 40), ($H - 40), ($W - 40), ($H - 120))
$cm.Dispose()

$bWhite.Dispose(); $bCyan.Dispose(); $bGold.Dispose(); $bMute.Dispose()
$fTitle.Dispose(); $fBadge.Dispose(); $fSub.Dispose(); $fCap.Dispose(); $fSmall.Dispose()
$g.Dispose()
$bmp.Save($OutPng, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Saved: " + $OutPng)
