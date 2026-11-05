if image_alpha <= 0{
	exit
}

var _cx = global.grid_cell_size_x
var _cy = global.grid_cell_size_y
var _w  = _cx * (ice_radius * 2 + 1) * 1.18
var _h  = _cy * (ice_radius * 2 + 1) * 1.18
var _sw = sprite_get_width(spr_xiaoming_ice)
var _sh = sprite_get_height(spr_xiaoming_ice)

// 冰雾本体：循环播放的小明冰雾帧，缩放到覆盖整个冰冻区域
draw_sprite_ext(spr_xiaoming_ice, anim_index, x, y, _w / _sw, _h / _sh, 0, c_white, 0.76 * image_alpha)

// 区域边界：保留一圈很淡的冰蓝描边，让玩家知道「补种进这里会被冻住」的范围
var _hw = _cx * (ice_radius + 0.5)
var _hh = _cy * (ice_radius + 0.5)
draw_set_alpha(0.30 * image_alpha)
draw_set_color(make_color_rgb(175, 232, 255))
draw_rectangle(x - _hw, y - _hh, x + _hw, y + _hh, true)

draw_set_alpha(1)
draw_set_color(c_white)
