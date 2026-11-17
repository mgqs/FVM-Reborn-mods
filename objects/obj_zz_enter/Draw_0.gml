// 关卡（战斗）里隐藏入口
if (room == room_battle) exit;

// 精灵原点在左上角（sequence xorigin/yorigin = 0,0），命中区按 x..x+w / y..y+h 算
var _x0 = x, _y0 = y;
var _x1 = x + sprite_width, _y1 = y + sprite_height;
var _hover = point_in_rectangle(mouse_x, mouse_y, _x0, _y0, _x1, _y1);
if (_hover) {
	var _s = 1.06;
	draw_sprite_ext(sprite_index, 0, x - sprite_width * (_s - 1) * 0.5,
		y - sprite_height * (_s - 1) * 0.5, _s, _s, 0, c_white, 1);
} else {
	draw_self();
}
