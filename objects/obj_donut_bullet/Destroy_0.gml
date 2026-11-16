/// 多拿滋 弹体 Destroy（命中后 3×3 溅射）
// 2026-11-17 用户口径：溅射范围 = 空中 / 陆地 / 地下，倍率按形态 0% / 25% / 25%（0 转没有溅射）
if (shape < 1) exit;

var _cx = x;
if (instance_exists(hitted_enemy)) _cx = hitted_enemy.x;

var _splash_ratio = 0.25;

with (obj_enemy_parent)
{
    if (hp <= 0) continue;
    if (id == other.hitted_enemy) continue;
    // 3×3：本行 ±1 行、命中点左右各 1.5 格
    if (abs(grid_row - other.row) > 1) continue;
    if (abs(x - _cx) > global.grid_cell_size_x * 1.5) continue;
    // 只认 空中 / 陆地 / 地下（障碍、幽灵、非主流不吃）
    if (target_type != "normal" && target_type != "air" && target_type != "underground") continue;
    if (target_type == "underground" && !is_digging_dijing(id)) continue;

    damage_amount = other.damage * _splash_ratio;
    damage_type   = other.damage_type;
    event_user(0);
}
