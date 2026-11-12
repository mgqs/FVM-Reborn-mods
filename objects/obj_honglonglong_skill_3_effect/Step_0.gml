if global.is_paused{
	exit
}

timer++

// 17 帧里只有前 6 帧有像素（帧 6 起 alpha 全 0），
// 所以按可见帧推进，不要空转那 11 帧。
var _visible_last = 5
var _hold_ticks = 5
image_index = min(floor(timer / _hold_ticks), _visible_last)

// 走完可见帧后补一段淡出，避免突然消失
var _fade_start = (_visible_last + 1) * _hold_ticks
var _fade_ticks = 10
if timer >= _fade_start{
	image_alpha = 1 - (timer - _fade_start) / _fade_ticks
	if image_alpha <= 0{
		image_alpha = 0
		instance_destroy()
	}
}
