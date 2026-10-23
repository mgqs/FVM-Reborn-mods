damage = 0;
move_speed = 8;
move_x = move_speed;
move_y = 0;
shape = 0;
target_id = noone;
base_atk = 0;
timer = 0;
max_life = 600;
has_hit = false;
damage_type = "pierce";
target_type = "normal";
hitted_enemy = ds_list_create();
hittable_types = ["normal", "air", "invisible"];
// 喷壶类可命中钻地中的地精鼠（其余地下目标仍不可命中）
array_push(hittable_types, "underground");
image_xscale = 1.6;
image_yscale = 1.6;
