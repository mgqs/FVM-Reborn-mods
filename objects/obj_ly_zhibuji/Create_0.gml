event_inherited();
ly_kind = "zhibuji";
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
ly_pending_shots = 0;
ly_damage_accum = 0;
ly_shot_loss = 0.125; // 介绍给出的10%~15%取中值，可调整
ly_dodge_cooldown = 0;
ly_original_hp = 100;
can_use_ladder = false;
state = ENEMY_STATE.ACTING;

// 本对象的属性、动作和专属状态。
mouse_id = "longyuan_zhibuji";
ly_anims = longyuan_animation_table("zhibuji");
hp = 1200; maxhp = 1200; ly_original_hp = 1200;
move_speed = 0.3; atk = 10; atk_cycle = 36;
is_vehicle = true; giant_type = true;
longyuan_move_action = function() {
    if (hp > maxhp * 0.75) return "全丝线移动";
    if (hp > maxhp * 0.5) return "剩余2份丝线移动";
    if (hp > maxhp * 0.3) return "剩余1份丝线移动";
    if (hp > maxhp * 0.15) return "破损剩余1份丝线移动";
    return "破损无丝线移动";
};
longyuan_attack_action = function() { return longyuan_move_action(); };
longyuan_begin_death = function() { ly_mode = "dead"; target_plant = noone; ly_action = ""; longyuan_play("死亡", true); };
