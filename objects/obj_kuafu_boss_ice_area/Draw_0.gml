if image_alpha <= 0{
	exit
}

var _cx = global.grid_cell_size_x
var _cy = global.grid_cell_size_y
var _hw = _cx * (ice_radius + 0.5)
var _hh = _cy * (ice_radius + 0.5)
var _l = x - _hw
var _r = x + _hw
var _t = y - _hh
var _b = y + _hh

// 冰面底色（半透明，盖在地面之上、卡片之下）
draw_set_alpha(0.16 * image_alpha)
draw_set_color(make_color_rgb(110, 195, 255))
draw_rectangle(_l, _t, _r, _b, false)

// 冰蓝描边，明确标出区域边界
draw_set_alpha(0.55 * image_alpha)
draw_set_color(make_color_rgb(175, 232, 255))
draw_rectangle(_l, _t, _r, _b, true)

draw_set_alpha(1)
draw_set_color(c_white)
