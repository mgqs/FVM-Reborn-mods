event_inherited();
ly_kind = "dijing";
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
mouse_id = "longyuan_dijing";
ly_anims = longyuan_animation_table("dijing");
hp = 500; maxhp = 500; ly_original_hp = 500;
move_speed = 0.9; atk = 10; atk_cycle = 36;
target_type = "underground"; attack_range = -90; ly_mode = "dig";
special_ash = true;
// 防爆：炸弹等秒杀效果只造成伤害。
immune_to_ash = true;
ly_food_surface = false;
// 钻地时撞到的地表卡片，出土后优先啃咬它，避免因站位偏差找不到目标而原地发呆。
ly_food_target = noone;
// 钻地期间是否正被允许的伤害命中（由攻击方按 can_hit 设置，仅当前帧有效）。
// 参照 obj_mole：只有能命中 underground 目标的攻击类型（rotate / d_fruit / all）可以打到钻地状态。
ly_dig_hittable = false;
ly_anims[$ "挖地"] = [spr_dijing_dig, 1, 6];
ly_anims[$ "出土"] = [spr_dijing_apper, 1, 29];
ly_anims[$ "眩晕"] = [spr_dijing_stun, 1, 4];
longyuan_move_action = function() { return longyuan_variant("正常走路", "受伤走路"); };
longyuan_attack_action = function() { return longyuan_variant("正常吃东西", "受伤吃东西"); };
longyuan_begin_death = function() { ly_mode = "dead"; target_plant = noone; ly_action = ""; longyuan_play("倒地", true); };
longyuan_dijing_food_ahead = function() {
    var _bridge = longyuan_bridge_contact(x - 24, y, x + 24, y, grid_row);
    if (instance_exists(_bridge)) return _bridge;
    var _found = noone;
    with (obj_card_parent) {
        if (hp > 0 && grid_row == other.grid_row && abs(x - other.x) <= 50
            && (plant_id == "mixian" || plant_id == "hongliukaochuan")) _found = id;
    }
    return _found;
};
