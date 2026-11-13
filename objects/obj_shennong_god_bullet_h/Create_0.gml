damage = 0;
move_speed = 0;
row = 0;
damage_type = "pierce";
target_type = "all";
timer = 0;
shape = 0;
hitted_enemy = ds_list_create();
hittable_types = get_hittable_enemy_types(target_type);
hit_tick = 0;
ash_kill = false;
image_xscale = 1.5;
image_yscale = 1.5;

// 终转（shape 3）专用：按行记录「该行受击次数」。
// 空数组 = 旧行为（只命中 row 这一行，伤害 ×1）。
// 非空时命中任意 row_hits[r] > 0 的行，伤害 = damage × row_hits[r]，
// 用来实现「上中下 5 行分别受击 1/2/3/2/1 次」。
row_hits = [];
