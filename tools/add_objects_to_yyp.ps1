$ErrorActionPreference = 'Stop'

$P   = 'D:\gameProject\FVM-Reborn-mod'
$yyp = Join-Path $P 'FVM_Reborn_makk.yyp'

$names = @(
    'obj_gods_shield_gem_1','obj_gods_shield_gem_2','obj_gods_shield_gem_3','obj_gods_shield_gem_4',
    'obj_poseidon_dart_gun_gem_1','obj_poseidon_dart_gun_gem_2','obj_poseidon_dart_gun_gem_3','obj_poseidon_dart_gun_gem_4',
    'obj_death_scythe','obj_death_scythe_enter','obj_death_scythe_bullet',
    'obj_death_scythe_gem_1','obj_death_scythe_gem_2','obj_death_scythe_gem_3','obj_death_scythe_gem_4'
)

$t = [System.IO.File]::ReadAllText($yyp, [System.Text.Encoding]::UTF8)
$origLen = $t.Length

Copy-Item $yyp ($yyp + '.bak_weapon_objects') -Force

# 已存在的不重复加
$todo = @()
foreach ($n in $names) {
    if ($t -match ('"name":"' + [regex]::Escape($n) + '","path":"objects/')) {
        Write-Host "  跳过（已存在）: $n"
    } else {
        $todo += $n
    }
}
if ($todo.Count -eq 0) { Write-Host '没有需要新增的对象'; exit 0 }

$anchor  = '"resources":['
$idx     = $t.IndexOf($anchor)
if ($idx -lt 0) { throw '找不到锚点 "resources":[' }
$insertAt = $idx + $anchor.Length

$block = "`n"
foreach ($n in $todo) {
    $block += '    {"id":{"name":"' + $n + '","path":"objects/' + $n + '/' + $n + '.yy",},},' + "`n"
}

$t = $t.Insert($insertAt, $block)
[System.IO.File]::WriteAllText($yyp, $t, (New-Object System.Text.UTF8Encoding($false)))

Write-Host "  已注册 $($todo.Count) 个对象"
Write-Host "  yyp: $origLen -> $($t.Length) 字节"
$todo | ForEach-Object { Write-Host "    + $_" }
