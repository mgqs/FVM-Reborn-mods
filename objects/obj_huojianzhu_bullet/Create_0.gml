// obj_huojianzhu_bullet（追踪导弹）Create 事件
// 飞行段只播「下落」那几帧（素材 2~4 帧是导弹，5 帧起是爆炸）；命中后由 obj_huojianzhu_boom 播爆炸。
event_inherited();

can_dandantu_store = false;

sprite_index = spr_huojianzhu_bullet;
image_speed  = 0;
image_index  = 1;          // 第 2 帧：导弹本体
image_angle  = 0;
image_alpha  = 1;
image_blend  = c_white;
image_xscale = 1.4;
image_yscale = 1.4;

damage       = 0;
target_enemy = noone;
stun_frames  = 0;
launch_delay = 0;
wave         = 0;
timer        = 0;
max_life     = 300;

// 落点格子（溅射中心；由 obj_huojianzhu/Other_11 传入，下落期间跟着目标更新）
grid_row = 0;
grid_col = 0;

damage_type = "normal";
target_type = "track";
hittable_types = get_hittable_enemy_types("track");

// 导弹帧区间（素材：第 2~4 帧是下落）
fly_frame_from = 1;
fly_frame_to   = 3;
