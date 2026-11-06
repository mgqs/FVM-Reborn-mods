// obj_tanchitu_rabbit（冲撞的兔子）Create：沿列**自上往下**跑，穿透整列
//   2026-11-06 用户口径：动画是从上往下跑过来的（原来是从最底行往上）。方向由 obj_tanchitu 写入。
image_speed = 0;
image_index = 0;
image_alpha = 1;
image_blend = c_white;
image_xscale = 1.7;
image_yscale = 1.7;

grid_col = 0;
damage = 0;
move_speed = 9;
hitted = ds_list_create();
life = 0;
bottom_y = global.grid_offset_y + global.grid_rows * global.grid_cell_size_y + 200;   // 跑到这条线就回收
