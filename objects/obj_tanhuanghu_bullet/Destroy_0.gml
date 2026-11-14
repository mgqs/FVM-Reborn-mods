/// 弹簧虎 弹体 Destroy（命中后做 3*3 溅射；没命中直接飞出图外则不溅射）
if (!instance_exists(hitted_enemy)) exit;

var _cx = hitted_enemy.x;

with (obj_enemy_parent){
    if (hp <= 0) continue;
    if (id == other.hitted_enemy) continue;
    if (abs(grid_row - other.row) > other.splash_cells) continue;
    if (abs(x - _cx) > global.grid_cell_size_x * 1.5) continue;
    // 2026-11-13：溅射口径**与本体完全一致** —— 直接读类型，不写死列表：
    //   对空弹按 air_only（只认空军）；对地弹按 normal（普通 + 障碍）；
    //   障碍只是被「穿过」、本体不吃伤害，所以溅射这里也跳过它。
    //   原来走 can_hit_ash("pierce", …) → 非主流 / 幽灵 / 障碍全都能吃，凭空变成穿透口径。
    if (!can_target_on(other.is_air_volley ? "air_only" : "normal", target_type)) continue;
    if (target_type == "obstacle") continue;

    damage_amount         = other.damage * other.splash_ratio;
    damage_type           = other.damage_type;
    damage_source_object  = obj_tanhuanghu;
    damage_source_card_id = "tanhuanghu";
    if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
    event_user(0);
    damage_source_card_id = "";
}
