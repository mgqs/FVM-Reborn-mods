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
hittable_types = ["normal", "air", "invisible", "obstacle", "underground", "dance"];

timer    = 0;
max_life = 600;
has_hit  = false;          // 是否命中过（命中后仍继续直线飞）
hit_tick = 0;

stun_chance = 0;
stun_frames = 0;
kill_normal = false;       // 2 转：秒杀非精英平民鼠

hitted_enemy = ds_list_create();

if (shape == 1)      sprite_index = spr_jingangma_bullet_1;
else if (shape == 2) sprite_index = spr_jingangma_bullet_2;
else                 sprite_index = spr_jingangma_bullet;

image_speed  = 1;
image_xscale = 1.4;
image_yscale = 1.4;
