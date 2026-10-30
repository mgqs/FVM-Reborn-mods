event_inherited();
// 敌人基类 Create 会把贴图放大到 1.8 倍（obj_enemy_parent: image_xscale/yscale = 1.8）。
// 朝向翻转必须在这个基准上翻，直接赋 ±1 会把地精缩到原图的 55% 大小。
ly_base_xscale = abs(image_xscale);
ly_base_yscale = abs(image_yscale);
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
// spr_dijing_apper 共 29 帧，但贴图本身把「出土」画了两遍：
//   1-9   从洞里钻出并站好
//   10-17 站立（中间多余的一段）
//   18-26 又从洞里钻出第二遍
// 27-29 站立
// 只取第一段，否则一次出土会看到两次冒头（与贴图美术无关，纯帧范围问题）。
ly_anims[$ "出土"] = [spr_dijing_apper, 1, 9];
ly_anims[$ "眩晕"] = [spr_dijing_stun, 1, 4];
longyuan_move_action = function() { return longyuan_variant("正常走路", "受伤走路"); };
longyuan_attack_action = function() { return longyuan_variant("正常吃东西", "受伤吃东西"); };
longyuan_begin_death = function() { ly_mode = "dead"; target_plant = noone; ly_action = ""; longyuan_play("倒地", true); };
longyuan_dijing_food_ahead = function() {
    var _bridge = longyuan_bridge_contact(x - 24, y, x + 24, y, grid_row);
    // 桥（桥头米线）外面也可能套着护罩，统一走外层解析，避免隔着护罩直接打桥。
    if (instance_exists(_bridge)) return longyuan_outer_card_of(_bridge);
    var _found = noone;
    with (obj_card_parent) {
        if (hp <= 0 || grid_row != other.grid_row || abs(x - other.x) > 50) continue;
        // 能引诱出土的：5 种食物卡，以及外层护罩本身（瓜皮 / 赫拉 / 处女座）。
        // 后者不能漏：护罩罩住的若不是食物卡，只认食物卡会让地精鼠从护罩底下整个穿过去。
        if (longyuan_dijing_is_food_card(plant_id) || plant_type == "shield_outer") _found = id;
    }
    // 被外部保护卡罩住时，出土撞击与后续啃咬都先落到保护卡上，破罩后才轮到内层。
    if (instance_exists(_found)) return longyuan_outer_card_of(_found);
    return noone;
};
