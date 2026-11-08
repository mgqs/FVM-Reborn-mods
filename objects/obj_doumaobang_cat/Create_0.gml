// obj_doumaobang_cat（召唤出来的猫猫）Create 事件
// 沿本行向右冲，撞飞整行老鼠；撞不飞的（魂系 / BOSS）只吃伤害。冲到「地图右沿 +2 格」消失。
image_speed  = 0;
image_index  = 0;
image_alpha  = 1;
image_blend  = c_white;
image_xscale = 1.6;
image_yscale = 1.6;

grid_row   = 0;
damage     = 900;
move_speed = 10;
target_type = "normal";
hittable_types = get_hittable_enemy_types(target_type);

// 1 转起「伤害对地下有效」：can_target_on 对 underground 只认 rotate / d_fruit，
//   投掷/普通口径里没有 → 这里单独放行（2026-11-08 用户反馈：鼹鼠撞不飞就是因为这条）
hit_underground = false;

hitted = ds_list_create();
life   = 0;

end_x = global.grid_offset_x + global.grid_cols * global.grid_cell_size_x + global.grid_cell_size_x * 2;
