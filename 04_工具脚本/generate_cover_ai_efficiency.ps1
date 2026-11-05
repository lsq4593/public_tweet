# generate_cover_ai_efficiency.ps1
# Style reference: 06_第五章戒掉内耗_封面.png
# Dark teal field / gold badge / oversized white title / muted subtitle / cyan keyword rule.

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$OutPng = "C:\Users\cbs\Desktop\公众号推文\03_独立文章\_配图\AI提效_封面.png"

$W = 3360
$H = 1440
$FW = 1600
$FH = 686

$white = [System.Drawing.Color]::FromArgb(255, 255, 255, 255)
$subColor = [System.Drawing.Color]::FromArgb(255, 240, 240, 240)
$gold = [System.Drawing.Color]::FromArgb(255, 208, 160, 112)
$cyan = [System.Drawing.Color]::FromArgb(255, 128, 192, 192)

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

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# Deep teal field, sampled from the reference cover.
$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, [System.Drawing.Color]::FromArgb(255, 10, 50, 61), [System.Drawing.Color]::FromArgb(255, 10, 30, 44), 90)
$blend = New-Object System.Drawing.Drawing2D.ColorBlend(6)
$blend.Colors = @(
  [System.Drawing.Color]::FromArgb(255, 10, 50, 61),
  [System.Drawing.Color]::FromArgb(255, 11, 56, 67),
  [System.Drawing.Color]::FromArgb(255, 11, 56, 67),
  [System.Drawing.Color]::FromArgb(255, 10, 38, 50),
  [System.Drawing.Color]::FromArgb(255, 11, 35, 48),
  [System.Drawing.Color]::FromArgb(255, 10, 30, 44)
)
$blend.Positions = @(0.0, 0.24, 0.54, 0.74, 0.90, 1.0)
$bg.InterpolationColors = $blend
$g.FillRectangle($bg, $rect)
$bg.Dispose()

# Soft corner glows keep the field from reading as a flat fill.
function Add-Glow {
  param([float]$CX, [float]$CY, [float]$R, [System.Drawing.Color]$C, [int]$A)
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddEllipse(($CX - $R), ($CY - $R), ($R * 2), ($R * 2))
  $brush = New-Object System.Drawing.Drawing2D.PathGradientBrush($path)
  $brush.CenterColor = [System.Drawing.Color]::FromArgb($A, $C.R, $C.G, $C.B)
  $brush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, $C.R, $C.G, $C.B))
  $g.FillPath($brush, $path)
  $brush.Dispose()
  $path.Dispose()
}
Add-Glow 240 1160 680 ([System.Drawing.Color]::FromArgb(255, 28, 79, 90)) 62
Add-Glow 3120 1230 760 ([System.Drawing.Color]::FromArgb(255, 52, 64, 69)) 46
Add-Glow 1680 430 980 ([System.Drawing.Color]::FromArgb(255, 16, 80, 96)) 22

$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = [System.Drawing.StringAlignment]::Center
$sf.LineAlignment = [System.Drawing.StringAlignment]::Center
$sf.FormatFlags = $sf.FormatFlags -bor [System.Drawing.StringFormatFlags]::NoWrap

# Badge: gold outlined pill.
$fBadge = New-Object System.Drawing.Font("Microsoft YaHei UI", 45, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$badgeText = "AI 职场 · 01"
$badgeSize = $g.MeasureString($badgeText, $fBadge, [System.Drawing.PointF]::Empty, $sf)
$bw = [int]($badgeSize.Width + 90)
$bh = 83
$bx = [int](($W - $bw) / 2)
$by = 212
$badgePen = New-Object System.Drawing.Pen $gold, 3
$badgePath = New-RoundedPath $bx $by $bw $bh 10
$g.DrawPath($badgePen, $badgePath)
$badgePath.Dispose()
$badgePen.Dispose()
$bGold = New-Object System.Drawing.SolidBrush $gold
$g.DrawString($badgeText, $fBadge, $bGold, (New-Object System.Drawing.RectangleF($bx, $by, $bw, $bh)), $sf)
$fBadge.Dispose()

# Hero title: oversized, white, tightly centered.
$fTitle = New-Object System.Drawing.Font("Microsoft YaHei UI", 192, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$bWhite = New-Object System.Drawing.SolidBrush $white
$g.DrawString("越提效，越累", $fTitle, $bWhite, (New-Object System.Drawing.RectangleF(0, 350, $W, 260)), $sf)
$fTitle.Dispose()

# Subtitle: the full article title.
$fSub = New-Object System.Drawing.Font("Microsoft YaHei UI", 61, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bSub = New-Object System.Drawing.SolidBrush $subColor
$g.DrawString("公司让全员用 AI 提效后，发现自己更累了", $fSub, $bSub, (New-Object System.Drawing.RectangleF(0, 615, $W, 90)), $sf)
$fSub.Dispose()
$bSub.Dispose()

# Keyword line: cyan, flanked by short rules.
$kwText = "省时 · 审核 · 返工 · 加活 · 下班"
$fKw = New-Object System.Drawing.Font("Microsoft YaHei UI", 38, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$bCyan = New-Object System.Drawing.SolidBrush $cyan
$kwSize = $g.MeasureString($kwText, $fKw, [System.Drawing.PointF]::Empty, $sf)
$g.DrawString($kwText, $fKw, $bCyan, (New-Object System.Drawing.RectangleF(0, 770, $W, 60)), $sf)
$fKw.Dispose()

$gap = 42
$ruleLen = 130
$ruleY = 800
$rulePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(190, 128, 192, 192)), 2
$leftEnd = [int](($W / 2) - ($kwSize.Width / 2) - $gap)
$leftStart = [int]($leftEnd - $ruleLen)
$rightStart = [int](($W / 2) + ($kwSize.Width / 2) + $gap)
$g.DrawLine($rulePen, $leftStart, $ruleY, $leftEnd, $ruleY)
$g.DrawLine($rulePen, $rightStart, $ruleY, ($rightStart + $ruleLen), $ruleY)
$rulePen.Dispose()
$bCyan.Dispose()
$bWhite.Dispose()
$bGold.Dispose()

$sf.Dispose()
$g.Dispose()

# Downscale to the 1600x686 cover size used across the article set.
$final = New-Object System.Drawing.Bitmap($FW, $FH)
$fg = [System.Drawing.Graphics]::FromImage($final)
$fg.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$fg.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$fg.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$fg.DrawImage($bmp, 0, 0, $FW, $FH)
$fg.Dispose()
$bmp.Dispose()

$final.Save($OutPng, [System.Drawing.Imaging.ImageFormat]::Png)
$final.Dispose()
Write-Output ("Saved: " + $OutPng)
