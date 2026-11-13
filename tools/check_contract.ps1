<#
.SYNOPSIS
  工程契约体检：确认 AGENTS.md 与记忆档案在位、是最新的，并打印指纹供 agent 回报「已读取」。

.DESCRIPTION
  对应 AGENTS.md §0.0「开场确认」。任何 agent 会话开始时跑一次，把输出原样贴进第一条回复，
  即可证明读的是当前版本而不是记忆里的旧版。

.PARAMETER Quiet
  只输出 §0.0 规定的那一行（可直接贴进回复）。

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_contract.ps1
#>
param([switch]$Quiet)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$agents = Join-Path $root 'AGENTS.md'

if (-not (Test-Path $agents)) {
    Write-Host "FAIL  AGENTS.md 不存在：$agents" -ForegroundColor Red
    exit 1
}

$bytes = [System.IO.File]::ReadAllBytes($agents)
$text = [System.Text.Encoding]::UTF8.GetString($bytes)
$lines = ($text -split "`n").Count
$lf = ([regex]::Matches($text, "`n")).Count
$bom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
$sha = (Get-FileHash -Algorithm SHA256 $agents).Hash.Substring(0, 12).ToLower()
$ver = if ($text -match 'game_version = "([\d.]+)"') { $Matches[1] } else { '?' }
$sec = ([regex]::Matches($text, '(?m)^#{2,3} ')).Count

$topicsDir = Join-Path $root '.workbuddy\memory\topics'
$topicNames = @('gml-pitfalls.md', 'cards.md', 'enemies-bosses.md', 'levels-maps.md',
                'economy-craft.md', 'info-island-hex.md', 'hex.md', 'fonts.md', 'infected-zhanshen.md')
$missing = @()
foreach ($t in $topicNames) {
    if (-not (Test-Path (Join-Path $topicsDir $t))) { $missing += $t }
}

$skill = Join-Path $root '.dsh\skills\fvm-project-contract\SKILL.md'
$skillOk = Test-Path $skill
$mistakes = Join-Path $root 'MISTAKES.md'
$mkOk = Test-Path $mistakes
$ref = Join-Path $root 'docs\REFERENCE.md'
$refOk = Test-Path $ref
$refLen = if ($refOk) { (Get-Item $ref).Length } else { 0 }
$mkCount = 0
if ($mkOk) {
    $mkText = [System.IO.File]::ReadAllText($mistakes, [System.Text.Encoding]::UTF8)
    $mkCount = ([regex]::Matches($mkText, '(?m)^### [ABCD]\d+ ')).Count
}

$bomText = if ($bom) { '带 BOM（异常）' } else { '无 BOM' }
if ($Quiet) {
    Write-Host ("已读取 AGENTS.md（{0} 行 / {1} B，UTF-8 {2}）— 本次遵守 §1 铁律与 §4 唯一事实源" -f $lf, $bytes.Length, $bomText)
    exit 0
}

Write-Host ''
Write-Host ('=' * 68) -ForegroundColor DarkGray
Write-Host ("已读取 AGENTS.md（{0} 行 / {1} B，UTF-8 {2}）— 本次遵守 §1 铁律与 §4 唯一事实源" -f $lf, $bytes.Length, $bomText) -ForegroundColor Green
Write-Host ('=' * 68) -ForegroundColor DarkGray
Write-Host ("sha256[:12] : {0}" -f $sha)
Write-Host ("game_version: {0}" -f $ver)
Write-Host ("章节数      : {0}  (## / ###)" -f $sec)
Write-Host ("行尾        : LF {0} / CRLF {1}" -f $lf, (([regex]::Matches($text, "`r`n")).Count))
Write-Host ''
if ($missing.Count -eq 0) {
    Write-Host ("记忆档案    : {0}/{0} 在位  (.workbuddy/memory/topics/)" -f $topicNames.Count) -ForegroundColor Green
} else {
    Write-Host ("记忆档案    : 缺 {0} -> {1}" -f $missing.Count, ($missing -join ', ')) -ForegroundColor Yellow
}
Write-Host ("项目技能    : {0}" -f $(if ($skillOk) { '.dsh/skills/fvm-project-contract/SKILL.md OK' } else { '缺失' })) -ForegroundColor $(if ($skillOk) { 'Green' } else { 'Yellow' })
if ($mkOk) {
    Write-Host ("错题本      : MISTAKES.md {0} 条（动手前先扫速查表，出错后补一条）" -f $mkCount) -ForegroundColor Green
} else {
    Write-Host "错题本      : 缺失 -> 新建 MISTAKES.md" -ForegroundColor Yellow
}
if ($refOk) {
    Write-Host ("细节参考    : docs/REFERENCE.md {0} B（按需读，不常驻）" -f $refLen) -ForegroundColor Green
} else {
    Write-Host "细节参考    : 缺失 -> docs/REFERENCE.md" -ForegroundColor Yellow
}
Write-Host ''
Write-Host '把上面第一行原样贴进回复，即完成 §0.0 开场确认。' -ForegroundColor DarkGray
Write-Host ''
