<#
.SYNOPSIS
  一次调用定位一个名字（卡 / 关卡 / 敌人）的全部触点，替代 4~6 次 grep + read。

.DESCRIPTION
  对应 AGENTS.md §0.0「跳读协议」与 INDEX.md。先跑它，再决定要不要打开文件。
  实现：一条 ripgrep（-F 字面量 / --no-ignore / 零递归遍历）扫「已知文件清单」，
  实测 0.14~0.30 s；机器上没有 rg 时自动回落到内建逐行正则（约 1.4 s）。
  不要用 Get-ChildItem -Recurse 找文件：全仓 *.gml 递归实测 15~21 秒。

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File tools\lookup.ps1 xiangshui_god
  powershell -NoProfile -ExecutionPolicy Bypass -File tools\lookup.ps1 cookie_island -Kind level
#>
param(
    [Parameter(Mandatory = $true, Position = 0)][string]$Name,
    [ValidateSet('any', 'card', 'level', 'enemy')][string]$Kind = 'any',
    [int]$Max = 10
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$utf8 = [System.Text.Encoding]::UTF8

function Resolve-Rg {
    $c = Get-Command rg -ErrorAction SilentlyContinue
    if ($c) { return $c.Source }
    $p = Join-Path $env:LOCALAPPDATA 'fvm-tools\rg.exe'
    if (Test-Path $p) { return $p }
    return $null
}

# 卡片链路 / 敌人链路：已知文件清单（一次扫完，不遍历目录）
$CardFiles = @(
    'scripts\mod_cards_init\mod_cards_init.gml',
    'scripts\mod_slots_init\mod_slots_init.gml',
    'scripts\mod_info_island_init\mod_info_island_init.gml',
    'scripts\mod_skill_init\mod_skill_init.gml',
    'scripts\card_buff_category\card_buff_category.gml'
)
$EnemyFiles = @(
    'scripts\mod_enemy_init\mod_enemy_init.gml',
    'scripts\mod_boss_init\mod_boss_init.gml'
)

$rg = Resolve-Rg
$targets = @()
if ($Kind -eq 'any' -or $Kind -eq 'card') { $targets += $CardFiles }
if ($Kind -eq 'any' -or $Kind -eq 'enemy') { $targets += $EnemyFiles }

# 命中缓存  rel -> @('行号: 内容', ...)
$Hits = @{}
if ($rg -and $targets.Count -gt 0) {
    $paths = @()
    foreach ($rel in $targets) {
        $full = Join-Path $root $rel
        if (Test-Path $full) { $paths += $full }
    }
    if ($paths.Count -gt 0) {
        $out = & $rg -n -F --no-heading --with-filename --no-ignore --color never -- $Name @paths
        if ($LASTEXITCODE -le 1) {
            foreach ($line in @($out)) {
                if (-not $line) { continue }
                $m = [regex]::Match([string]$line, '^(.*\.gml):(\d+):(.*)$')
                if (-not $m.Success) { continue }
                $rel = $m.Groups[1].Value
                if ($rel.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
                    $rel = $rel.Substring($root.Length).TrimStart('\')
                }
                if (-not $Hits.ContainsKey($rel)) { $Hits[$rel] = New-Object System.Collections.ArrayList }
                [void]$Hits[$rel].Add(('{0}: {1}' -f $m.Groups[2].Value, $m.Groups[3].Value.Trim()))
            }
        }
    }
}

function Show-Hits([string]$Rel, [string]$Pattern) {
    if ($Hits.ContainsKey($Rel)) {
        $arr = $Hits[$Rel]
        foreach ($h in ($arr | Select-Object -First $Max)) { Write-Host ('  {0}:{1}' -f $Rel, $h) }
        if ($arr.Count -gt $Max) {
            Write-Host ('  {0}: …共 {1} 处（-Max 调整）' -f $Rel, $arr.Count) -ForegroundColor DarkGray
        }
        return
    }
    if ($rg) { return }   # rg 已扫过该文件，没有命中
    $p = Join-Path $root $Rel
    if (-not (Test-Path $p)) { return }
    $lines = [System.IO.File]::ReadAllLines($p, $utf8)
    $hit = @()
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match $Pattern) {
            $hit += ('{0}:{1}: {2}' -f $Rel, ($i + 1), $lines[$i].Trim())
        }
    }
    if ($hit.Count -eq 0) { return }
    foreach ($h in ($hit | Select-Object -First $Max)) { Write-Host "  $h" }
    if ($hit.Count -gt $Max) {
        Write-Host ('  {0}: …共 {1} 处（-Max 调整）' -f $Rel, $hit.Count) -ForegroundColor DarkGray
    }
}

