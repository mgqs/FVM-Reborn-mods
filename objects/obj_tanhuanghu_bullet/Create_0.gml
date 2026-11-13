/// 弹簧虎 弹体 Create（本行直线弹，命中后 3*3 溅射，可越过岩浆与障碍）
event_inherited();

damage     = 0;
base_atk   = 0;
move_speed = 11;
row        = 0;
shape      = 0;

// target_type 只是默认值，实际由 obj_tanhuanghu/Other_11 按「这一发打空还是打地」覆写为 air_only / normal
target_type    = "normal";
damage_type    = "pierce";                        // 同参考卡 多拿滋弹体：pierce = 同时打护盾与本体
hittable_types = get_hittable_enemy_types("normal");   // 由 Other_11 覆写为 air_only / normal 派生结果
is_air_volley  = false;                            // true = 对空弹（只打 air）

hit_tick   = 0;
hitted_enemy = noone;
has_hit    = false;

splash_ratio = 0.25;
splash_cells = 1;

if (shape == 1)      sprite_index = spr_tanhuanghu_bullet_1;
else if (shape == 2) sprite_index = spr_tanhuanghu_bullet_2;
else                 sprite_index = spr_tanhuanghu_bullet;

// 2026-11-13：精灵 0~9 帧是飞行、10~14 帧是命中爆炸 → 飞行只循环 0~9，命中后另起一个副本播爆炸
image_speed  = 0;
image_index  = 0;
anim_t       = 0;
is_effect    = false;      // true = 命中特效副本（只播 10~14 帧）
image_xscale = 1.4;
image_yscale = 1.4;
