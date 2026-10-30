// obj_eightcake_bullet（蛋糕子弹）Create 事件
// 抛物线点到点飞行：起点 sx/sy、落点 tx/ty 由卡片在开火时算好，飞行 T 帧后落地结算。
// 落地对该格内所有陆、空、幽灵鼠造成 damage 点伤害。
event_inherited();
can_dandantu_store = false;

sprite_index = spr_eightcake_bullet;
image_speed = 0;              // 自己推帧（见 Step_0）：精灵最后 1 帧是空帧，按 image_speed 递增会「飞到一半消失」
image_index = 0;
fly_end = 16;                 // 0~16 是飞行段（17 是空帧；三形态贴图都是 18 帧）
fly_anim_speed = 0.7;
image_angle = 0;
image_alpha = 1;
image_blend = c_white;
image_xscale = 1.5;     // 投出去的蛋糕块放大一点（用户反馈太小）
image_yscale = 1.5;

damage = 0;
row = 0;
col = 0;
sx = x; sy = y;
tx = x; ty = y;
t = 0;
T = 26;
arc = 90;
landed = false;
hit_tick = 0;
target_type = "throw";
damage_type = "throw";
hittable_types = ["normal", "air", "invisible"];
