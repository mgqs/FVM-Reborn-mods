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
longzhu_clip_set(id, "旋转待机", true);
