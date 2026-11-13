draw_self()
draw_sprite_ext(spr_player_menu_bg_ex, 0, x-2, y-0.8, 0.9, 0.9, 0, c_white, 1)

// ── 卡片情报任务红点已移到 obj_player_menu_btn/Draw_0 ──
// 原因：按钮实例是 bg 的 depth-1（在 bg 之上），红点原来画在这里会被按钮贴图整个盖掉。
// 现在由按钮自己「先画贴图、再画红点」，红点必然在最上面。判定仍是 task_red_dot("task") / ("package")。
