/// 金刚马 弹体 Create（音波：追踪 + 穿透 + 定身 + 二转秒杀平民鼠）
event_inherited();

damage     = 0;
base_atk   = 0;
move_speed = 9;
move_x     = move_speed;
move_y     = 0;
shape      = 0;
row        = 0;
target_id  = noone;

target_type    = "pierce";
damage_type    = "pierce";
hittable_types = ["normal", "air", "invisible"];   // 2026-11-13：与卡面一致，去掉 非主流(dance)/障碍/钻地

timer    = 0;
max_life = 600;
has_hit  = false;          // 是否命中过（命中后仍继续直线飞）
hit_tick = 0;
anim_t   = 0;              // 飞行帧计时（Step 里自推 index 0~5，精灵里后面几帧是命中迸裂）
anim_every = 4;            // 飞行音波每 N 帧换一张（6 帧循环 → 24 帧 ≈ 0.4 秒转一圈；嫌快继续加大）

stun_chance = 0;
stun_frames = 0;
kill_normal = false;       // 2 转：秒杀非精英平民鼠

hitted_enemy = ds_list_create();

// 三形态共用同一张音波（spr_jingangma_bullet），_1/_2 是重复资源、2026-11-13 已删
sprite_index = spr_jingangma_bullet;

image_speed  = 1;
image_xscale = 1.4;
image_yscale = 1.4;
