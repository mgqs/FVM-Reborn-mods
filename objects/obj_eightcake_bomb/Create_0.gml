// obj_eightcake_bomb（可乐炸弹）Create 事件
// 素材 14 帧：0~6 可乐罐飞行、7~13 爆开的焦糖与碎块。
// 落地对 3*3（本格 ±1 行 ±1 列）内所有老鼠造成固定 900 伤害，非 BOSS / 不免疫灰烬的直接灰烬化。
event_inherited();
can_dandantu_store = false;

sprite_index = spr_eightcake_bomb;
image_speed = 0;              // 自己推帧：按 0.8 自动推进会越过 fly_end，飞到一半就闪出爆炸帧
image_index = 0;
image_angle = 0;
image_alpha = 1;
image_blend = c_white;
image_xscale = 1;
image_yscale = 1;

damage = 900;
row = 0;
col = 0;
sx = x; sy = y;
tx = x; ty = y;
t = 0;
T = 26;
arc = 100;
landed = false;
fly_end = 6;
boom_t = 0;
target_type = "throw";
damage_type = "throw";
hittable_types = ["normal", "air", "invisible"];
