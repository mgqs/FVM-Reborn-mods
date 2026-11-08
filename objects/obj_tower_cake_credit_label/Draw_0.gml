/// 魔塔蛋糕 · 凭证格小字：统一在这一层画（字体跟商店「通过X-X层可买」同一款 font_pixel、纯黑）
if (!instance_exists(obj_tower_cake_bg)) exit;

var _bg = obj_tower_cake_bg;
var _list = _bg.credit_labels;
var _n = array_length(_list);
if (_n <= 0) exit;

draw_set_font(font_pixel);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_alpha(1);

for (var i = 0 ; i < _n ; i ++){
	var _it = _list[i];
	var _txt = _it[2];
	var _grey = _it[3];
	// 长卡名（9 字以上）按 152px 上限收一点缩比，别让相邻两格的标签撞在一起
	var _w = max(1, string_width(_txt));
	var _scl = clamp(152 / _w, 0.8, 1.0);
	draw_set_colour(_grey ? make_color_rgb(96, 104, 116) : c_black);
	draw_text_transformed(_it[0], _it[1], _txt, _scl, _scl, 0);
}

draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
