// obj_eightcake（8周年蛋糕）Create 事件
// 三形态：0 8周年蛋糕（70 帧）/ 1 8周年慕斯（75 帧）/ 2 8周年红丝绒（110 帧）
// 帧段（Step_0 自己推帧，按「本轮丢什么」选段；待机都是 10 帧一循环）：
//   普通轮        待机 0~9   / 挥勺 21~31（25 脱手，26~31 手臂收回）
//   蜡烛轮(3n)    装填 32~34 / 待机 35~44 / 挥勺 56~66（56~59 起手、60 脱手、61~66 收回）
//   炸弹轮(10n)   装填 67~69 / 待机 70~79 / 挥勺 91~101（91~93 起手、94 脱手、95~101 收回）
//   补蛋糕块      本体·一转 67~69，二转 102~104（二转的 67~101 整段是可乐炸弹专用段）
// 数值取自「食神谱金卡融合卡前置补全\基本信息.xlsx」第 309~315 行。
// 机制：单线投手，往**本行最前面那只老鼠身上**投（没有目标才投前方 8 格）。
//       每第 3n 次攻击投「蜡烛子弹」（落地单格 0.5s 灼烧，伤害 = 1.5 × 攻击力，击杀出灰烬）；
//       二转每第 10n 次改投「可乐炸弹」（3*3 范围 900 灰烬爆炸）—— 投炸弹的那一发**不再叠投蛋糕块**。
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
// 攻击计数：第 3n 次换蜡烛子弹、第 10n 次（二转）改投可乐炸弹
eightcake_shot_count = 0;
// 本次攻击是否已经出弹（普通 25 / 蜡烛 60 / 炸弹 94 帧，见 Step_0）
eightcake_fired = false;
// 本轮丢什么：0 普通蛋糕块 / 1 蜡烛 / 2 可乐炸弹（挥勺期间锁定，见 Step_0）
ec_round = 0;
// 动画阶段：0 蛋糕块待机 / 1 装填蜡烛 / 2 蜡烛待机 / 3 补蛋糕块 / 4 装填炸弹 / 5 炸弹待机
ec_phase = 0;
ec_phase_t = 0;
// 灼烧伤害倍率（击杀灰烬的那部分）
eightcake_burn_ratio = 1.5;
// 二转可乐炸弹
eightcake_bomb_damage = 900;

attack_timer = cycle - 40;
