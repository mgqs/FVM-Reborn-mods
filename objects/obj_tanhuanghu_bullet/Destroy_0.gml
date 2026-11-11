/// 弹簧虎 弹体 Destroy（命中后做 3*3 溅射；没命中直接飞出图外则不溅射）
if (!instance_exists(hitted_enemy)) exit;

var _cx = hitted_enemy.x;

with (obj_enemy_parent){
    if (hp <= 0) continue;
    if (id == other.hitted_enemy) continue;
    if (abs(grid_row - other.row) > other.splash_cells) continue;
    if (abs(x - _cx) > global.grid_cell_size_x * 1.5) continue;
    // 溅射可同时命中空中 / 地面 / 地下
    if (!can_hit_ash("pierce", target_type)) continue;

    damage_amount         = other.damage * other.splash_ratio;
    damage_type           = other.damage_type;
    damage_source_object  = obj_tanhuanghu;
    damage_source_card_id = "tanhuanghu";
    if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
    event_user(0);
    damage_source_card_id = "";
}
