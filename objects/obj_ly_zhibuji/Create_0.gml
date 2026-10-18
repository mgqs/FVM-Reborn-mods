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
// 每损失 15% 血量（首次降到 85/70/55/40/25/10%）各发射一次：6 个一次性阈值旗 + 顺序发射队列
ly_shot_queue = [];
ly_shot_fired = [false, false, false, false, false, false];
ly_shot_thresholds = [0.85, 0.70, 0.55, 0.40, 0.25, 0.10];
// 各阈值对应的发射动作（均为 6 帧段）；70%/40%/10% 档发射时丝线外观随之减少
ly_shot_actions = ["全丝线发射子弹", "破损剩余2份丝线移动", "破损剩余2份丝线移动", "破损剩余1份丝线移动", "破损剩余1份丝线移动", "破损破损剩余1份丝线移动"];
ly_shoot_index = 0;
ly_dodge_cooldown = 0;
ly_original_hp = 100;
can_use_ladder = false;
state = ENEMY_STATE.ACTING;

// 本对象的属性、动作和专属状态。
mouse_id = "longyuan_zhibuji";
ly_anims = longyuan_animation_table("zhibuji");
hp = 3500; maxhp = 3500; ly_original_hp = 3500;
move_speed = 0.3; atk = 10; atk_cycle = 36;
is_vehicle = true; giant_type = true;
longyuan_move_action = function() {
    if (hp > maxhp * 0.7) return "全丝线移动";
    if (hp > maxhp * 0.4) return "剩余2份丝线移动";
    if (hp > maxhp * 0.1) return "剩余1份丝线移动";
    return "破损无丝线移动";
};
longyuan_attack_action = function() { return longyuan_move_action(); };
longyuan_begin_death = function() { ly_mode = "dead"; target_plant = noone; ly_action = ""; longyuan_play("死亡", true); };
