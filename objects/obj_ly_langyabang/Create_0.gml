event_inherited();
ly_kind = "langyabang";
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
mouse_id = "longyuan_langyabang";
ly_anims = longyuan_animation_table("langyabang");
hp = 6000; maxhp = 6000; ly_original_hp = 6000;
move_speed = 0.27; atk = 900; atk_cycle = 108;
giant_type = true; immune_to_ash = true; attack_range = 120;
longyuan_move_action = function() { return longyuan_variant("正常行走", "受伤行走"); };
longyuan_attack_action = function() { return longyuan_variant("正常砸东西", "受伤砸东西"); };
longyuan_begin_death = function() { ly_mode = "dead"; target_plant = noone; ly_action = ""; longyuan_play("死亡倒地", true); };
