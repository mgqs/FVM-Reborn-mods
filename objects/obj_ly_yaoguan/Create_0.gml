event_inherited();
ly_kind = "yaoguan";
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
ly_fire = LY_YAOGUAN_FIRE_COUNT;  // 减伤用魂火数（3团 → 60% 减伤）
ly_heal_charges = 1;              // 回血次数（用户要求仅触发一次）
ly_dodge_cooldown = 0;
ly_original_hp = 100;
can_use_ladder = false;
state = ENEMY_STATE.ACTING;

// 本对象的属性、动作和专属状态。
mouse_id = "longyuan_yaoguan";
ly_anims = longyuan_animation_table("yaoguan");
hp = 1960; maxhp = 1960; ly_original_hp = 1960;
move_speed = 0.6; atk = 10; atk_cycle = 48;
is_soul = false;
longyuan_move_action = function() { return longyuan_variant("正常前进", "破损前进"); };
longyuan_attack_action = function() { return longyuan_variant("正常啃咬", "破损啃咬"); };
longyuan_begin_death = function() { ly_mode = "dead"; target_plant = noone; ly_action = ""; longyuan_play("死亡", true); };
