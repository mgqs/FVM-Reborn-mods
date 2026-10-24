if (global.is_paused) exit;

// ---------- 反伤（仅形态1及以后，参考瓜皮护罩的一转效果） ----------
// hp 已被老鼠攻击扣减，此时按上一帧差值反伤
if (mixian_prev_hp > hp && shape >= 1) {
	bleed_damage = mixian_prev_hp - hp;
	event_user(1);
}

// ---------- 致命伤：进入死亡动画 ----------
// 保持 hp=1 以避免父对象在 hp<=0 时立即销毁，动画结束后再真正销毁
if (hp <= 0 && !mixian_dying) {
	mixian_dying = true;
	mixian_death_tick = 0;
	hp = 1;
	mixian_prev_hp = hp;
	state = CARD_STATE.DEAD;
	image_index = 16;

	// 连接线播放 disxian，脚下光环播放 disconnect
	mixian_break_visuals();
	mixian_release_bridge();

	// 米线断裂：立刻解封龙柱
	if (mixian_pillar != noone) longzhu_bridge_disconnect(id);
	mixian_pillar = noone;
	mixian_link_broken = true;

	if (instance_exists(banding_sleep_obj)) instance_destroy(banding_sleep_obj);
}

if (mixian_dying) {
	// 死亡动画期间免疫后续伤害
	if (hp <= 0) hp = 1;
	event_inherited();
	if (hp <= 0) hp = 1;

	mixian_death_tick++;
	var _rate = is_slowdown ? flash_speed * 2 : flash_speed;
	var _f = mixian_death_tick div _rate;
	if (_f <= 5) {
		image_index = 16 + _f;
	} else {
		instance_destroy();
	}
	exit;
}

event_inherited();
if (hp <= 0) exit;
mixian_prev_hp = hp;

// ---------- 与最近的龙柱连接 ----------
if (!mixian_link_broken) {
	// 目标龙柱中途消失：断开连接，不再重新寻找
	if (mixian_pillar != noone && !instance_exists(mixian_pillar)) {
		mixian_pillar = noone;
		mixian_link_broken = true;
		mixian_break_visuals();
		mixian_release_bridge();
	}

	// 尚未连上时定期寻找 5*5 范围内最近的龙柱（关卡波次中龙柱可能后生成）
	if (mixian_pillar == noone && !mixian_link_broken && grid_col >= 0 && instance_exists(obj_longzhu)) {
		mixian_link_retry--;
		if (mixian_link_retry <= 0) {
			mixian_link_retry = 30;
			var _best = noone;
			var _best_d = 99999999;
			with (obj_longzhu) {
				if (col < 0 || row < 0) continue;
				if (abs(col - other.grid_col) > 2 || abs(row - other.grid_row) > 2) continue;
				// 同一龙柱已被 2 条米线连接时，不再接受其他米线链接
				var _links = 0;
				with (obj_mixian) {
					if (!mixian_dying && mixian_pillar == other.id) _links++;
				}
				if (_links >= 2) continue;
				var _d = point_distance(x, y, other.x, other.y);
				if (_d < _best_d) {
					_best = id;
					_best_d = _d;
				}
			}
			if (_best != noone) {
				mixian_pillar = _best;

				// 连接线
				mixian_line = instance_create_depth(x, y, depth + 1, obj_mixian_xian);
				mixian_line.owner_card = id;
				mixian_line.owner_pillar = _best;

				// 卡片脚下光环
				mixian_ring_self = instance_create_depth(x, y, depth + 1, obj_mixian_ring);
				mixian_ring_self.owner_card = id;
				mixian_ring_self.follow_target = id;
				mixian_ring_self.is_pillar_ring = false;

				// 龙柱脚下光环（压在龙柱下面、地图上面）
				mixian_ring_pillar = instance_create_depth(_best.x, _best.y, _best.depth + 0.5, obj_mixian_ring);
				mixian_ring_pillar.owner_card = id;
				mixian_ring_pillar.follow_target = _best;
				mixian_ring_pillar.is_pillar_ring = true;

				// 注册米线桥线段（地晶、梭子、高跷等龙源关卡机制会读取）
				longyuan_bridge_connected = true;
				mixian_bridge_line = { owner: id, x1: x, y1: y, x2: _best.x, y2: _best.y };
				array_push(global.longyuan_bridge_lines, mixian_bridge_line);
				mixian_bridge_registered = true;
			}
		}
	}

	// 每步上报连接线，龙柱接口按线段判定封印
	// 1 张即可封印；2 张连接同一根龙柱时额外触发净化
	if (instance_exists(mixian_pillar)) {
		if (mixian_bridge_registered) {
			mixian_bridge_line.x1 = x;
			mixian_bridge_line.y1 = y;
			mixian_bridge_line.x2 = mixian_pillar.x;
			mixian_bridge_line.y2 = mixian_pillar.y;
		}
		longzhu_bridge_connect(id, x, y, mixian_pillar.x, mixian_pillar.y);

		// 2 张同时连接同一根龙柱：在该龙柱处播放一次净化演出（机制仍为封印）
		var _linked = 0;
		with (obj_mixian) {
			if (!mixian_dying && mixian_pillar == other.mixian_pillar) _linked++;
		}
		if (_linked >= 2) {
			if (!variable_instance_exists(mixian_pillar, "longzhu_purify_played") || !mixian_pillar.longzhu_purify_played) {
				mixian_pillar.longzhu_purify_played = true;
				var _fx = instance_create_depth(mixian_pillar.x, mixian_pillar.y, mixian_pillar.depth + 1, obj_mixian_fx);
				_fx.fx_sprite = spr_mixian_effect;
				_fx.fx_frames = sprite_get_number(spr_mixian_effect);
				_fx.fx_rate = 5;
				_fx.image_xscale = 2;
				_fx.image_yscale = 2;
				// 净化发光的同时立即施加一次龙柱效果（清醒/保护/返还火苗）
				longzhu_purify_effect(mixian_pillar);
			}
		} else {
			mixian_pillar.longzhu_purify_played = false;
		}
	}
}

