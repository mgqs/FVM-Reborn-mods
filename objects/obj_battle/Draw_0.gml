// 关卡背景：默认按原尺寸画在左上角；关卡 JSON 里给了 bg_draw 时按其缩放/偏移绘制
// （跨服·梦魇天空的底图是 1109×597 半尺寸图，需要还原到 9*107 × 7*116 的格子区）
if (variable_struct_exists(global.level_file, "bg_draw")){
	var _bg_draw = global.level_file.bg_draw;
	// bg_draw 是把「美术格线」钉死在逻辑网格上的精确缩放（sx = 107 / 美术格距），
	// 它不负责铺满屏幕，四边会露出十几像素没有图，而房间本身 clearViewBackground = false，
	// 露出来的就是脏像素。
	//
	// 补边统一用「取原图边缘 1 像素拉成条带」，条带与精确份共用同一条格线，所以不会重影。
	// 旧写法在这里按 cover 比例把整张图再画一遍（缩放 1.8090 vs 1.7833、水平错开 56 px），
	// 底图里的云与障碍就各出现两次 —— 梦魇天空「两层云」正是这么来的，与云事件无关。
	var _spr = global.level_data.level_sprite;
	var _idx = map_spr_index;
	var _bg_w = sprite_get_width(_spr);
	var _bg_h = sprite_get_height(_spr);
	if (_bg_w > 0 && _bg_h > 0){
		var _sx = _bg_draw.sx;
		var _sy = _bg_draw.sy;
		var _x0 = _bg_draw.x;
		var _y0 = _bg_draw.y;
		var _w = _bg_w * _sx;
		var _h = _bg_h * _sy;
		var _x1 = _x0 + _w;
		var _y1 = _y0 + _h;
		// 左右两条竖带：源为最左 / 最右 1 像素列
		if (_x0 > 0) draw_sprite_part_ext(_spr,_idx, 0,0, 1,_bg_h, 0,_y0, _x0,_sy, c_white,1);
		if (_x1 < 1920) draw_sprite_part_ext(_spr,_idx, _bg_w - 1,0, 1,_bg_h, _x1,_y0, 1920 - _x1,_sy, c_white,1);
		// 上下两条横带：源为最上 / 最下 1 像素行
		if (_y0 > 0) draw_sprite_part_ext(_spr,_idx, 0,0, _bg_w,1, _x0,0, _sx,_y0, c_white,1);
		if (_y1 < 1080) draw_sprite_part_ext(_spr,_idx, 0,_bg_h - 1, _bg_w,1, _x0,_y1, _sx,1080 - _y1, c_white,1);
		// 四个角：源为对应角的 1 像素
		if (_x0 > 0 && _y0 > 0)
			draw_sprite_part_ext(_spr,_idx, 0,0, 1,1, 0,0, _x0,_y0, c_white,1);
		if (_x1 < 1920 && _y0 > 0)
			draw_sprite_part_ext(_spr,_idx, _bg_w - 1,0, 1,1, _x1,0, 1920 - _x1,_y0, c_white,1);
		if (_x0 > 0 && _y1 < 1080)
			draw_sprite_part_ext(_spr,_idx, 0,_bg_h - 1, 1,1, 0,_y1, _x0,1080 - _y1, c_white,1);
		if (_x1 < 1920 && _y1 < 1080)
			draw_sprite_part_ext(_spr,_idx, _bg_w - 1,_bg_h - 1, 1,1, _x1,_y1, 1920 - _x1,1080 - _y1, c_white,1);
	}
	draw_sprite_ext(_spr,_idx,_bg_draw.x,_bg_draw.y,_bg_draw.sx,_bg_draw.sy,0,c_white,1);
}
else{
	draw_sprite(global.level_data.level_sprite,map_spr_index,0,0)
}
draw_set_valign(fa_top)
draw_set_halign(fa_left)
draw_set_color(c_white)
draw_set_font(font_yuan)
draw_text(0,0,"FPS:"+string(fps))
draw_text(0,25,"加速:"+(speed_up ? "开" : "关") + "（shift）")
draw_text(0,50,"暂停（空格）\n菜单（ESC）")

if global.level_id == "test_level"{
	var _total = variable_global_exists("test_damage_total_all") ? global.test_damage_total_all : 0
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_font(font_yuan)
	draw_set_color(c_yellow)
	var _remain = test_dps_window - test_dps_timer
	var _secs = ceil(_remain / 60)
	draw_text(0, 100, "5秒内总伤害: " + string(test_dps_display))
	draw_text(0, 125, "累计总伤害: " + string(_total))
	draw_text(0, 150, "下次结算: " + string(_secs) + "秒")
	draw_set_color(c_white)
	draw_text(0, 175, "F2：打开测试老鼠选择");
	draw_text(0, 200, "F4：打开原本老鼠选择");
	draw_text(0, 225, "F5：海克斯自选测试");
}


if (global.level_id == "test_level" && global.test_mouse_picker_id != "")
{
    draw_set_color(c_yellow);
    draw_set_font(font_yuan);
    draw_text(0, 250, "已选择测试老鼠：点击场上格子创建");
    draw_set_color(c_white);
}
