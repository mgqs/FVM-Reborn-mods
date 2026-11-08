// obj_fangkongmiao_bullet（猫猫钢弹）Create 事件
// 追踪空军，命中后造成伤害（一转起附加减速 3 秒）。
event_inherited();

can_dandantu_store = true;

sprite_index = spr_fangkongmiao_bullet;
image_speed  = 0;
image_index  = 0;
image_angle  = 0;
image_alpha  = 1;
image_blend  = c_white;
image_xscale = 1.6;
image_yscale = 1.6;

damage       = 0;
move_speed   = 11;
target_enemy = noone;
slow_frames  = 0;
damage_type  = "normal";
target_type  = "air_only";
hittable_types = get_hittable_enemy_types(target_type);

xstart = x;
ystart = y;
timer  = 0;
max_life = 420;

// 命中特效（素材第 7~17 帧 = 索引 6~16）：命中后先播这一段再销毁，播完约 33 帧（11 帧 × 3 tick）
hitting   = false;
hit_t     = 0;
hit_first = 6;
hit_last  = 16;
