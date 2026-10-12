/// ============================================================
/// 泡椒春笋：不占格陷阱。准备 → 冒芽 → 待机（范围内有老鼠才出手）→ 攻击
/// 帧段（资源第 N 帧 = image_index N-1）：准备 1-14 / 冒芽 15-19 / 待机 20-35 / 攻击 36-39
/// ============================================================

/// @func chunsun_targets_in_range(self_inst)
/// @desc 攻击范围内的可命中目标：normal(陆鼠，含非主流) / underground(地鼠) / invisible(未显形幽灵)，不含飞行
function chunsun_targets_in_range(_self) {
	var _out = [];
	for (var _i = 0; _i < instance_number(obj_enemy_parent); _i++) {
		var _e = instance_find(obj_enemy_parent, _i);
		if (!instance_exists(_e) || _e.hp <= 0) continue;
		if (_e.target_type != "normal" && _e.target_type != "underground" && _e.target_type != "invisible") continue;
		var _g = get_grid_position_from_world(_e.x, _e.y);
		if (_g.col < 0 || _g.col >= global.grid_cols || _g.row < 0 || _g.row >= global.grid_rows) continue;
		if (abs(_g.col - _self.grid_col) <= _self.range_col && abs(_g.row - _self.grid_row) <= _self.range_row) array_push(_out, _e);
	}
	// 傀儡马代理（千里马）同样吃笋
	for (var _j = 0; _j < instance_number(obj_kuileima_decoy); _j++) {
		var _d = instance_find(obj_kuileima_decoy, _j);
		if (!instance_exists(_d) || _d.hp <= 0 || array_contains(_out, _d)) continue;
		var _g2 = get_grid_position_from_world(_d.x, _d.y);
		if (_g2.col < 0 || _g2.col >= global.grid_cols || _g2.row < 0 || _g2.row >= global.grid_rows) continue;
		if (abs(_g2.col - _self.grid_col) <= _self.range_col && abs(_g2.row - _self.grid_row) <= _self.range_row) array_push(_out, _d);
	}
	return _out;
}

/// @func chunsun_spawn_spikes()
/// @desc 在攻击范围内每格铺一张「刺」；自己那格由本体自己的攻击帧负责，避免叠两层
function chunsun_spawn_spikes() {
	for (var _c = -range_col; _c <= range_col; _c++) {
		for (var _r = -range_row; _r <= range_row; _r++) {
			if (_c == 0 && _r == 0) continue;
			var _cc = grid_col + _c;
			var _rr = grid_row + _r;
			if (_cc < 0 || _cc >= global.grid_cols || _rr < 0 || _rr >= global.grid_rows) continue;
			var _wp = get_world_position_from_grid(_cc, _rr);
			var _fx = instance_create_depth(_wp.x, _wp.y, calculate_plant_depth(_cc, _rr, "gridless"), obj_chunsun_spike);
			_fx.sprite_index = spike_sprite;
			_fx.image_xscale = image_xscale;
			_fx.image_yscale = image_yscale;
		}
	}
}

/// @func chunsun_deal_damage(targets)
/// @desc 精英(防爆)只吃[攻击力]伤害；非精英用「血+盾+盔」真伤直接秒杀，并生成向上击飞的表现
function chunsun_deal_damage(_targets) {
	var _dmg = atk;
	for (var _i = 0; _i < array_length(_targets); _i++) {
		var _t = _targets[_i];
		if (!instance_exists(_t) || _t.hp <= 0) continue;
		var _elite = variable_instance_exists(_t, "immune_to_ash") ? _t.immune_to_ash : false;
		if (_elite) {
			with (_t) {
				damage_amount = _dmg;
				damage_type = "normal";
				event_user(0);
			}
			continue;
		}
		// 击飞表现要用老鼠当前的贴图与位置，销毁前先记下来
		var _kx = _t.x;
		var _ky = _t.y;
		var _kspr = _t.sprite_index;
		var _kidx = _t.image_index;
		var _kxs = _t.image_xscale;
		var _kys = _t.image_yscale;
		var _lethal = _t.hp;
		if (variable_instance_exists(_t, "shield_hp")) _lethal += _t.shield_hp;
		if (variable_instance_exists(_t, "helmet_hp")) _lethal += _t.helmet_hp;
		with (_t) {
			damage_amount = _lethal;
			damage_type = "true";
			event_user(0);
		}
		var _fx = instance_create_depth(_kx, _ky, -3000, obj_chunsun_launch_fx);
		_fx.sprite_index = _kspr;
		_fx.image_index = _kidx;
		_fx.image_xscale = _kxs;
		_fx.image_yscale = _kys;
	}
}

// ============================================================
// 主逻辑
// ============================================================
if (global.is_paused) exit;
event_inherited();
if (hp <= 0) exit;
if (is_frozen) exit;

// 父对象只有「待机(0..idle_anim) + 攻击」两段，装不下四段，
// 这里每帧自己算 image_index 覆盖它。
anim_tick++;
var _rate = is_slowdown ? flash_speed * 2 : flash_speed;
var _f = anim_tick div _rate;

if (phase == 0) {
	// 准备：坑里空无一物（资源 1-14）
	image_index = _f mod (PREPARE_LAST + 1);
	phase_timer++;
	if (phase_timer >= prepare_time) {
		phase = 1;
		anim_tick = 0;
	}
	exit;
}

// 准备结束开始计存活时间
alive_timer++;
if (alive_timer >= life_time) {
	instance_destroy();
	exit;
}
if (attack_timer > 0) attack_timer--;

if (phase == 1) {
	// 冒芽：单次播完进待机（资源 15-19）
	image_index = GROW_FIRST + min(GROW_LAST - GROW_FIRST, _f);
	if (_f > (GROW_LAST - GROW_FIRST)) {
		phase = 2;
		anim_tick = 0;
	}
	exit;
}

var tg = chunsun_targets_in_range(id);

if (phase == 2) {
	// 待机：春笋长在土堆上循环（资源 20-35）；范围内有老鼠、间隔到点且还有剩余次数才出手
	image_index = IDLE_FIRST + (_f mod (IDLE_LAST - IDLE_FIRST + 1));
	if (array_length(tg) > 0 && attack_timer <= 0 && attack_count < max_attack) {
		phase = 3;
		anim_tick = 0;
		swing_done = false;
	}
	exit;
}

if (phase == 3) {
	// 攻击：范围内只剩刺（资源 36-39）
	image_index = ATK_FIRST + min(ATK_LAST - ATK_FIRST, _f);
	if (!swing_done) {
		swing_done = true;
		attack_count++;
		attack_timer = cycle;
		chunsun_spawn_spikes();
		chunsun_deal_damage(tg);
	}
	if (_f > (ATK_LAST - ATK_FIRST)) {
		if (attack_count >= max_attack) {
			instance_destroy();
			exit;
		}
		phase = 2;
		anim_tick = 0;
	}
}
