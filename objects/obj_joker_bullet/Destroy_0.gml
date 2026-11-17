/// 恶作剧神 弹体 Destroy（命中后 3x3 溅射；倍率读 splash_ratio，来自 custom["溅射比例"]）
// 溅射范围 = 空中 / 陆地 / 潜水 / 钻地中的地鼠；障碍、幽灵、非主流不吃
var _cx = x;
if (instance_exists(hitted_enemy)) _cx = hitted_enemy.x;

with (obj_enemy_parent)
{
    if (hp <= 0) continue;
    if (id == other.hitted_enemy) continue;
    // 3x3：本行 ±1 行、命中点左右各 1.5 格
    if (abs(grid_row - other.row) > 1) continue;
    if (abs(x - _cx) > global.grid_cell_size_x * 1.5) continue;
    if (target_type != "normal" && target_type != "air" && target_type != "underground" && target_type != "diver") continue;
    if (target_type == "underground" && !is_digging_dijing(id)) continue;

    damage_amount = other.damage * other.splash_ratio;
    damage_type   = other.damage_type;
    if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
    event_user(0);
}
