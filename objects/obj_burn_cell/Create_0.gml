// obj_burn_cell（通用的「单格持续灼烧」）Create 事件
// 谁的卡都能用：调用方传 sprite_index / frame_start / frame_end / damage / life。
//   街头烤肉大师：spr_bbq_burn_ground 的 3~16 帧，**存在 2 秒（life 120）、每 60 帧一跳 100（共 200）**
//   8周年蛋糕  ：spr_eightcake_burn_bullet 的第 14~31 帧（落地火），伤害 = 1.5 × 攻击力，老口径（每 6 帧一跳）
// 判定口径：
//   ① single_hit = true → 整个持续时间内每帧扫，格内**每只敌人只吃一次** damage（进 burned 名单）；
//   ② single_hit = false（默认）→ 每 tick_interval 帧结算一跳（烤肉 60 帧 / 蛋糕 6 帧），每跳都结算。
//   命中只认「就是这一格」的敌人（grid_col / grid_row 严格相等，不做 bbox 兜底 ——
//   老鼠贴图很高，相邻行老鼠的头顶会探进本格，用 bbox 会连带烧上下行）；
//   命中类型由调用方给（bbq = 地面单位全烧，空军 / 钻地不烧）；多格可叠加（每个实例独立结算）。
//   击杀一律出灰烬（obj_mouse_ash_death）。
image_speed = 0;
image_index = 0;
image_angle = 0;
image_alpha = 1;
image_blend = c_white;
image_xscale = 1;
image_yscale = 1;

damage = 0;
life = 30;
t = 0;
tick_interval = 6;
frame_start = 0;
frame_end = sprite_get_number(sprite_index) - 1;
// 0 = 老行为（整段帧均匀铺满 life）；> 0 = 按这个帧数循环播（烤肉 2 秒火照样 1 秒一轮，不会放成慢动作）
anim_loop_frames = 0;

target_type = "all";
damage_type = "fire";
hittable_types = ["normal", "air", "invisible"];

grid_col = -1;
grid_row = -1;
// 2026-10-31：调用方可直接锁死格子坐标（放在格子底边时反算会被算成下一行），
//   可选「每只只吃一次」的结算口径，以及给被烧到的鼠挂一只身上燃烧特效
lock_grid = false;
single_hit = false;
mouse_fx_spr = -1;
burned = ds_list_create();