// ---------- 5*5 范围攻击 ----------
var _rate = is_slowdown ? flash_speed * 2 : flash_speed;

if (mixian_attack_phase == 0) {
	// 待机循环 0-7
	mixian_idle_tick++;
	image_index = (mixian_idle_tick div _rate) mod 8;

	mixian_attack_timer--;
	if (!is_frozen && state != CARD_STATE.SLEEP && mixian_attack_timer <= 0) {
		var _targets = [];
		with (obj_enemy_parent) {
			// 地面范围攻击：命中陆鼠、非主流鼠、地鼠与未显形幽灵，不含飞行；高跷鼠（空军单位）不受伤
			if (hp > 0
				&& (target_type == "normal" || target_type == "dance" || target_type == "underground" || target_type == "invisible")
				&& !(variable_instance_exists(id, "mouse_id") && mouse_id == "longyuan_gaoqiao")
				&& abs(grid_col - other.grid_col) <= 2
				&& abs(grid_row - other.grid_row) <= 2) {
				array_push(_targets, id);
			}
		}

		if (array_length(_targets) > 0) {
			mixian_attack_phase = 1;
			mixian_attack_tick = 0;
			mixian_attack_hit = false;
			mixian_attack_targets = _targets;
		} else {
			mixian_attack_timer = 10; // 没有目标时短暂重试
		}
	}
} else {
	// 攻击动画 8-15，在第 5 帧命中（对应资源第 13 帧附近）
	mixian_attack_tick++;
	var _f = mixian_attack_tick div _rate;
	image_index = 8 + min(7, _f);

	if (!mixian_attack_hit && _f >= 4) {
		mixian_attack_hit = true;

		// 二转的攻击力已在数据表中单独配置，不再额外翻倍
		var _dmg = atk;

		var _n = array_length(mixian_attack_targets);
		for (var _i = 0; _i < _n; ++_i) {
			var _e = mixian_attack_targets[_i];
			if (!instance_exists(_e) || _e.hp <= 0) continue;

			// 攻击到敌人播放一次 spr_mixian_effect
			var _fx = instance_create_depth(_e.x, _e.y, _e.depth - 1, obj_mixian_fx);
			_fx.fx_sprite = spr_mixian_effect;
			_fx.fx_frames = sprite_get_number(spr_mixian_effect);
			_fx.fx_rate = 5;

			with (_e) {
				damage_amount = _dmg;
				damage_type = "normal";
				event_user(0);
			}
		}
	}

	if (_f > 7) {
		mixian_attack_phase = 0;
		mixian_attack_timer = cycle;
		mixian_idle_tick = 0;
	}
}
