// obj_fashishe_poison_cell（法师蛇 · 毒雾格专用）Create 事件
// 2026-11-08 从通用 obj_burn_cell 拆出来的**独立对象**（同 obj_eightcake_burn_cell 的做法）：
//   以后调 bbq 的火格 / 蛋糕的蜡烛都不会牵连这里，反过来也一样。
//
// 口径（数值基本来自 obj_fashishe 读的注册表 custom，改表即生效）：
//   · 每跳伤害 = **调用方传进来的卡片攻击力 atk**（2026-11-08 起不走 custom["毒雾伤害"]：
//       同 bbq 读攻击表，但**不翻倍**，铺毒当帧现取 → 星级 / 技能 / 平射增幅都吃得到）
//   · 跳数     = custom["毒雾次数"]（默认 5）
//   · 持续     = custom["毒雾持续"] 秒（默认 1s → 60 帧 → 每跳 12 帧）
//   · 命中范围 = 「就是这一格」+ 右边 extra_col_right 格（只有最右一格放宽 1 格 = 场外第 10 格 / BOSS 出生位）
//   · 行必须严格相等（不做 bbox 兜底：老鼠贴图很高，相邻行头顶会探进来，用 bbox 会连带烧上下行）
//   · 命中类型由调用方给（法师蛇 = get_hittable_enemy_types("all")，空军 / 钻地 / 幽灵全吃）
//   · 击杀一律出灰烬（obj_mouse_ash_death）
image_speed = 0;
image_index = 0;
image_angle  = 0;
image_alpha  = 1;
image_blend  = c_white;
image_xscale = 1;
image_yscale = 1;

damage        = 400;
life          = 60;     // 存在帧数（1 秒）
t             = 0;
tick_interval = 12;     // 每跳间隔（1 秒 5 跳）

frame_start = 0;
frame_end   = sprite_get_number(sprite_index) - 1;
anim_loop_frames = 30;  // 贴图 9 帧按 30 帧一轮循环（不会放成慢动作）

target_type  = "all";
damage_type  = "normal";
hittable_types = get_hittable_enemy_types("all");

grid_col = -1;
grid_row = -1;
lock_grid = true;
extra_col_right = 0;    // 只有最右一格由调用方设成 1

// 鼠身紫雾（挂在被毒到的老鼠身上）：缩 2.0 / 抬 90 / 左移 10，存活 16 帧（毒雾 12 帧一跳，刚好接上不叠成一片）
mouse_fx_spr   = spr_fashishe_burn_mouse;
mouse_fx_scale = 2.0;
mouse_fx_y_off = 90;
mouse_fx_x_off = -10;
mouse_fx_life  = 16;

burned = ds_list_create();
