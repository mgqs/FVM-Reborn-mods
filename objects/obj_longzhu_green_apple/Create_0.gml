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

// ---------- 目标接口 ----------
// 青苹果要「吸引卡片进攻」，就得进入卡片的敌人扫描体系：注册成 normal 类型目标。
// 注意它不是 obj_enemy_parent，所以不会影响波次存活计数、猫驱赶、BOSS 逻辑。
// 下面是卡片 / 子弹命中流程会直接读的字段（不少实现没有 variable_instance_exists 保护，
// 缺字段会直接报错），一律先给默认值。
target_type = "normal";
mouse_id = "longzhu_green_apple";
is_boss = false;
giant_type = false;
can_dropped = false;
can_use_ladder = false;
grid_col = -1;
grid_row = -1;
maxhp = max_hp;
shield_hp = 0;
state = ENEMY_STATE.NORMAL;
stun_timer = 0;
frozen_timer = 0;
ice_timer = 0;
scare_timer = 0;
is_stun = false;
is_frozen = false;
is_slowdown = false;
is_scare = false;
is_soul = false;
ly_soul = false;
move_speed = 0;
life = 1;
ash_death = true;
special_ash = false;
can_loss = true;
// 青苹果不是「防爆鼠」：灰烬/碾压效果可以正常把它打掉（走自己的 Other_10 扣血）
immune_to_ash = false;
invincible = false;
damage_amount = 0;
damage_type = "normal";
damage_source_object = noone;
damage_source_card_id = "";
longzhu_hit_flash = 0;
longzhu_apple_enemy_register(id);
