# redact_images.ps1
# Crops and mosaic-blurs each stock photo used in "同一条街".
# Removes: place names, phone numbers, street addresses — anything that would
# locate a real business.
#
# Reads pristine originals from _配图\_源图\, writes clean results to _配图\.
# Idempotent — safe to re-run after editing the crop/region values.
#
#   crop    = @(x, y, w, h)  applied first; omit with $null to keep full frame
#   regions = flat list, 5 ints per region: x, y, w, h, blockSize (post-crop coords)
param(
  [string]$Dir = "C:\Users\cbs\Desktop\公众号推文\01_精准深耕系列\_配图"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$plan = @{
  # 棚布上的定做厂标牌 + 手机号
  "图01_单店招牌_红棚布.jpg" = @{ crop = $null; regions = @(290, 578, 165, 118, 8) }

  # 裁掉绿色大招牌（含城市名、"老字号"、菜名）与红色餐车（含地名）
  # 保留的招牌只有食物名，无地名
  "图02_一排单店.jpg" = @{
    crop    = @(500, 505, 730, 680)
    regions = @(48, 172, 100, 48, 6)      # 「冰糖葫芦」招牌底部的电话号码
  }
}

function Add-Mosaic {
  param($g, $bmp, [int]$x, [int]$y, [int]$w, [int]$h, [int]$block)
  $x = [math]::Max(0, [math]::Min($x, $bmp.Width - 1))
  $y = [math]::Max(0, [math]::Min($y, $bmp.Height - 1))
  $w = [math]::Min($w, $bmp.Width - $x)
  $h = [math]::Min($h, $bmp.Height - $y)
  if ($w -le 2 -or $h -le 2) { return }
  $srcRect = New-Object System.Drawing.Rectangle($x, $y, $w, $h)
  $sw = [int][math]::Max([double]1, [math]::Floor(([double]$w) / [double]$block))
  $sh = [int][math]::Max([double]1, [math]::Floor(([double]$h) / [double]$block))
  $small = New-Object System.Drawing.Bitmap($sw, $sh)
  $gs = [System.Drawing.Graphics]::FromImage($small)
  $gs.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $gs.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
  $gs.DrawImage($bmp, (New-Object System.Drawing.Rectangle(0, 0, $sw, $sh)), $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
  $gs.Dispose()
  $gb = [System.Drawing.Graphics]::FromImage($bmp)
  $gb.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
  $gb.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
  $gb.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighSpeed
  $gb.DrawImage($small, (New-Object System.Drawing.Rectangle($x, $y, $w, $h)))
  $gb.Dispose()
  $small.Dispose()
}

foreach ($name in $plan.Keys) {
  $srcPath = Join-Path $Dir ("_源图\" + $name)
  if (-not (Test-Path -LiteralPath $srcPath)) { Write-Output ("SKIP (no pristine copy): " + $name); continue }

  $img = [System.Drawing.Bitmap]::FromFile($srcPath)
  $full = New-Object System.Drawing.Bitmap($img)
  $img.Dispose()

  $c = $plan[$name].crop
  if ($c) {
    $cropped = $full.Clone((New-Object System.Drawing.Rectangle($c[0], $c[1], $c[2], $c[3])), $full.PixelFormat)
    $full.Dispose()
    $bmp = $cropped
  } else {
    $bmp = $full
  }

  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $r = $plan[$name].regions
  for ($i = 0; $i -lt $r.Count; $i += 5) {
    Add-Mosaic $g $bmp $r[$i] $r[$i + 1] $r[$i + 2] $r[$i + 3] $r[$i + 4]
  }
  $g.Dispose()

  $out = Join-Path $Dir $name
  $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Jpeg)
  $bmp.Dispose()
  Write-Output ("Done: " + $out + "  (" + (Get-Item $out).Length + " bytes)")
}