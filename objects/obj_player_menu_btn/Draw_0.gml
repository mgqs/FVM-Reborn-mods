// 玩家菜单按钮
// Preserve native default drawing while allowing visual-only animation overrides.
// 红点（任务栏 / 背包）画在这里而不是 obj_player_menu_bg：
//   按钮是 bg 的 depth-1（在 bg 之上），红点画在 bg 的 Draw 里就会被按钮贴图盖住。
//   放到按钮自己的 Draw 里 → 同一个实例先 draw_self() 再画红点，红点必然压在按钮上面。
draw_self();

// ── 卡片情报任务红点：任务栏 / 背包同源（判定见 scripts/task_edit 的 task_red_dot）──
// 位置按贴图像素算，自动吃 origin 与 0.9 缩放：
//   任务 spr_task_btn     76×110 origin(38,110) → 红点贴图像素 (68, 26)
//   背包 spr_package_btn  78×108 origin(38,108) → 红点贴图像素 (70, 24)
if (target_screen == "task" || target_screen == "package")
{
    if (task_red_dot(target_screen))
    {
        var _ox = 68;
        var _oy = 26;
        if (target_screen == "package")
        {
            _ox = 70;
            _oy = 24;
        }
        var _cx = x + (_ox - sprite_get_xoffset(sprite_index)) * image_xscale;
        var _cy = y + (_oy - sprite_get_yoffset(sprite_index)) * image_yscale;

        // 只要红点，不要外面那圈白边
        draw_set_colour(make_colour_rgb(226, 52, 52));
        draw_circle(_cx, _cy, 9, false);
        draw_set_colour(c_white);
        draw_set_alpha(1);
    }
}
