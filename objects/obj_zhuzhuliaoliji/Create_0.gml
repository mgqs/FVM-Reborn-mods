// obj_zhuzhuliaoliji（猪猪料理机 / 猪猪搅拌机 / 猪猪破壁机）Create 事件
// 多向类·海星类：向 5 个方向各射 1 发刀片（±35°、±90°、180°），**没有正前方那一发**；
//   二转每个方向 2 发（共 10 发，错 5 帧）；一转起命中减速 1.5 秒。
// 素材 20 帧：待机 0~12（13 帧）、攻击 13~19（7 帧，第 17 帧脱手）。
// 数值全部走注册表：
//   攻击力       → atk（mod_cards_init，17 档）
//   背面子弹伤害 → custom["背面攻击"]（背面子弹的伤害直接取这个值，所以**天然不吃食神谱加成**）
//   攻击间隔     → cycle（技能 9 档在 mod_skill_init）
event_inherited();
plant_id = "zhuzhuliaoliji";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_zhuzhuliaoliji;
else if (shape == 1) sprite_index = spr_zhuzhuliaoliji_1;
else                 sprite_index = spr_zhuzhuliaoliji_2;

plant_type = "normal";
feature_type = "normal";
target_type = "normal";
is_slowdown = false;
image_speed = 0;

idle_anim   = 12;      // 待机 0~12
attack_anim = 7;       // 攻击 13~19，第 17 帧脱手
flash_speed = 5;

// 背面子弹伤害（0 转 15 → 16 星 225）
var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("zhuzhuliaoliji", shape, clamp(current_level, 0, 16), _sk);
back_atk = 15;
if (_info != undefined && ds_map_exists(_info, "背面攻击")) back_atk = _info[? "背面攻击"];

// 1 转起命中减速；时长走 custom["减速时间"]（秒），改注册表就生效
slow_time = 1.5;
if (_info != undefined && ds_map_exists(_info, "减速时间")) slow_time = _info[? "减速时间"];
slow_frames = (shape >= 1) ? round(slow_time * 60) : 0;

fired_this_attack = false;
// 2 转错帧连发（照炭烧海星）：第一轮当帧出，第二轮隔 burst_gap 帧再出一次 5 方向
//   🔴 原来的做法是「一次造 10 颗，第二颗靠子弹 delay 冻在枪口」，那 5 帧看着就是一颗刀片卡住不动
burst_left  = 0;
burst_timer = 0;
burst_gap   = 5;
