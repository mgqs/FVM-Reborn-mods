// 傀儡马的巫毒代理：继承敌人父类以便被攻击类卡片的索敌/范围攻击命中，
// 但本身无敌、不可见、不移动、不注册、不掉金币；受到的伤害在EndStep转发给绑定老鼠。
event_inherited();

visible = false;
image_alpha = 0;
sprite_index = -1;

move_speed = 0;
move_speed_modify = 1;
atk = 0;
atk_cycle = 99999;

target_type = "normal";
mouse_id = "";
is_boss = false;
giant_type = false;

hp = 1;
maxhp = 1;
helmet_hp = 0;
helmet_max_hp = 0;
shield_hp = 0;
shield_max_hp = 0;
state = ENEMY_STATE.NORMAL;

// 本帧收集到的伤害（User事件0累加，EndStep统一转发）
decoy_pending = 0;
decoy_type = "normal";
decoy_card = noone;
decoy_target = noone;
