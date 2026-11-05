// obj_dianman（美味电鳗 / 变异美味电鳗 / 霸王美味电鳗）Create 事件
// 灰烬类·持续类：范围内每秒结算 atk（总伤害 = atk × 持续秒数），
//   范围内一切非 BOSS 定身 2 秒（每秒刷新）；持续时长到了就淡出消失。
// 素材 29 帧：待机 0~16、放电 17~28；特效 spr_dianman_effect 13 帧铺在范围上
// 范围：0/1 转 3×3、2 转 3×5（横 3 竖 5）
// 数值：atk（17 档）、持续时长 → 技能表 duration（mod_skill_init）
event_inherited();
plant_id = "dianman";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_dianman;
else if (shape == 1) sprite_index = spr_dianman_1;
else                 sprite_index = spr_dianman_2;

plant_type = "normal";
feature_type = "normal";
target_type = "rotate";
is_slowdown = false;
image_speed = 0;

// 素材 29 帧，按用户 2026-11-06 给的分段：
//   0~13  = 待机（第 1~14 帧）
//   14~28 = 攻击段（第 15~29 帧）：15~23 蓄力、**24 开始放电**、24~29 是放电那 6 帧
idle_anim   = 13;
attack_anim = 15;
flash_speed = 5;

// 卡片动画（自己管，不走父对象的两段状态机）：一轮 60 帧
//   前 45 帧待机 0~13 循环（3 帧/张），后 15 帧播攻击段 14~28（1 帧/张）
//   其中 index 23 = 卡片第 24 帧 = **放电那一帧**
anim_t        = 0;
anim_idle_max = 45;      // 前多少帧走待机
atk_start     = 14;      // 攻击段起始 index

// 伤害判定跟**脚下电弧特效**（spr_dianman_effect，13 帧）走（2026-11-06 用户口径）：
//   电弧循环到第 6 帧（image_index 5）那一下结算 atk + 定身
//   电弧 4 帧/张 × 13 帧 = 52 帧一轮，所以大约 0.87 秒结算一次
fx_fire_frame = 5;       // 电弧第 6 帧（index 5）→ 出伤害
fx_start_frame = 54;     // 本体第 anim_t=54 帧（= 卡片 index 23 放电那一帧）时点亮电弧
fx_last_index = -1;      // 上一帧电弧的 image_index，用来「只在刚跳到第 6 帧时结算一次」

var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("dianman", shape, clamp(current_level, 0, 16), _sk);
life_time = 600;                       // 技能 0 级 10 秒（技能表 duration 覆盖）
if (_info != undefined && ds_map_exists(_info, "duration")) life_time = _info[? "duration"];

live_timer = 0;
range_col = 1;
range_row = (shape >= 2) ? 2 : 1;
stun_frames = 120;

// 范围特效在 Step 首帧生成（Create 时 grid_col / grid_row 还没赋值）
fx_list = [];
fx_spawned = false;
