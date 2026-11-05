// 关卡背景：默认按原尺寸画在左上角；关卡 JSON 里给了 bg_draw 时按其缩放/偏移绘制
// （跨服·梦魇天空的底图是 1109×597 半尺寸图，需要还原到 9*107 × 7*116 的格子区）
if (variable_struct_exists(global.level_file, "bg_draw")){
	var _bg_draw = global.level_file.bg_draw;
	draw_sprite_ext(global.level_data.level_sprite,map_spr_index,_bg_draw.x,_bg_draw.y,_bg_draw.sx,_bg_draw.sy,0,c_white,1);
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
