$ErrorActionPreference = 'Stop'

$P      = 'D:\gameProject\FVM-Reborn-mod'
$SRC    = 'C:\Users\18203\Desktop\mod97\code'
$encGML = New-Object System.Text.UTF8Encoding($false)

# ================= 1) 覆盖 obj_poseidon_dart_gun 三个事件 =================
function Clean([string]$t) {
    $t = [regex]::Replace($t, '(?sm)^[ \t]*enum\s+UnknownEnum\s*\{.*?\}[ \t]*\r?\n?', '')
    $t = $t -replace 'UnknownEnum\.Value_0', 'CARD_STATE.IDLE'
    $t = $t -replace 'UnknownEnum\.Value_1', 'CARD_STATE.ATTACK'
    return $t
}

$objDir = Join-Path $P 'objects\obj_poseidon_dart_gun'
Copy-Item $objDir (Join-Path $P '.workbuddy\backup\obj_poseidon_dart_gun_old') -Recurse -Force -ErrorAction SilentlyContinue

foreach ($ev in @('Create_0', 'Step_0', 'Other_11')) {
    $srcFile = Join-Path $SRC ('gml_Object_obj_poseidon_dart_gun_' + $ev + '.gml')
    $t = [System.IO.File]::ReadAllText($srcFile, [System.Text.Encoding]::UTF8)
    $t = Clean $t
    if ($ev -eq 'Create_0') {
        # 项目约定：parent_player 初值 noone，由卡片在创建后赋值
        $t = $t -replace 'parent_player\s*=\s*-4;', 'parent_player = noone;'
    }
    [System.IO.File]::WriteAllText((Join-Path $objDir ($ev + '.gml')), $t, $encGML)
    Write-Host "  覆盖 obj_poseidon_dart_gun/$ev.gml"
}

# ================= 2) 改 weapons_init 的 poseidon 定义 =================
$wf = Join-Path $P 'scripts\weapons_init\weapons_init.gml'
$w  = [System.IO.File]::ReadAllText($wf, [System.Text.Encoding]::UTF8)
Copy-Item $wf ($wf + '.bak_poseidon') -Force

$startTok = 'register_weapon("poseidon_dart_gun",{'
$s = $w.IndexOf($startTok)
if ($s -lt 0) { throw '找不到 poseidon 老定义' }
$e = $w.IndexOf('})', $s)
if ($e -lt 0) { throw '找不到 poseidon 老定义结束' }
$e += 2

$newDef = @'
register_weapon("poseidon_dart_gun",{"sprite":spr_poseidon_dart_gun,
										"icon":spr_poseidon_dart_gun_icon,
										"obj":obj_poseidon_dart_gun,
										"slot":"main_weapon",
										"atk":20,
										"cycle":90,
										"bullet_style":0,
										"description":"海神镖枪：发射多个追踪飞镖攻击敌人",
										"name":"海神镖枪",
										"allowed_gems":["poseidon_dart_gun_gem_1","poseidon_dart_gun_gem_2","poseidon_dart_gun_gem_3","poseidon_dart_gun_gem_4"],
										"atk_impact":[50,60,70,80,90,100,110,120,130,140,150,170,190,215,240,270],
										"cycle_impact":[120,116,112,108,104,100,96,92,88,84,80,76,72,68,64,60],
										"bullet_style_impact":[0,0,0,0,0,0,1,1,1,1,2,2,3,3,4,4]
										})
'@
$w = $w.Substring(0, $s) + $newDef + $w.Substring($e)
[System.IO.File]::WriteAllText($wf, $w, $encGML)
Write-Host '  weapons_init.gml 的 poseidon 定义已换成新版'

# ================= 3) 注册 4 个 poseidon 宝石 =================
$mf = Join-Path $P 'scripts\mod_weapons_init\mod_weapons_init.gml'
$m  = [System.IO.File]::ReadAllText($mf, [System.Text.Encoding]::UTF8)

if ($m.Contains('register_gem("poseidon_dart_gun_gem_1"')) {
    Write-Host '  poseidon 宝石已注册，跳过'
} else {
    $gems = @'
    register_gem("poseidon_dart_gun_gem_1",
    {
        name: "魔影圣衣",
        description: "魔影圣衣：海神镖枪子弹获得溅射伤害\n[专属宝石]：海神镖枪",
        icon: spr_poseidon_dart_gun_gem_1,
        slot: "main_weapon",
        obj: obj_poseidon_dart_gun_gem_1,
        allowed_weapons: ["poseidon_dart_gun"],
        splash_ratio: [0.1, 0.13, 0.16, 0.19, 0.21, 0.24, 0.27, 0.3, 0.33, 0.36, 0.4, 0.43, 0.46, 0.49, 0.53, 0.58],
        max_level: 15
    });
    register_gem("poseidon_dart_gun_gem_2",
    {
        name: "魔影蛮力",
        description: "魔影蛮力：增加海神镖枪伤害\n[专属宝石]：海神镖枪",
        icon: spr_poseidon_dart_gun_gem_2,
        slot: "main_weapon",
        obj: obj_poseidon_dart_gun_gem_2,
        allowed_weapons: ["poseidon_dart_gun"],
        max_level: 15
    });
    register_gem("poseidon_dart_gun_gem_3",
    {
        name: "魔影超刃",
        description: "魔影超刃：增加海神镖枪子弹数量\n[专属宝石]：海神镖枪",
        icon: spr_poseidon_dart_gun_gem_3,
        slot: "main_weapon",
        obj: obj_poseidon_dart_gun_gem_3,
        allowed_weapons: ["poseidon_dart_gun"],
        bullet_count: [2, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 6, 6, 7],
        atk_bonus: [0, 15, 20, 25, 30, 35, 10, 15, 20, 25, 10, 25, 35, 10, 40, 30],
        max_level: 15
    });
    register_gem("poseidon_dart_gun_gem_4",
    {
        name: "魔影迅疾",
        description: "魔影迅疾：增加海神镖枪攻速\n[专属宝石]：海神镖枪",
        icon: spr_poseidon_dart_gun_gem_4,
        slot: "main_weapon",
        obj: obj_poseidon_dart_gun_gem_4,
        allowed_weapons: ["poseidon_dart_gun"],
        max_level: 15
    });
'@
    $anchor = '    register_weapon("gods_shield",'
    $idx = $m.IndexOf($anchor)
    if ($idx -lt 0) { throw '找不到 gods_shield 锚点' }
    $m = $m.Substring(0, $idx) + $gems + $m.Substring($idx)
    [System.IO.File]::WriteAllText($mf, $m, $encGML)
    Write-Host '  已注册 4 个 poseidon 宝石'
}
