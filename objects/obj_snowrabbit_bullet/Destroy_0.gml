/// 雪球兔 弹体 Destroy：命中后 2 转溅射（3*3 范围 20%）
if (splash_ratio <= 0) exit;
if (!instance_exists(hitted_enemy)) exit;

var _cx = hitted_enemy.x;
var _cy = hitted_enemy.y;
var _crow = hitted_enemy.grid_row;

with (obj_enemy_parent){
    if (hp <= 0) exit;
    if (target_type == "obstacle") exit;
    if (id == other.hitted_enemy) exit;
    if (abs(grid_row - _crow) > other.splash_cells) exit;
    if (abs(x - _cx) > global.grid_cell_size_x * (other.splash_cells + 0.5)) exit;
    if (!can_target_on(other.target_type, target_type)) exit;

    damage_amount         = other.damage * other.splash_ratio;
    damage_type           = other.damage_type;
    damage_source_object  = obj_snowrabbit;
    damage_source_card_id = "snowrabbit";
    if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
    event_user(0);
    damage_source_card_id = "";
}
