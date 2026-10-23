event_inherited();
ly_kind = "fuzhou_minion";
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
// 防爆：炸弹等秒杀效果只造成伤害。
immune_to_ash = true;
ly_dodge_cooldown = 0;
ly_original_hp = 100;
ly_owner = noone;
can_use_ladder = false;
state = ENEMY_STATE.ACTING;

// 本对象的属性、动作和专属状态。
mouse_id = "longyuan_fuzhou_minion";
ly_anims = longyuan_animation_table("fuzhou_minion");
hp = 200; maxhp = 200; ly_original_hp = 200;
move_speed = 0.32; atk = 10; atk_cycle = 42;
is_soul = true; ly_mode = "spawn"; longyuan_play("出生", true);
ly_soul = true; target_type = "normal";
longyuan_move_action = function() { return longyuan_variant("正常前进", "破损前进"); };
longyuan_attack_action = function() { return longyuan_variant("正常啃咬", "破损啃咬"); };
longyuan_begin_death = function() { ly_mode = "dead"; target_plant = noone; ly_action = ""; longyuan_play("死亡", true); };
