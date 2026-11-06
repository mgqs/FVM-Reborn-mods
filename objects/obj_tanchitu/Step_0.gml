if (global.is_paused) exit;
event_inherited();

if (spawned) exit;

windup_t++;
if (windup_t < windup_frames) exit;

spawned = true;

// 冲撞的列（照方案：0 转第 8 列；1 转第 7·8 列；2 转第 7·8·9 列）
//   🔴 2026-11-06 修：列号是 **0 起算**（最后一列 = grid_cols-1）。
//     原来写 grid_cols-1 / grid_cols 整体偏了一列，1·2 转那颗兔子还生成到「场外第 10 列」去了，
//     跑完整列一格都撞不到。现在按 1 起算的「第 N 列」= grid_cols - (grid_cols - N + 1) 换算好。
var _cols = [global.grid_cols - 2];                                                   // 第 8 列
if (shape == 1)      _cols = [global.grid_cols - 3, global.grid_cols - 2];             // 第 7·8 列
else if (shape >= 2) _cols = [global.grid_cols - 3, global.grid_cols - 2, global.grid_cols - 1]; // 第 7·8·9 列

for (var _i = 0; _i < array_length(_cols); _i++){
    var _c = clamp(_cols[_i], 0, global.grid_cols - 1);
    // 2026-11-06 用户口径：兔子是**从上往下**跑过来的（原来从最底行往上跑，方向反了）
    //   出生点在场上沿（第 1 行）上方，终点是最后一行下方
    var _top = get_world_position_from_grid(_c, 0);
    var _bot = get_world_position_from_grid(_c, global.grid_rows - 1);
    var _r = instance_create_depth(_top.x, _top.y - 120, depth - 500, obj_tanchitu_rabbit);
    _r.grid_col = _c;
    _r.damage = atk;
    _r.move_speed = 9;
    _r.bottom_y = _bot.y + 120;
    if (shape == 1)      _r.sprite_index = spr_tanchitu_bullet_1;
    else if (shape == 2) _r.sprite_index = spr_tanchitu_bullet_2;
}

instance_destroy();
