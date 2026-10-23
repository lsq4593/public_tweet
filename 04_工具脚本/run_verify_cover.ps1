# ASCII-only runner: reads UTF-8 JSON, then calls the cover generator.
$ErrorActionPreference = "Stop"

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$ParamsJson = Join-Path $here "_verify_cover_params.json"
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
