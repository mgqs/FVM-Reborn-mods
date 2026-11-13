draw_self()
draw_sprite_ext(spr_player_menu_bg_ex, 0, x-2, y-0.8, 0.9, 0.9, 0, c_white, 1)

// ── 卡片情报任务红点：任务栏 / 背包同源（判定见 task_red_dot） ──
// 任务按钮 spr_task_btn：76×110，origin(38,110)，工位 (x-370, y-5)，本对象 0.9 缩放
// 背包按钮 spr_package_btn：78×108，origin(38,108)，工位 (x-45, y-5)
var _dot_task = task_red_dot("task")
var _dot_pack = task_red_dot("package")

if (_dot_task){
	var _tx = x - 370 - 38*0.9 + 68*0.9
	var _ty = y - 5 - 110*0.9 + 26*0.9
	draw_set_colour(c_white)
	draw_circle(_tx, _ty, 12, false)
	draw_set_colour(make_colour_rgb(226, 52, 52))
	draw_circle(_tx, _ty, 9, false)
}
if (_dot_pack){
	var _px = x - 45 - 38*0.9 + 70*0.9
	var _py = y - 5 - 108*0.9 + 24*0.9
	draw_set_colour(c_white)
	draw_circle(_px, _py, 12, false)
	draw_set_colour(make_colour_rgb(226, 52, 52))
	draw_circle(_px, _py, 9, false)
}
draw_set_colour(c_white)
draw_set_alpha(1)
