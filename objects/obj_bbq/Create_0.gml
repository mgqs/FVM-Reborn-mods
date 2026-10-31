// obj_bbq（街头烤肉大师）Create 事件
// 三形态：0 街头烤肉大师 / 1 户外烤肉大师 / 2 BBQ烤肉大师
// 素材：0shape / 1shape / 2shape 各 22 帧
//       **待机 0~12，攻击 13~21**（13~16 串串顶出、17~18 最长、19~21 回落）
//       父对象按 idle_anim / attack_anim 划段：IDLE 走 0~12，ATTACK 走 13~21
// 数值取自「食神谱金卡融合卡前置补全\基本信息.xlsx」第 216~222 行（街头烤肉大师那一段）。
// 机制：沿本行向右发射穿透串串子弹；每第 2 发换成爆辣烤串，并在该行最右 1 格留下 0.5s 灼烧（200 物理伤害）。
//       一转 +1 发子弹（单行 2 发）；二转同时在上下三路各发。
event_inherited();
plant_id = "bbq";
obj_type = object_index;
current_level = 1;
event_user(0);

if (shape == 0) sprite_index = spr_bbq;
else if (shape == 1) sprite_index = spr_bbq_1;
else sprite_index = spr_bbq_2;

idle_anim = 12;
attack_anim = 9;
flash_speed = 5;
plant_type = "normal";
feature_type = "normal";
is_slowdown = false;
attack_type = ATTACK_TYPE.SHOOTER;
target_type = "normal";
state = CARD_STATE.IDLE;

// 单行子弹数恒为 1；一转的强化改成**伤害翻倍**（见前置表「已优化帧率」：一转攻击表 = 0 转 ×2，
//   数值已经在 mod_cards_init 的 atk 表里，不再额外补一发子弹）
bbq_per_row = 1;
bbq_rows = (shape >= 2) ? 3 : 1;
bbq_shot_count = 0;
bbq_burn_damage = 100;      // 灼烧区每秒一跳 100（区存在 2 秒 = 共 200，见 Other_11）
// 本次攻击是否已经出弹（攻击动画第 17 帧出一次，见 Step_0）
bbq_fired = false;

// 开局不要等满一个冷却
attack_timer = cycle - 30;
