if (global.is_paused) exit;

sprite_index = fx_sprite;
fx_tick++;

var _f = fx_tick div max(1, fx_rate);
if (_f >= fx_frames) {
	instance_destroy();
} else {
	image_index = _f;
}
