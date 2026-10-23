damage = 0
move_speed = 0
row = 0
col = 0
shape = 0
damage_type = "pierce"
target_type = "pierce"
attack_timer = 0
image_speed = 0
image_xscale = 1.8;
image_yscale = 1.8;
hittable_types = get_hittable_enemy_types(target_type);
// 喷壶类可命中钻地中的地精鼠（其余地下目标仍不可命中）
array_push(hittable_types, "underground");
hit_tick = 0;