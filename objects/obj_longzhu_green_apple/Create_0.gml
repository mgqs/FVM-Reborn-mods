/// 青苹果：傲慢龙柱把「攻击类」卡片感染成的实体。
/// 接触它的老鼠会被大幅提升体力；到时 / 被打坏后消失。
col = -1;
row = -1;
longzhu_owner = noone;

hp = LONGZHU_GREEN_APPLE_HP;
max_hp = hp;
longzhu_life = 0;

longzhu_anims = longzhu_green_apple_anims();
longzhu_action = "";
longzhu_frame = 0;
longzhu_once = false;
longzhu_timer = 0;

image_speed = 0;
depth = LONGZHU_APPLE_DEPTH_OFFSET;
longzhu_clip_set(id, "出生", true);
