event_inherited();
ly_kind = "pingmin";
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
ly_dodge_cooldown = 0;
ly_original_hp = 100;
can_use_ladder = false;
state = ENEMY_STATE.ACTING;

// 本对象的属性、动作和专属状态。
mouse_id = "longyuan_pingmin";
ly_anims = longyuan_animation_table("pingmin");
hp = 200; maxhp = 200; ly_original_hp = 200;
move_speed = 0.32; atk = 10; atk_cycle = 36;

longyuan_move_action = function() { return longyuan_variant("正常行走", "重伤行走"); };
longyuan_attack_action = function() { return longyuan_variant("正常吃东西循环", "重伤吃东西循环"); };
longyuan_begin_death = function() { ly_mode = "dead"; target_plant = noone; ly_action = ""; longyuan_play("倒地", true); };
