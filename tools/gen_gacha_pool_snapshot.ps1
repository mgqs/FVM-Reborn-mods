# gen_gacha_pool_snapshot.ps1
# 抽卡卡池总账快照生成器（AGENTS.md §2.5：结论落盘，不许只活在对话里）
# 用法：powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\gen_gacha_pool_snapshot.ps1
# 输出：tools\gacha_pool_snapshot.json
# 口径全部来自代码：slots_init 82 + mod_slots_init 133，去重后为 player_deck。

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $root 'scripts'))) { $root = (Get-Location).Path }

function Read-Gml([string]$rel) {
    $p = Join-Path $root $rel
    if (-not (Test-Path $p)) { throw "缺少文件: $rel" }
    return [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8)
}

$gachaPath = 'scripts\gacha_random_card\gacha_random_card.gml'
$g = Read-Gml $gachaPath

function Get-FnBody([string]$src, [string]$name) {
    $m = [regex]::Match($src, 'function\s+' + [regex]::Escape($name) + '\s*\([^)]*\)\s*\{')
    if (-not $m.Success) { throw "函数未找到: $name" }
    $depth = 0
    for ($k = $m.Index + $m.Length - 1; $k -lt $src.Length; $k++) {
        $c = $src[$k]
        if ($c -eq '{') { $depth++ }
        elseif ($c -eq '}') { $depth--; if ($depth -eq 0) { return $src.Substring($m.Index, $k - $m.Index + 1) } }
    }
    throw "函数体未闭合: $name"
}

function Get-QuotedIds([string]$body) {
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($m in [regex]::Matches($body, '"([a-z0-9][a-z0-9_]*)"')) {
        $v = $m.Groups[1].Value
        if (-not $out.Contains($v)) { [void]$out.Add($v) }
    }
    return $out.ToArray()
}

$excluded  = @(Get-QuotedIds (Get-FnBody $g 'gacha_get_excluded_cards'))
$mapOnly   = @(Get-QuotedIds (Get-FnBody $g 'gacha_is_map_unlock_card'))
$normalIds = @(Get-QuotedIds (Get-FnBody $g 'gacha_is_zodiac_card'))

Write-Host ("排除表 {0} 张（预期 19） / _map_only {1} 张（预期 14） / _normal 名单 {2} 条" -f $excluded.Count, $mapOnly.Count, $normalIds.Count)

function Get-RegisteredCards([string]$rel) {
    $src = Read-Gml $rel
    $ms = [regex]::Matches($src, 'register_card\s*\(\s*"([a-z0-9][a-z0-9_]*)"')
    $res = @()
    for ($i = 0; $i -lt $ms.Count; $i++) {
        $start = $ms[$i].Index
        $end = if ($i + 1 -lt $ms.Count) { $ms[$i + 1].Index } else { $src.Length }
        $block = $src.Substring($start, $end - $start)
        $gold   = ($block -match '"?is_gold"?\s*:\s*1') -or ($block -match '"?is_god"?\s*:\s*1')
        $fusion = ($block -match '"?is_fusion"?\s*:\s*1')
        $res += [pscustomobject]@{ id = $ms[$i].Groups[1].Value; gold = $gold; fusion = $fusion; src = $rel }
    }
    return $res
}

$all = @()
$all += Get-RegisteredCards 'scripts\slots_init\slots_init.gml'
$all += Get-RegisteredCards 'scripts\mod_slots_init\mod_slots_init.gml'

$deck = @{}
foreach ($c in $all) {
    if ($deck.ContainsKey($c.id)) {
        $deck[$c.id].dup = $true
        if ($c.gold)   { $deck[$c.id].gold = $true }
        if ($c.fusion) { $deck[$c.id].fusion = $true }
    } else {
        $deck[$c.id] = [pscustomobject]@{ id = $c.id; gold = $c.gold; fusion = $c.fusion; dup = $false; src = $c.src }
    }
}

function Get-Category($card) {
    if ($excluded -contains $card.id)  { return 'excluded' }
    if ($card.id -eq 'lihe')           { return 'lihe' }
    if ($card.fusion)                  { return 'fusion' }
    if ($card.gold)                    { return 'gold' }
    if ($mapOnly -contains $card.id)   { return 'map_unlock' }
    if ($normalIds -contains $card.id) { return 'normal' }
    return 'zodiac'
}

$rows = @()
foreach ($k in ($deck.Keys | Sort-Object)) {
    $c = $deck[$k]
    $rows += [pscustomobject]@{
        id       = $c.id
        category = (Get-Category $c)
        gold     = [int]$c.gold
        fusion   = [int]$c.fusion
        map_only = [int]($mapOnly -contains $c.id)
        dup      = $c.dup
    }
}

$names = @('excluded','lihe','fusion','gold','map_unlock','normal','zodiac')
$counts = [ordered]@{}
foreach ($name in $names) { $counts[$name] = @($rows | Where-Object { $_.category -eq $name }).Count }
$counts['map_only_all'] = @($rows | Where-Object { $_.map_only -eq 1 }).Count
$counts['total'] = $rows.Count

$snap = [ordered]@{
    generated_at = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    source       = @($gachaPath, 'scripts\slots_init\slots_init.gml', 'scripts\mod_slots_init\mod_slots_init.gml')
    counts       = $counts
    excluded     = $excluded
    map_only     = $mapOnly
    normal_list  = $normalIds
    cards        = $rows
}
$json = $snap | ConvertTo-Json -Depth 6
$out = Join-Path $root 'tools\gacha_pool_snapshot.json'
[System.IO.File]::WriteAllText($out, $json, (New-Object System.Text.UTF8Encoding($false)))

Write-Host ("OK  去重后注册总数 {0}" -f $counts['total'])
Write-Host ("    排除 {0} / lihe {1} / 融合 {2} / 金卡 {3} / 地图解锁 {4} / 普通 {5} / 生肖 {6}" -f `
    $counts['excluded'], $counts['lihe'], $counts['fusion'], $counts['gold'], $counts['map_unlock'], $counts['normal'], $counts['zodiac'])
Write-Host ("    其中 map_only 命中 {0} 张（多半已先被排除表吃掉）" -f $counts['map_only_all'])
$dups = @($rows | Where-Object { $_.dup })
if ($dups.Count -gt 0) { Write-Host ("    同文件重复注册: " + (($dups | ForEach-Object { $_.id }) -join ', ')) }
$sum = 0
foreach ($name in $names) { $sum += $counts[$name] }
Write-Host ("    分类合计 {0} vs 总数 {1} → {2}" -f $sum, $counts['total'], $(if ($sum -eq $counts['total']) { 'PASS' } else { 'FAIL' }))
Write-Host ("    输出 {0}（{1} B）" -f $out, (Get-Item $out).Length)
