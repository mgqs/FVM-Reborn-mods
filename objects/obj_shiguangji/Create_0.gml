// obj_shiguangji（13周年时光机 / 超载时光机 / 未来时光机）Create 事件
// 辅助类·变星类：放下后走「前摇 2.7 → 1.1 秒」（register_card_skill 的「前摇」9 档），
//   到点把范围内（0 转本格 / 1·2 转 3*3）的实体卡随机升降星，**永久生效**，然后自己消失
//   星级上下限 0~16；**范围里一张卡都没作用到 → 清空自身卡槽 CD**（xlsx 备注）
// 概率表（卡面数值，不进 custom）：
//   0 · 1 转：+2 10 / +1 30 / -1 45 / -2 15
//   2 转：+3 5 / +2 20 / +1 35 / -1 20 / -2 15 / -3 5
// 素材 31 帧，全程无空帧 → 整段当待机循环播
event_inherited();

plant_id = "shiguangji";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_shiguangji;
else if (shape == 1) sprite_index = spr_shiguangji_1;
else                 sprite_index = spr_shiguangji_2;

plant_type   = "coffee";      // 辅助类：老鼠不啃、不吃海水
feature_type = "normal";
target_type  = "normal";
is_slowdown  = false;
image_speed  = 0;             // 帧自己推
flash_speed  = 5;

// ── 待机帧：31 帧整段循环 ──
sg_anim_from = 0;
sg_anim_to   = 30;
sg_anim_i    = 0;
sg_anim_tick = 0;
image_index  = 0;

idle_anim   = sg_anim_to;     // 父对象推帧要读，对齐到 31 帧整段
attack_anim = 0;

// ── 前摇：技能 9 档，走 register_card_skill("shiguangji", "前摇", [...]) ──
//   情报岛文案 {前摇} 也吃这份值
sg_cast_delay = 162;
sg_init_done  = false;
sg_timer      = 0;
sg_cast_done  = false;
sg_end_timer  = 0;

// ── 作用范围：0 转本格，1·2 转 3*3 ──
sg_range = (shape >= 1) ? 1 : 0;

// ── 概率表 ──
if (shape >= 2){
    sg_off    = [ 3,  2,  1, -1, -2, -3];
    sg_chance = [ 5, 20, 35, 20, 15,  5];
}
else{
    sg_off    = [ 2,  1, -1, -2];
    sg_chance = [10, 30, 45, 15];
}
