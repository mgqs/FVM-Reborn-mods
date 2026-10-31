// obj_eightcake_burn_bullet（蜡烛子弹）Create 事件
// 素材 32 帧：0~13 是蓝色 8 蜡烛飞行、14 是落地过渡、**15~30 是地上燃烧的火**（31 空帧）。
// 飞行段自己推帧循环 0~13；落地生成 obj_burn_cell 播 15~30，做 0.5s 单格灼烧
// （伤害 = 1.5 × 攻击力，击杀出灰烬；格子用 lock_grid 锁死，别按坐标反算）。
event_inherited();
can_dandantu_store = false;

sprite_index = spr_eightcake_burn_bullet;
image_speed = 0;              // 自己推帧（见 Step_0），避免越过 fly_end 闪出燃烧帧
image_index = 0;
image_angle = 0;
image_alpha = 1;
image_blend = c_white;
image_xscale = 1.5;     // 投出去的蜡烛放大一点（用户反馈太小）
image_yscale = 1.5;

damage = 0;
raw_atk = 0;
row = 0;
col = 0;
sx = x; sy = y;
tx = x; ty = y;
t = 0;
T = 26;
arc = 90;
landed = false;
fly_end = 13;
burn_start = 15;
fly_anim_speed = 0.7;
target_type = "throw";
damage_type = "fire";
