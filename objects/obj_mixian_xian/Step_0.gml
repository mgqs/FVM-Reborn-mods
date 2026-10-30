if (global.is_paused) exit;

var _rate = 5;

if (link_state == "connect") {
	if (!instance_exists(owner_card) || !instance_exists(owner_pillar)) {
		link_state = "break";
		anim_tick = 0;
		sprite_index = spr_mixian_disxian;
		image_index = 0;
	} else {
		anim_tick++;

		// 跟随卡片起点，朝向并拉伸到龙柱
		x = owner_card.x;
		y = owner_card.y;
		depth = owner_card.depth + 1;

		var _tx = owner_pillar.x;
		var _ty = owner_pillar.y;
		var _dist = point_distance(x, y, _tx, _ty);

		image_angle = point_direction(x, y, _tx, _ty);
		image_xscale = max(0.05, _dist / max(1, line_base_len));
		image_yscale = 1;

		var _f = anim_tick div _rate;
		if (_f <= 3) {
			image_index = _f;                       // 1-4 连接
		} else {
			image_index = 4 + ((_f - 4) mod 3);      // 5-7 循环
		}
	}
}

if (link_state == "break") {
	anim_tick++;
	var _f = anim_tick div _rate;
	if (_f >= 7) {
		instance_destroy();
	} else {
		image_index = min(6, _f);
	}
}
