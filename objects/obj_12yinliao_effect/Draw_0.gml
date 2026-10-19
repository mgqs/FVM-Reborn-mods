if (center_screen) {
	var _scale = max(room_width / sprite_get_width(sprite_index), room_height / sprite_get_height(sprite_index));
	draw_sprite_ext(sprite_index, image_index, room_width / 2, room_height / 2, _scale, _scale, 0, c_white, 1);
} else {
	draw_sprite_stretched(sprite_index, image_index, 0, 0, room_width, room_height);
}
