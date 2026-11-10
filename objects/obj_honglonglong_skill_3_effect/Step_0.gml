if global.is_paused{
	exit
}

timer++

// 17 帧特效，每帧 3 tick（约 0.85 秒播完）
var _last = sprite_get_number(sprite_index) - 1
image_index = floor(timer/3)
if image_index >= _last{
	image_index = _last
	instance_destroy()
}