function Show-Dirs([string]$Sub, [string]$Filter, [switch]$SkipEvents) {
    $p = Join-Path $root $Sub
    if (-not (Test-Path $p)) { return }
    $d = Get-ChildItem $p -Directory -Filter $Filter -ErrorAction SilentlyContinue
    foreach ($x in $d) {
        if ($SkipEvents) {
            Write-Host ('  {0}\{1}' -f $Sub, $x.Name)
        } else {
            $ev = (Get-ChildItem $x.FullName -File -Filter '*.gml' -ErrorAction SilentlyContinue |
                   ForEach-Object { $_.Name }) -join ', '
            Write-Host ('  {0}\{1}   [{2}]' -f $Sub, $x.Name, $(if ($ev) { $ev } else { '无 gml' }))
        }
    }
}

Write-Host ('== lookup: {0}   (kind={1}{2}) ==' -f $Name, $Kind, $(if ($rg) { '' } else { ', 无 rg → 回落模式' })) -ForegroundColor Cyan

if ($Kind -eq 'any' -or $Kind -eq 'card') {
    Write-Host '-- 数值（唯一生效源）' -ForegroundColor Yellow
    Show-Hits 'scripts\mod_cards_init\mod_cards_init.gml' ([regex]::Escape($Name))
    Write-Host '-- 槽位显示 / 情报岛 / 技能' -ForegroundColor Yellow
    Show-Hits 'scripts\mod_slots_init\mod_slots_init.gml' ([regex]::Escape($Name))
    Show-Hits 'scripts\mod_info_island_init\mod_info_island_init.gml' ([regex]::Escape($Name))
    Show-Hits 'scripts\mod_skill_init\mod_skill_init.gml' ([regex]::Escape($Name))
    Write-Host '-- 分类表 / 增幅名单' -ForegroundColor Yellow
    Show-Hits 'scripts\card_buff_category\card_buff_category.gml' ([regex]::Escape($Name))
}

if ($Kind -eq 'any' -or $Kind -eq 'enemy') {
    Write-Host '-- 敌人 / BOSS 注册' -ForegroundColor Yellow
    Show-Hits 'scripts\mod_enemy_init\mod_enemy_init.gml' ([regex]::Escape($Name))
    Show-Hits 'scripts\mod_boss_init\mod_boss_init.gml' ([regex]::Escape($Name))
}

if ($Kind -eq 'any' -or $Kind -eq 'level') {
    Write-Host '-- 关卡 JSON' -ForegroundColor Yellow
    $dirs = @('', 'tower', 'volcanic', 'floating', 'cross', 'undersea', 'camp', 'longyuan')
    $found = $false
    foreach ($d in $dirs) {
        $rel = if ($d) { "datafiles\level_data\$d\$Name.json" } else { "datafiles\level_data\$Name.json" }
        if (Test-Path (Join-Path $root $rel)) { Write-Host "  $rel"; $found = $true }
    }
    if (-not $found) { Write-Host '  （未命中同名 JSON；关卡 id 可能带章节前缀）' -ForegroundColor DarkGray }
}

Write-Host '-- 对象 / 精灵（目录级）' -ForegroundColor Yellow
Show-Dirs 'objects' ('obj_' + $Name + '*')
if ($Kind -eq 'any' -or $Kind -eq 'card') { Show-Dirs 'sprites' ('spr_' + $Name + '*') -SkipEvents }

Write-Host '-- 下一步' -ForegroundColor DarkGray
if ($rg) {
    Write-Host '  rg -n -F "<名字>" objects scripts          # 清单外还想扩大范围时用这个（限定目录 < 0.3 s）'
}
Write-Host '  read <上面的文件> offset=<行号-20> limit=60      # 只读相关段' -ForegroundColor DarkGray
