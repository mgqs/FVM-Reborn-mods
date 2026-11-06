// obj_meiweijishiqi（美味计时器 / 佳肴计时器 / 珍馐计时器）Create 事件
// 辅助类·冷却类：放下 1.5 秒后第一次，之后每 6.5 秒（390 帧）一次，
//   把范围内**正在冷却的实体卡**剩余冷却减去「总冷却 × 缩减比例」
// 数值走注册表：作用时长 → custom["持续"]（技能 9 档在 mod_skill_init 的 duration）；
//   缩减比例 30% / 50% / 50% 照卡面，写死在这里（0/1/2 转）
// 素材 16 帧全待机（0~15）；特效 spr_meiweijishiqi_effect 19 帧挂在脚下
event_inherited();
plant_id = "meiweijishiqi";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_meiweijishiqi;
else if (shape == 1) sprite_index = spr_meiweijishiqi_1;
else                 sprite_index = spr_meiweijishiqi_2;

plant_type = "coffee";        // 冷却类：老鼠不啃、不吃海水（同极寒冰沙）
feature_type = "normal";
is_slowdown = false;
image_speed = 0;

idle_anim   = 15;
attack_anim = 0;
flash_speed = 5;

var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("meiweijishiqi", shape, clamp(current_level, 0, 16), _sk);
life_time = 510;              // 8.5 秒（技能 0 级）
if (_info != undefined && ds_map_exists(_info, "duration")) life_time = _info[? "duration"];

// 缩减比例走 custom["冷却缩减"]（百分数，按形态 30 / 50 / 50）
reduce_pct = 30;
if (_info != undefined && ds_map_exists(_info, "冷却缩减")) reduce_pct = _info[? "冷却缩减"];
reduce_ratio = reduce_pct / 100;

first_delay  = 90;            // 放下 1.5 秒后第一次
exec_gap     = 390;           // 之后每 6.5 秒一次
exec_count   = 0;
exec_timer   = first_delay;
live_timer   = 0;

// 次数（2026-11-06 按 xlsx）：放下 1.5s 第 1 次、之后每 6.5s 一次
//   → 0~7 技能只够 2 次（1.5s、8.0s），8 技能 3 次（1.5s、8.0s、14.5s）
//   存活时长（技能 duration：510~900 帧 = 8.5~15 秒）刚好装得下：2 次在 480 帧、3 次在 870 帧
max_exec = (_sk >= 8) ? 3 : 2;      // 用上面取好的 _sk，避免 skill 未定义时报错

// 显示控制（照 obj_time_god）：平时**整卡隐形**，只在快到执行时播一遍待机动画
//   原来是一直显示，跟时间神那种「冷却期不露头」的观感不一致
image_alpha = 0;
anim_frame  = 0;
anim_tick   = 0;

// 范围：0/1 转 1 格（自身），2 转 3×1（横向 3 格）
range_col = (shape >= 2) ? 1 : 0;
range_row = 0;

var _eff = instance_create_depth(x, y, depth - 20, obj_meiweijishiqi_effect);
if (instance_exists(_eff)){
    _eff.parent_plant = id;
    _eff.image_alpha = 0;          // 跟本体一起隐形，执行前才亮
    if (shape == 1)      _eff.sprite_index = spr_meiweijishiqi_effect_1;
    else if (shape == 2) _eff.sprite_index = spr_meiweijishiqi_effect_2;
}
