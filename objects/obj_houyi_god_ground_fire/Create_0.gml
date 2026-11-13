// obj_houyi_god_ground_fire（后羿 · 地火格）Create 事件
// 2026-11-13 新增：后羿四形态的**地面火焰**。
//   与 obj_houyi_god_fire（命中单体后挂在老鼠位置的一团三昧真火）不是一回事：
//   这个是**铺在格子上**的地火，每发子弹首次命中时在本行右侧铺 3/5/5/5 格，
//   持续 0.5 秒（30 帧），格内的老鼠挂 0.5 秒身上着火特效，整段只吃**一次** 700 伤害。
//   写法照 obj_fashishe_poison_cell（法师蛇毒雾格）+ obj_burn_cell 的 single_hit 口径，
//   数值/外观全部收在本对象里，调烤肉/法师蛇不会牵到这里。
image_speed = 0;      // 🔴 必须 0：帧由 Step 的 t 推，image_speed = 1 会每步再推一帧，动画翻倍
image_index = 0;
image_angle = 0;
image_alpha = 1;
image_blend = c_white;
image_xscale = 1;
image_yscale = 1;

// ── 数值（用户口径：一次 700，持续 0.5s = 30 帧）──
damage           = 700;
damage_type      = "fire";     // 只扣血不吃盾（obj_enemy_parent/Other_10 的 else 分支）
life             = 30;
t                = 0;
frame_start      = 0;
frame_end        = sprite_get_number(sprite_index) - 1;
anim_loop_frames = 0;          // 0 = 整段 life 把 17 帧播一遍（不循环，末帧正好火散）

// ── 命中判定 ──
target_type      = "all";
hittable_types   = ["normal", "dance", "invisible", "diver", "obstacle", "underground"];
grid_col         = -1;
grid_row         = -1;
lock_grid        = true;       // 铺格时由调用方写死 col/row，不用自身坐标反算
extra_col_right  = 0;
single_hit       = true;       // 格内每只只吃一次（靠 burned 名单记，后进来的也算一次）
burned           = ds_list_create();

// ── 老鼠身上的着火特效（复用法师蛇 / 烤肉的 obj_bbq_mouse_burn 跟随器）──
shape          = 0;
mouse_fx_spr   = -1;   // -1 = 按 shape 自动选 spr_houyi_god_fire / _1 / _2 / _3
mouse_fx_scale = 1.8;
mouse_fx_x_off = 0;
mouse_fx_y_off = 50;
mouse_fx_life  = 30;   // 与地火同为 0.5s
