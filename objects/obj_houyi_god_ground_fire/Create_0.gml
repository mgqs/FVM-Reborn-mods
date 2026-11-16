// obj_houyi_god_ground_fire（后羿 · 地火格）Create 事件
// 口径照 obj_fashishe_poison_cell（法师蛇毒雾格）：每 tick_interval 帧结算一跳，
//   每跳伤害 = 卡片攻击力（调用方铺火那一刻现取 atk，星级 / 技能 / 增幅都吃得到）。
//   持续 / 跳数由卡片读注册表 custom（灼烧时间 / 灼烧次数）后传进来。
//   命中：行严格相等、列在本格 ~ 本格 + extra_col_right（只有最右一格放宽到第 10 列 / BOSS 出生位）。
//   与 obj_houyi_god_fire（挂在老鼠身上的三昧真火）不是一回事，那个是子弹旧口径，现在不用了。
image_speed = 0;      // 🔴 必须 0：帧由 Step 的 t 推，image_speed = 1 会每步再推一帧，动画翻倍
image_index = 0;
image_angle = 0;
image_alpha = 1;
image_blend = c_white;
image_xscale = 1;
image_yscale = 1;

damage        = 0;
life          = 120;    // 2 秒（120 帧），铺火时由调用方覆盖
t             = 0;
tick_interval = 24;     // 2 秒 5 跳

frame_start = 0;
frame_end   = sprite_get_number(sprite_index) - 1;
anim_loop_frames = 30;  // 贴图按 30 帧一轮循环

// ── 命中判定 ──
target_type      = "all";
damage_type      = "fire";     // 只扣血不吃盾
hittable_types   = get_hittable_enemy_types("all");
grid_col         = -1;
grid_row         = -1;
lock_grid        = true;
extra_col_right  = 0;

// ── 老鼠身上的着火特效（复用 obj_bbq_mouse_burn 跟随器）──
shape          = 0;
mouse_fx_spr   = -1;   // -1 = 按 shape 自动选 spr_houyi_god_fire / _1 / _2 / _3
mouse_fx_scale = 1.8;
mouse_fx_x_off = 0;
mouse_fx_y_off = 50;
mouse_fx_life  = 28;   // 比一跳（24 帧）多 4 帧，接得上又不会叠成一片
