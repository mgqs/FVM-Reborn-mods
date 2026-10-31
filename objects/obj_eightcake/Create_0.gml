// obj_eightcake（8周年蛋糕）Create 事件
// 三形态：0 8周年蛋糕 / 1 8周年慕斯 / 2 8周年红丝绒
// 素材：0shape 70 帧（用户删掉尾部 4 帧后的实际长度）
//      待机 0~20（呼吸循环）；挥勺 21~31（25 勺子挥出、蛋糕块脱手，26~31 手臂收回）
//      装填蜡烛 32~34（两个 8 飞进、落到勺子上）；蜡烛待机 34~59；蜡烛挥勺 60~66（60 脱手）
//      装填蛋糕块 67~69（块飞回勺子）；**2shape（110 帧）的 67~101 是可乐炸弹专用段，暂不播**，
//      它的「蛋糕块回勺」在 **102~104** —— Step 里按 shape 取 `_load_start`，别写死 67
// 数值取自「食神谱金卡融合卡前置补全\基本信息.xlsx」第 309~315 行。
// 机制：单线投手，往**本行最前面那只老鼠身上**投（没有目标才投前方 8 格）。
//       每第 3n 次攻击投「蜡烛子弹」（落地单格 0.5s 灼烧，伤害 = 1.5 × 攻击力，击杀出灰烬）；
//       二转额外每第 10n 次投「可乐炸弹」（3*3 范围 900 灰烬爆炸），与蜡烛子弹相互独立。
event_inherited();
plant_id = "eightcake";
obj_type = object_index;
current_level = 1;
event_user(0);

if (shape == 0) sprite_index = spr_eightcake;
else if (shape == 1) sprite_index = spr_eightcake_1;
else sprite_index = spr_eightcake_2;

idle_anim = 20;
attack_anim = 11;
flash_speed = 4;
plant_type = "normal";
feature_type = "normal";
is_slowdown = false;
attack_type = ATTACK_TYPE.SHOOTER;
target_type = "throw";
state = CARD_STATE.IDLE;

// 投掷：落点 = **本行最前面那只老鼠的实际位置**（Step_0 每帧更新），
//   eightcake_throw_dist 只在没有目标时兜底（投前方 8 格）
eightcake_throw_dist = 8;
eightcake_target_col = -1;
eightcake_target = noone;
// 攻击计数：第 3n 次换蜡烛子弹、第 10n 次（二转）补可乐炸弹
eightcake_shot_count = 0;
// 本次攻击是否已经出弹（普通轮第 25 帧 / 蜡烛轮第 60 帧，见 Step_0）
eightcake_fired = false;
// 动画：本轮是不是「蜡烛轮」（第 3n 发）—— 蜡烛轮用精灵自带的「勺子装着 8」帧段
eightcake_candle_round = false;
// 动画阶段：0 普通待机 / 2 装填蜡烛 / 3 蜡烛待机 / 4 装填（攻击帧由 state 另管）
eightcake_phase = 0;
eightcake_phase_t = 0;
// 灼烧伤害倍率（击杀灰烬的那部分）
eightcake_burn_ratio = 1.5;
// 二转可乐炸弹
eightcake_bomb_damage = 900;

attack_timer = cycle - 40;
