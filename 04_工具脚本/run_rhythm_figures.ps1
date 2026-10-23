# ASCII-only runner: reads UTF-8 JSON, then calls the generators.
$ErrorActionPreference = "Stop"

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$ParamsJson = Join-Path $here "_rhythm_figure_params.json"
$raw = [System.IO.File]::ReadAllText($ParamsJson, [System.Text.Encoding]::UTF8)
$p = $raw | ConvertFrom-Json

$outDir = Split-Path -Parent $p.coverOut
if (-not (Test-Path $outDir)) {
  New-Item -ItemType Directory -Path $outDir | Out-Null
}

& "$here\generate_cover_handbook_fork.ps1" `
  -SourceMd $p.sourceMd `
  -OutPng $p.coverOut `
  -Subtitle $p.subtitle `
  -LeftLabel $p.leftLabel `
  -RightLabel $p.rightLabel `
  -FootLabel $p.footLabel `
  -TitleOverride $p.title `
  -BadgeOverride $p.badge

& "$here\generate_table_three_col.ps1" `
  -OutPng $p.tableOut `
  -Headers $p.tableHeaders `
  -Rows $p.tableRows `
  -HeaderNote $p.tableNote `
  -CornerNote $p.tableFoot `
  -HighlightLast 0 `
  -RowH 148 `
  -Top 90

& "$here\generate_two_ways_figure.ps1" `
  -OutPng $p.waysOut `
  -Header $p.header `
  -LeftTitle $p.leftTitle `
  -RightTitle $p.rightTitle `
  -LeftItems $p.leftItems `
  -RightItems $p.rightItems `
  -Footer $p.footer
