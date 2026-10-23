$ErrorActionPreference = "Stop"
$root = "C:\Users\cbs\Desktop\公众号推文"
$OutputEncoding = [System.Text.Encoding]::UTF8

# ---- build the rename plan: folder -> ordered list of new filenames ----
$plans = @()

$plans += ,@("01_精准深耕系列", @(
  "01_2026-09-18_1737_2026年，普通人的红利不再是暴富，而是「精准深耕」v1.md",
  "02_2026-09-18_1744_2026年，普通人的红利不再是暴富，而是「精准深耕」v2.md",
  "03_2026-09-21_1800_第二章 精准深耕：普通人可直接照搬的落地实操与真实案例.md",
  "04_2026-09-23_0933_第三章 建立壁垒：为什么你深耕了，却依然不赚钱、可被替代.md",
  "05_2026-09-24_1504_第四章 稳态变现：把深耕壁垒，换成持续、可落地的真收入.md",
  "06_2026-09-23_1948_第五章 戒掉内耗：普通人深耕最大的敌人，从来不是能力不足.md"
))

$plans += ,@("02_AI主题", @(
  "09_2026-09-28_1002_普通人如何使用AI赋能自己的行业.md",
  "10_2026-09-28_1012_普通人如何使用AI赋能自己的行业-封面设计.md",
  "11_2026-09-28_1609_AI快速发展的今天，什么更重要.md",
  "12_2026-09-28_1714_普通人别追AI风口：真正稳的逆袭，是把本事练深.md",
  "13_2026-09-30_AI时代守住思考力：别让工具替代大脑.md",
  "14_AI时代背诵默写还有必要保留吗.md",
  "15_AI时代，背诵、默写还有必要保留吗？（个人深度解读）.md",
  "16_普通人如何用AI提高效率：高效的人，从不是靠硬撑.md",
  "17_别让AI替你思考！用AI精进判断力，普通人最靠谱的成长方式.md"
))

$plans += ,@("03_独立文章", @(
  "05_2026-09-23_1948_因为变动，所以幸福.md",
  "08_2026-09-24_1510_为什么碎片时间，才是普通人做副业的王牌？.md"
))

$plans += ,@("05_AI动手手册", @(
  "14_AI动手手册01_有了AI之后，我一天到底省了多长时间.md",
  "15_AI动手手册02_我用AI帮我清了一次手机相册.md",
  "16_AI动手手册03_我用AI试了40多种发型.md",
  "17_AI动手手册04_我用AI分析了一下自己的性格.md"
))

foreach ($plan in $plans) {
  $dir = Join-Path $root $plan[0]
  $i = 0
  foreach ($old in $plan[1]) {
    $i++
    $new = "{0:d2}_{1}" -f $i, ($old -replace '^\d+_', '')
    if ($old -eq $new) { continue }
    Rename-Item -LiteralPath (Join-Path $dir $old) -NewName $new
    Write-Output ("{0}: {1}" -f $plan[0], $new)
  }
}

# ---- fix internal image references (14_ / 15_ prefixes in 05_AI动手手册) ----
$hb = Join-Path $root "05_AI动手手册"
$imgFix = @{
  "_配图/14_AI省了多长时间_封面.png"   = "_配图/01_AI省了多长时间_封面.png"
  "_配图/15_清相册_封面.png"          = "_配图/02_清相册_封面.png"
  "_配图/15_清相册_封面_竖版.png"      = "_配图/02_清相册_封面_竖版.png"
  "_配图/15_清相册_配图1_4312与540.png" = "_配图/02_清相册_配图1_4312与540.png"
}
foreach ($f in Get-ChildItem -LiteralPath $hb -File -Filter *.md) {
  $c = [System.IO.File]::ReadAllText($f.FullName)
  $n = $c
  foreach ($k in $imgFix.Keys) { $n = $n.Replace($k, $imgFix[$k]) }
  if ($n -ne $c) {
    [System.IO.File]::WriteAllText($f.FullName, $n, (New-Object System.Text.UTF8Encoding($false)))
    Write-Output ("fixed refs: " + $f.Name)
  }
}
# rename the image files themselves
foreach ($k in $imgFix.Keys) {
  $p = Join-Path $hb ($k -replace '/','\')
  if (Test-Path -LiteralPath $p) {
    Rename-Item -LiteralPath $p -NewName (Split-Path $imgFix[$k] -Leaf)
    Write-Output ("img -> " + $imgFix[$k])
  }
}
Write-Output "done"