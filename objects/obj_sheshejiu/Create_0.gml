// obj_sheshejiu（蛇蛇酒 / 仙露蛇蛇酒 / 琼浆蛇蛇酒）Create 事件
// 辅助类·变星类：放下 1.1 秒前摇后，把 3*3 内（含自身格）的实体卡随机升降星，
//   **持续时间（45~80 秒，按技能档位）到点后复原** —— 这是和克洛托最大的区别（克洛托是永久改）
//   0 转 +2/+1/-1/-2 ｜ 1 转再多 ±3 ±4 ｜ 2 转只升不降（卡面「星级只升不降」）
// 数值：变星持续时长 = 技能 9 档（register_card_skill("sheshejiu","升降持续",…)，秒；×60 转帧）；
//   升降星概率表 = 卡面数值，也写在下面
// 素材 20 帧：每形态里都有一个「消散成星星」的空帧（0 转 14 / 1 转 12 / 2 转 3），
//   待机循环避开它 —— 窗口见 ss_anim_from / ss_anim_to
event_inherited();

plant_id = "sheshejiu";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_sheshejiu;
else if (shape == 1) sprite_index = spr_sheshejiu_1;
else                 sprite_index = spr_sheshejiu_2;

plant_type   = "coffee";      // 辅助类：老鼠不啃、不吃海水（同克洛托 / 美味计时器）
feature_type = "normal";
target_type  = "normal";
is_slowdown  = false;
image_speed  = 0;             // 帧自己推
flash_speed  = 5;

// ── 帧段（2026-11-12 用户口径；三形态结构一致）──
//   第 1~11 帧（index 0~10）= 前摇待机，循环
//   第 12~19 帧（index 11~18）= 倒酒（施法演出），只播一次
//   第 20 帧（index 19）= 消散空帧，不播
//   播完 → 从网格移除并隐藏（一次性卡），但实例留到「持续时间」结束做复原
ss_anim_from = 0;
ss_anim_to   = 10;
ss_pour_from = 11;
ss_pour_to   = 18;
ss_anim_i    = ss_anim_from;
ss_anim_tick = 0;
ss_pour_i    = ss_pour_from;
ss_pour_tick = 0;
ss_pouring   = false;         // true = 正在播倒酒段
ss_gone      = false;         // true = 已经移出网格并隐藏
image_index  = ss_anim_i;

// 父对象仍会按 state 推帧，这里把 idle_anim 对齐到自己的窗口上、attack_anim 归零（辅助卡不攻击）
idle_anim   = ss_anim_to;
attack_anim = 0;

// ── 前摇 1.1 秒（xlsx）──
ss_cast_delay = 66;
ss_timer      = 0;
ss_cast_done  = false;
ss_rest_timer = 0;

// ── 变星持续时长：技能 9 档，走 register_card_skill("sheshejiu", "升降持续", [...])（秒）──
//   情报岛文案里的 {升降持续} 直接吃技能值（秒）；custom 里也放了一份基础值给文案兜底
ss_live_frames = 45 * 60;
ss_init_done   = false;

// ── 升降星概率表（按形态；百分数，累加判定）──
//   0 转：+2 10 / +1 30 / -1 45 / -2 15
//   1 转：+4 2 / +3 5 / +2 8 / +1 30 / -1 40 / -2 15
//   2 转：+4 2 / +3 7 / +2 20 / +1 71（只升不降）
if (shape == 1){
    ss_off    = [ 4,  3,  2,  1, -1, -2];
    ss_chance = [ 2,  5,  8, 30, 40, 15];
}
else if (shape >= 2){
    ss_off    = [ 4,  3,  2,  1];
    ss_chance = [ 2,  7, 20, 71];
}
else{
    ss_off    = [ 2,  1, -1, -2];
    ss_chance = [10, 30, 45, 15];
}

// ── 原值快照（到点复原用）：{ inst, lv, pid, col, row } ──
ss_snap = ds_list_create();
