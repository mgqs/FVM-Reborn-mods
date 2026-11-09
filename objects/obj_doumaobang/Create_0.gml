// obj_doumaobang（逗猫棒 / 金鱼逗猫棒 / 鼠鼠逗猫棒）Create 事件
// 灰烬类·瞬发类·冲撞类（2026-11-07 新卡，照白羊座 / 贪吃兔）
//   🔴 卡面 / 卡槽图标是**猫**（spr_doumaobang_icon），场上放下来的本体是**棒子**（spr_doumaobang）。
//   放置后经过「前摇」召唤猫猫沿本行向右冲撞，随后本体消失。伤害固定 900（同白羊座），不随星级。
event_inherited();

plant_id = "doumaobang";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_doumaobang;
else if (shape == 1) sprite_index = spr_doumaobang_1;
else                 sprite_index = spr_doumaobang_2;

plant_type   = "normal";
feature_type = "normal";
target_type  = "normal";
is_slowdown  = false;
image_speed  = 0;
flash_speed  = 5;

attack_timer = 0;
state        = CARD_STATE.IDLE;

// 动画：全待机，没有攻击段（前摇结束就召猫自毁）
attack_anim = 0;
idle_anim   = sprite_get_number(sprite_index)-1;

// 前摇走技能表 register_card_skill("doumaobang", "前摇", […])，单位秒
var _sk   = variable_instance_exists(id, "skill") ? skill : 0;
var _info = get_plant_data_with_skill("doumaobang", shape, clamp(current_level, 0, 16), _sk);
windup_time = 4.5;   // 兜底 = 技能 0 级
if (_info != undefined && ds_map_exists(_info, "前摇")) windup_time = _info[? "前摇"];
windup_frames = round(windup_time * 60);

windup_t = 0;
spawned  = false;

cat_art_up = 76;          // 猫画在卡片上几像素（猫原点在身体中心，卡片原点在底部）
// 猫猫出生点（2026-11-08 用户口径）：**第 0 列左沿**（玩家这边最左），不再从逗猫棒身上原地冒出来，
//   出来之后沿目标行的走廊向右冲。要贴左沿写 0，想再往场外一点写负数（单位 = 格）。
cat_start_cells = 0;
// 发数：0/1 转 1 只（本行）；二转 3 只 = 上中下三行各 1 只（见 Step_0）
// 命中口径：一转起「伤害对空、地下有效」→ track（普通 + 地下 + 空军），地下在猫的 Step 里单独放行
cat_target_type = (shape >= 1) ? "track" : "normal";
