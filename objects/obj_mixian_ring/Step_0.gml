if (global.is_paused) exit;

var _rate = 5;

if (ring_state == "connect") {
	if (!instance_exists(follow_target)) {
		ring_state = "break";
		anim_tick = 0;
		sprite_index = spr_mixian_disconnect;
		image_index = 0;
	} else {
		anim_tick++;

		x = follow_target.x;
		y = follow_target.y;
		depth = is_pillar_ring ? follow_target.depth + 0.5 : follow_target.depth + 1;

		var _f = anim_tick div _rate;
		if (_f <= 9) {
			image_index = _f;                        // 1-10 连接
		} else {
			image_index = 10 + ((_f - 10) mod 8);    // 11-18 循环
		}
	}
}

if (ring_state == "break") {
	anim_tick++;
	var _f = anim_tick div _rate;
	if (_f >= 6) {
		instance_destroy();
	} else {
		image_index = min(5, _f);
	}
}
