if (global.is_paused) exit;

// ---------- 血量主控：一次灰烬固定 -50%，卡片侧的额外扣血一律还原 ----------
// （面粉袋 / 椰子 / 春笋这类实现会在 event_user(0) 之前先 hp -= atk，
//  不还原的话「一次灰烬 = 半血」的口径会被打乱）
if (zhangaiwu_state != "dead" && hp != ly_hp_lock) hp = ly_hp_lock;

// ---------- 死亡状态：播完 dead 动画后销毁 ----------
if (zhangaiwu_state == "dead") {
	if (sprite_index != spr_zhangaiwu_dead) {
		sprite_index = spr_zhangaiwu_dead;
		image_index = 0;
	}
	if (image_index >= sprite_get_number(spr_zhangaiwu_dead) - 1) {
		if (variable_global_exists("longyuan_bridge_obstacle_" + longyuan_bridge_track)) {
			global[$ "longyuan_bridge_obstacle_" + longyuan_bridge_track] = noone;
		}
		instance_destroy();
	}
	exit;
}

event_inherited();
if (!instance_exists(id)) exit;
// Other_10 可能在父对象 Step 中触发并将状态切到 dead，此处再次检查
if (zhangaiwu_state == "dead") exit;

// hp<=0 由 Other_10 切换到 dead；这里兜底（防止其他来源的伤害）
if (hp <= 0) {
	zhangaiwu_state = "dead";
	sprite_index = spr_zhangaiwu_dead;
	image_index = 0;
	exit;
}

// ---------- 待机状态：10s 后进入移动 ----------
if (zhangaiwu_state == "idel") {
	zhangaiwu_idle_timer++;
	if (zhangaiwu_idle_timer >= 600) {
		zhangaiwu_state = "move";
		sprite_index = spr_zhangaiwu_move;
		image_index = 0;
	}
	exit;
}

// ---------- 移动状态：沿轨道前进，撞击销毁非承载卡 ----------
if (zhangaiwu_state == "move") {
	if (array_length(longyuan_bridge_path) <= 0) exit;

	var _target = longyuan_bridge_path[longyuan_bridge_path_index];
	var _pos = get_world_position_from_grid(_target[0], _target[1]);
	var _speed = 0.625;
	var _distance = point_distance(x, y, _pos.x, _pos.y);
	if (_distance <= _speed) {
		x = _pos.x;
		y = _pos.y;
		longyuan_bridge_clear_cell(_target[0], _target[1]);
		longyuan_bridge_path_index++;
		if (longyuan_bridge_path_index >= array_length(longyuan_bridge_path)) {
			if (variable_global_exists("longyuan_bridge_obstacle_" + longyuan_bridge_track)) {
				global[$ "longyuan_bridge_obstacle_" + longyuan_bridge_track] = noone;
			}
			instance_destroy();
			exit;
		}
	} else {
		var _direction = point_direction(x, y, _pos.x, _pos.y);
		x += lengthdir_x(_speed, _direction);
		y += lengthdir_y(_speed, _direction);
	}
}
