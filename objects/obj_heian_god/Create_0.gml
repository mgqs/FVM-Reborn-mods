event_inherited();

plant_id = "heian_god";
obj_type = object_index;
current_level = 1;

event_user(0);

// 登场 + 待机 sprite
if shape == 0 {
    awake_sprite = spr_dark_god;
    idle_sprite  = spr_dark_turn;
}
else if shape == 1 {
    awake_sprite = spr_dark_god_1;
    idle_sprite  = spr_dark_turn_1;
}
else if shape == 2 {
    awake_sprite = spr_dark_god_2;
    idle_sprite  = spr_dark_turn_2;
}
else if shape == 3 {
    awake_sprite = spr_dark_god_3;
    idle_sprite  = spr_dark_turn_3;
}

// 觉醒控制标志
awakened = false;
awakening_started = false;
target_type = "all";

// 立即开始播放觉醒动画
awakening_started = true;
sprite_index = awake_sprite;
image_speed = 0.5;
image_index = 0;

// 创建领域特效
if shape <= 2 {
    var eff_sprite = -1;
    switch(shape) {
        case 0: eff_sprite = spr_dark_area; break;
        case 1: eff_sprite = spr_dark_area_1; break;
        case 2: eff_sprite = spr_dark_area_2; break;
    }
    var eff = instance_create_depth(x, y, 0, obj_dark_area_e);
    eff.sprite_index = eff_sprite;
    eff.parent_inst = id;
}

// 攻击核心参数
damage = atk;  // 伤害值
is_slowdown = false;
// 攻击间隔计时器
attack_interval_timer = 0;
destroy_timer = 0;
max_time = cycle
cycle = 60
