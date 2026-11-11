// 对象池复用（obj_pool_acquire → instance_change）不会把 sprite_index 恢复成对象默认精灵：
// 回收时实例在 obj_pool_holder 上已被置成 -1，复用时就把 -1 带进 Draw → 攻击特效完全看不见。
// obj_spicy_pot 的 Other_11 里也没给子弹赋 sprite_index（关东煮那条路径赋了，所以没事）。
// Create 每次复用都会重跑，这里显式指回默认精灵。
sprite_index = spr_spicypot_bullet

damage = 0
move_speed = 8
row = 0
col = 0
start_col = 0
shape = 0
burnt = 0
damage_type = "pierce"
target_type = "pierce"
disabled = false
image_speed = 0
timer = 0

// 复用兜底：上一发可能淡出到接近全透明（disabled 时 image_alpha -= 0.1），
// 或被布丁反弹留下 180° 旋转 / 冰冻染色。Create 不重置就会把脏状态带进新一发。
image_alpha = 1
image_angle = 0
image_blend = c_white

hitted_enemy = ds_list_create()
image_xscale = 1.8;
image_yscale = 1.8;
hittable_types = get_hittable_enemy_types(target_type);
// 喷壶类可命中钻地中的地精鼠（其余地下目标仍不可命中）
array_push(hittable_types, "underground");
hit_tick = 0;