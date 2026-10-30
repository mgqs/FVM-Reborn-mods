event_inherited();
ly_kind = "longmu";
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
ly_egg = true;
ly_dodge_cooldown = 0;
ly_original_hp = 100;
can_use_ladder = false;
state = ENEMY_STATE.ACTING;

// 本对象的属性、动作和专属状态。
mouse_id = "longyuan_longmu";
ly_anims = longyuan_animation_table("longmu");
hp = 200; maxhp = 200; ly_original_hp = 200;
move_speed = 0.36; atk = 10; atk_cycle = 36;
shield_hp = 80; shield_max_hp = 80;
longyuan_move_action = function() { return ly_egg ? longyuan_variant("正常有蛋前进", "破损有蛋前进") : longyuan_variant("正常无蛋前进", "破损无蛋前进"); };
longyuan_attack_action = function() { return ly_egg ? longyuan_variant("正常有蛋啃咬", "破损有蛋啃咬") : longyuan_variant("正常无蛋啃咬", "破损无蛋啃咬"); };
longyuan_begin_death = function() { ly_mode = "dead"; target_plant = noone; ly_action = ""; longyuan_play("死亡", true); };
