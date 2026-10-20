var _pool_top = y + 375 - 48;
if (fly_active && sprite_exists(fly_spr)) {
	var _p = fly_t / fly_dur;
	var _e = 1 - power(1 - _p, 3);
	var _fy = lerp(fly_sy, fly_ty, _e);
	if (_fy - 40 < _pool_top) {
		var _fx = lerp(fly_sx, fly_tx, _e);
		draw_sprite_ext(spr_slot, 0, _fx, _fy - 3, 0.25, 0.25, 0, c_white, 1);
		draw_sprite_ext(fly_spr, 0, _fx, _fy + 15, 0.7, 0.7, 0, c_white, 1);
	}
}
for (var _bi = 0; _bi < array_length(fly_batch); _bi++) {
	var _b = fly_batch[_bi];
	var _p = min(1, _b.t / _b.dur);
	var _e = 1 - power(1 - _p, 3);
	var _bx = lerp(_b.sx, _b.tx, _e);
	var _by = lerp(_b.sy, _b.ty, _e);
	if (_by - 40 < _pool_top) {
		draw_sprite_ext(spr_slot, 0, _bx, _by - 3, 0.25, 0.25, 0, c_white, 1);
		draw_sprite_ext(_b.spr, 0, _bx, _by + 15, 0.7, 0.7, 0, c_white, 1);
	}
}
