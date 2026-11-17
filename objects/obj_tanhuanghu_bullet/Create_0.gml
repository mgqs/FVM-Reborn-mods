/// 弹簧虎 弹体 Create（本行直线弹，命中后 3*3 溅射，可越过岩浆与障碍）
event_inherited();

damage     = 0;
base_atk   = 0;
move_speed = 11;
row        = 0;
shape      = 0;

// 子弹是 air 类型：陆地 + 空军都打（「优先对空」在卡片的炮口高度上做）
target_type    = "air";
damage_type    = "pierce";                        // 同参考卡 多拿滋弹体：pierce = 同时打护盾与本体
hittable_types = get_hittable_enemy_types("air");       // 由 Other_11 覆写：air = 陆地 + 空军

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
image_xscale = 1.4;        // 素材 126×122 → 176×171：视觉大小按用户口径保留 1.4（跨行已由 grid_row 过滤兜住）
image_yscale = 1.4;
