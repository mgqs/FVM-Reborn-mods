event_inherited();
ly_kind = "gaoqiao";
ly_anims = {};
ly_action = "";
ly_frame = 0;
ly_done = false;
ly_once = false;
ly_hit = false;
ly_mode = "walk";
ly_cooldown = 0;
is_soul = false;
invincible = false;
is_vehicle = false;
ly_wind_multiplier = 1.5; // 未给定风力倍率
ly_fan = true;
ly_dodge_cooldown = 0;
ly_dance_cooldown = 0;
ly_original_hp = 100;
can_use_ladder = false;
state = ENEMY_STATE.ACTING;

// 本对象的属性、动作和专属状态。
mouse_id = "longyuan_gaoqiao";
ly_anims = longyuan_animation_table("gaoqiao");
hp = 170; maxhp = 170; ly_original_hp = 170;
move_speed = 0.9; atk = 10; atk_cycle = 42;
target_type = "air";
longyuan_move_action = function() { return longyuan_variant("正常移动", "破损移动"); };
longyuan_attack_action = function() { return longyuan_variant("正常啃咬", "破损啃咬"); };
longyuan_begin_death = function() { ly_mode = "dead"; target_plant = noone; ly_action = ""; longyuan_play("死亡", true); };
