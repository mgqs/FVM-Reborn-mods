$ErrorActionPreference = 'Stop'

$P = 'D:\gameProject\FVM-Reborn-mod'
$f = Join-Path $P 'scripts\mod_shop_init\mod_shop_init.gml'
$enc = New-Object System.Text.UTF8Encoding($false)

$t = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
Copy-Item $f ($f + '.bak_weapon_goods') -Force

# ---------- 1) poseidon 描述更新 ----------
$old = 'description: "海神镖枪：发射两个追踪飞镖攻击敌人",'
$new = 'description: "海神镖枪：连续发射追踪飞镖，可溅射",'
if ($t.Contains($old)) { $t = $t.Replace($old, $new); Write-Host '  poseidon 描述已更新' }

# ---------- 2) 新增商品 ----------
$add = @'

    register_goods("gods_shield",
    {
        type: "weapon",
        cost: "200000",
        unlock_item_id: "gods_shield",
        description: "诸神之盾：增加500生命值，镶嵌宝石时提供增益效果",
        display_name: "诸神之盾"
    });
    register_goods("death_scythe",
    {
        type: "weapon",
        cost: "200000",
        unlock_item_id: "death_scythe",
        description: "死神镰刀：O形轨迹发射旋转镰刀",
        display_name: "死神镰刀"
    });
    register_goods("poseidon_dart_gun_gem_1",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "poseidon_dart_gun_gem_1",
        description: "魔影圣衣：海神镖枪子弹获得溅射伤害",
        display_name: "魔影圣衣"
    });
    register_goods("poseidon_dart_gun_gem_2",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "poseidon_dart_gun_gem_2",
        description: "魔影蛮力：增加海神镖枪伤害",
        display_name: "魔影蛮力"
    });
    register_goods("poseidon_dart_gun_gem_3",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "poseidon_dart_gun_gem_3",
        description: "魔影超刃：增加海神镖枪子弹数量",
        display_name: "魔影超刃"
    });
    register_goods("poseidon_dart_gun_gem_4",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "poseidon_dart_gun_gem_4",
        description: "魔影迅疾：增加海神镖枪攻速",
        display_name: "魔影迅疾"
    });
    register_goods("gods_shield_gem_1",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "gods_shield_gem_1",
        description: "光能之源：生产大量火苗",
        display_name: "光能之源"
    });
    register_goods("gods_shield_gem_2",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "gods_shield_gem_2",
        description: "撕裂之源：撕裂3x3范围内的敌人",
        display_name: "撕裂之源"
    });
    register_goods("gods_shield_gem_3",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "gods_shield_gem_3",
        description: "永恒之源：为5x5范围内的卡片提升攻击力",
        display_name: "永恒之源"
    });
    register_goods("gods_shield_gem_4",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "gods_shield_gem_4",
        description: "生命之源：提升5x5范围内卡片的最大生命值",
        display_name: "生命之源"
    });
    register_goods("death_scythe_gem_1",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "death_scythe_gem_1",
        description: "死神一击：增加死神镰刀伤害",
        display_name: "死神一击"
    });
    register_goods("death_scythe_gem_2",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "death_scythe_gem_2",
        description: "死神收割：增加死神镰刀攻速",
        display_name: "死神收割"
    });
    register_goods("death_scythe_gem_3",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "death_scythe_gem_3",
        description: "死神苏醒：增加死神镰刀子弹数量",
        display_name: "死神苏醒"
    });
    register_goods("death_scythe_gem_4",
    {
        type: "gem",
        cost: "200000",
        unlock_item_id: "death_scythe_gem_4",
        description: "死神意志：额外增加死神镰刀攻击并改变子弹形态",
        display_name: "死神意志"
    });
'@

# 插到 hades_scythe 商品之前，保持武器区集中
$anchor = '    register_goods("hades_scythe",'
$idx = $t.IndexOf($anchor)
if ($idx -lt 0) { throw '找不到 hades_scythe 商品锚点' }

# 已经加过就跳过（幂等）
if ($t.Contains('register_goods("death_scythe",')) {
    Write-Host '  已存在 death_scythe 商品，跳过新增'
} else {
    $t = $t.Substring(0, $idx) + $add + "`n" + $t.Substring($idx)
    Write-Host '  已新增 2 个武器商品 + 12 个宝石商品'
}

[System.IO.File]::WriteAllText($f, $t, $enc)
Write-Host "  mod_shop_init.gml 已写回（$($t.Length) 字符）"
