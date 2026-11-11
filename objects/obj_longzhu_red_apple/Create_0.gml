/// 红苹果：傲慢龙柱被封印后发射的追踪子弹
longzhu_target = noone;
longzhu_owner = noone;
damage = LONGZHU_RED_APPLE_DAMAGE;
longzhu_life = 0;

longzhu_anims = longzhu_red_apple_anims();
longzhu_action = "";
longzhu_frame = 0;
longzhu_once = false;
longzhu_timer = 0;

image_speed = 0;
depth = LONGZHU_APPLE_DEPTH_OFFSET;
// 贴图放大 2 倍：原精灵 203×206（不透明区约 62×59），相对龙柱本体 287×342 明显偏小。
// 只放大视觉，命中半径仍由 Step_0 的 point_distance <= 26 决定。
image_xscale = 2;
image_yscale = 2;
longzhu_clip_set(id, "旋转待机", true);
