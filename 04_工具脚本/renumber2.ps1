$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.Encoding]::UTF8
$root = "C:\Users\cbs\Desktop\公众号推文"

# Remaining renames, matched on the actual file objects (not hardcoded strings).
$todo = @{
  "02_AI主题" = @("14_AI时代背诵默写还有必要保留吗", "15_AI时代，背诵、默写还有必要保留吗？（个人深度解读）", "16_普通人如何用AI提高效率", "17_别让AI替你思考")
  "03_独立文章" = @("01_因为变动", "02_为什么碎片时间")
  "05_AI动手手册" = @("01_AI动手手册01", "02_AI动手手册02", "03_AI动手手册03", "04_AI动手手册04")
}

foreach ($dirName in $todo.Keys) {
  $dir = Join-Path $root $dirName
  $files = Get-ChildItem -LiteralPath $dir -File -Filter *.md | Sort-Object Name
  $i = 0
  foreach ($f in $files) {
    $i++
    $new = "{0:d2}_{1}" -f $i, ($f.Name -replace '^\d+_', '')
    if ($f.Name -eq $new) { continue }
    $target = Join-Path $dir $new
    if (Test-Path -LiteralPath $target) {
      Write-Output ("SKIP (target exists): " + $new)
      continue
    }
    [System.IO.File]::Move($f.FullName, $target)
    Write-Output ("{0}: {1}" -f $dirName, $new)
  }
}
Write-Output "done"