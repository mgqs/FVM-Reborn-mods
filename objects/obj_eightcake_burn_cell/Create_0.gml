// obj_eightcake_burn_cell（8周年蛋糕蜡烛专用火格）
// 从通用的 obj_burn_cell 分出来，免得以后调 bbq 的火格把蛋糕带崩。
// 口径：0.5 秒（life 30）、单格、格内每只老鼠只结算一次 = 蜡烛伤害（1.5 × 攻击力）。
//   贴图 / 起止帧 / 伤害由 obj_eightcake_burn_bullet 传（本体 15~30 帧、一/二转 19~34 帧）。
//   命中只认「就是这一格」的敌人（grid_col / grid_row 严格相等）；击杀一律出灰烬。
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
frame_start = 0;
frame_end = sprite_get_number(sprite_index) - 1;

target_type = "throw";
damage_type = "fire";
hittable_types = get_hittable_enemy_types("throw");

grid_col = -1;
grid_row = -1;
lock_grid = false;
burned = ds_list_create();
