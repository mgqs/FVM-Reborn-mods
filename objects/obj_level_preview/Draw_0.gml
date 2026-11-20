// 地图查看：关卡底图铺满整屏当背景
// 2026-11-20 用户口径：从「梦魇天空」这类跨服章节进来时地图尺寸太小，
// 不像之前的关卡那样铺满整张背景。
// 根因：29 张关卡底图尺寸并不统一 ——
//   古代城堡 / 饼干岛   2005x1080（本来就够铺满 1920x1080）
//   梦魇天空 / 水货之间 / 无毒研究所 / 灼热地域   1108~1114 x 597~600（只有半屏）
// 原来一律 draw_sprite(...,0,0) 按 1:1 画，半尺寸那几张就只剩左上一块。
// 现在按「cover」缩放：取宽高两个比例里更大的那个，等比放大到短边也铺满，居中裁切。
// 大于房间的图仍然保持原尺寸（比例 1.0），不被缩小，行为与旧版一致。
var _lspr = global.level_data.level_sprite;
if (sprite_exists(_lspr)) {
	var _lw = sprite_get_width(_lspr);
	var _lh = sprite_get_height(_lspr);
	if (_lw > 0 && _lh > 0) {
		var _scale = max(room_width / _lw, room_height / _lh);
		var _lx = (room_width  - _lw * _scale) * 0.5;
		var _ly = (room_height - _lh * _scale) * 0.5;
		draw_sprite_ext(_lspr, 0, _lx, _ly, _scale, _scale, 0, c_white, 1);
	}
}
draw_set_color(c_black)
draw_set_alpha(0.7)
draw_rectangle(0,0,room_width,room_height,0)
draw_set_alpha(1)
draw_set_font(font_yuan)
draw_set_colour(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_text(20,20,"右键点击或按ESC返回关卡")
draw_text(40,180,"普通敌人")
draw_text(40,820,"BOSS")
