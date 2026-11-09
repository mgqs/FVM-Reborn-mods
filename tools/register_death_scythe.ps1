$ErrorActionPreference = 'Stop'

$P   = 'D:\gameProject\FVM-Reborn-mod'
$f   = Join-Path $P 'scripts\mod_weapons_init\mod_weapons_init.gml'

$enc = New-Object System.Text.UTF8Encoding($false)
$t   = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
Copy-Item $f ($f + '.bak_death_scythe') -Force

# ---------- 1) gods_shield 四颗宝石补 obj ----------
for ($i = 1; $i -le 4; $i++) {
    $oldTok = 'register_gem("gods_shield_gem_' + $i + '",'
    if ($t.Contains($oldTok)) {
        # 找到该 register_gem 块里的 obj: noone
        $start = $t.IndexOf($oldTok)
        $end   = $t.IndexOf('});', $start)
        $seg   = $t.Substring($start, $end - $start)
        if ($seg -match 'obj:\s*noone') {
            $newSeg = $seg -replace 'obj:\s*noone', ('obj: obj_gods_shield_gem_' + $i)
            $t = $t.Substring(0, $start) + $newSeg + $t.Substring($end)
            Write-Host "  gods_shield_gem_$i : obj -> obj_gods_shield_gem_$i"
        } else {
            Write-Host "  gods_shield_gem_$i : 已是具体对象，跳过"
        }
    } else {
        Write-Host "  !! 找不到 gods_shield_gem_$i"
    }
}

# ---------- 2) 插入 death_scythe 武器 + 4 宝石 ----------
if ($t.Contains('register_weapon("death_scythe"')) {
    Write-Host '  death_scythe 已注册，跳过插入'
} else {
    $block = @'
    register_weapon("death_scythe", 
    {
        sprite: spr_death_scythe_icon,
        icon: spr_death_scythe_icon,
        obj: obj_death_scythe_enter,
        slot: "super_weapon",
        allowed_gems: ["death_scythe_gem_1", "death_scythe_gem_2", "death_scythe_gem_3", "death_scythe_gem_4"],
        atk: 200,
        cycle: 900,
        ghost_shape: 0,
        bullet_shape: 0,
        bullet_amount: 1,
        description: "死神镰刀：O形轨迹发射旋转镰刀",
        name: "死神镰刀",
        atk_impact: [260, 300, 340, 380, 440, 500, 560, 640, 720, 800, 900, 950, 1000, 1050, 1100, 1200],
        cycle_impact: [882, 855, 828, 801, 765, 729, 693, 639, 585, 495, 405, 396, 387, 375, 360, 342],
        bullet_amount_impact: [1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4],
        bullet_shape_impact: [0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3],
        ghost_shape_impact: [0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2],
        atk_bonus_impact: [50, 60, 70, 80, 90, 100, 120, 150, 180, 210, 300, 350, 370, 390, 410, 450]
    });
    register_gem("death_scythe_gem_1",
    {
        name: "死神一击",
        description: "死神一击：增加死神镰刀伤害\n[专属宝石]：死神镰刀",
        icon: spr_death_scythe_gem_1,
        slot: "super_weapon",
        obj: obj_death_scythe_gem_1,
        allowed_weapons: ["death_scythe"],
        max_level: 15
    });
    register_gem("death_scythe_gem_2",
    {
        name: "死神收割",
        description: "死神收割：增加死神镰刀攻速\n[专属宝石]：死神镰刀",
        icon: spr_death_scythe_gem_2,
        slot: "super_weapon",
        obj: obj_death_scythe_gem_2,
        allowed_weapons: ["death_scythe"],
        max_level: 15
    });
    register_gem("death_scythe_gem_3",
    {
        name: "死神苏醒",
        description: "死神苏醒：增加死神镰刀子弹数量\n[专属宝石]：死神镰刀",
        icon: spr_death_scythe_gem_3,
        slot: "super_weapon",
        obj: obj_death_scythe_gem_3,
        allowed_weapons: ["death_scythe"],
        max_level: 15
    });
    register_gem("death_scythe_gem_4",
    {
        name: "死神意志",
        description: "死神意志：额外增加死神镰刀攻击并改变子弹形态\n[专属宝石]：死神镰刀",
        icon: spr_death_scythe_gem_4,
        slot: "super_weapon",
        obj: obj_death_scythe_gem_4,
        allowed_weapons: ["death_scythe"],
        max_level: 15
    });
'@

    $anchor = '    register_weapon("gods_shield",'
    $idx = $t.IndexOf($anchor)
    if ($idx -lt 0) { throw '找不到 gods_shield 锚点' }
    $t = $t.Substring(0, $idx) + $block + $t.Substring($idx)
    Write-Host '  已插入 death_scythe 武器 + 4 宝石'
}

[System.IO.File]::WriteAllText($f, $t, $enc)
Write-Host "  mod_weapons_init.gml 已写回（$($t.Length) 字符）"
