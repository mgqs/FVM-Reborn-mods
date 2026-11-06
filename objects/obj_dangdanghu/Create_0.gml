// obj_dangdanghu（铛铛虎 / 速热铛铛虎 / 微波铛铛虎）Create 事件
// 投掷类·灼烧投手：向射程 4 格内的本行敌人投高温糕饼，落点 3×3 连环灼烧
//   0/1 转 = 3×3 十字（中心 + 上下左右）；2 转 = 3×3 方块（9 格）
//   每轮 10 跳 × 0.2 秒（12 帧一跳），每跳 = 攻击力 / 10
// 素材 35 帧：待机 0~16、投掷 17~25（第 21 帧脱手）、收手 26~34 再回待机
// 数值：atk（0/1 转共用本体表、2 转用一转表，见 mod_cards_init）、cycle（技能 9 档）
event_inherited();
plant_id = "dangdanghu";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_dangdanghu;
else if (shape == 1) sprite_index = spr_dangdanghu_1;
else                 sprite_index = spr_dangdanghu_2;

plant_type = "normal";
feature_type = "normal";
target_type = "throw";
is_slowdown = false;
image_speed = 0;

// 素材 35 帧，按用户 2026-11-06 给的实际分段：
//   0~10  = 待机（11 帧）
//   11~34 = 抬手 → 第 18 帧（image_index 17）投出 → 收手回到待机
idle_anim   = 10;      // 待机 0~10
attack_anim = 24;      // 投掷段 11~34（24 帧）
flash_speed = 5;
fire_frame  = 17;      // 第 18 帧脱手（24×5=120 帧动画，cycle 最低 132 帧装得下）

// 灼烧节奏走注册表 custom：{每跳间隔} 秒 / {跳数} 次
var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("dangdanghu", shape, clamp(current_level, 0, 16), _sk);
tick_seconds = 0.2;
tick_count   = 10;
if (_info != undefined){
    if (ds_map_exists(_info, "每跳间隔")) tick_seconds = _info[? "每跳间隔"];
    if (ds_map_exists(_info, "跳数"))     tick_count   = _info[? "跳数"];
}

fired_this_attack = false;
