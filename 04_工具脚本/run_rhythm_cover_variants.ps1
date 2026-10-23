# run_rhythm_cover_variants.ps1
# Generates three alternative covers for the "AI 时代不必追赶所有人" article.
# Source file is ASCII-only: every CJK string arrives via _rhythm_cover_variants_params.json.
$ErrorActionPreference = "Stop"

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$ParamsJson = Join-Path $here "_rhythm_cover_variants_params.json"
$raw = [System.IO.File]::ReadAllText($ParamsJson, [System.Text.Encoding]::UTF8)
$p = $raw | ConvertFrom-Json

foreach ($v in @($p.grid.out, $p.paper.out, $p.ledger.out)) {
  $outDir = Split-Path -Parent $v
  if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
}

& "$here\generate_cover_handbook_grid.ps1" `
  -SourceMd $p.sourceMd `
  -OutPng $p.grid.out `
  -Kicker $p.grid.kicker `
  -Subtitle $p.grid.subtitle `
  -CaptionTop $p.grid.captionTop `
  -CaptionBottom $p.grid.captionBottom `
  -LitCol $p.grid.litCol `
  -LitRow $p.grid.litRow

& "$here\generate_cover_handbook_paper.ps1" `
  -SourceMd $p.sourceMd `
  -OutPng $p.paper.out `
  -Kicker $p.paper.kicker `
  -Subtitle $p.paper.subtitle `
  -Rotate $p.paper.rotate

& "$here\generate_cover_handbook_ledger.ps1" `
  -SourceMd $p.sourceMd `
  -OutPng $p.ledger.out `
  -Kicker $p.ledger.kicker `
  -Subtitle $p.ledger.subtitle `
  -PanelHead $p.ledger.panelHead `
  -PanelFoot $p.ledger.panelFoot `
  -Filled $p.ledger.filled `
  -Total $p.ledger.total
