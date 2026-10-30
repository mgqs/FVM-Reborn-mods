/// ============================================================
/// 泡椒春笋：不占格陷阱。准备 → 冒芽 → 待机（范围内有老鼠才出手）→ 攻击
/// 帧段（资源第 N 帧 = image_index N-1）：准备 1-14 / 冒芽 15-19 / 待机 20-30；
/// 攻击时本体固定停在 ATK_BODY_FRAME（云底座 + 笋），刺由 obj_chunsun_spike 铺满范围
/// ============================================================

/// @func chunsun_targets_in_range(self_inst)
/// @desc 攻击范围内的可命中目标：normal(陆鼠) / dance(非主流鼠走行时的类别) / underground(地鼠军) / invisible(未显形幽灵)，不含飞行
function chunsun_targets_in_range(_self) {
	var _out = [];
	for (var _i = 0; _i < instance_number(obj_enemy_parent); _i++) {
		var _e = instance_find(obj_enemy_parent, _i);
		if (!instance_exists(_e) || _e.hp <= 0) continue;
		if (_e.target_type != "normal" && _e.target_type != "dance" && _e.target_type != "underground" && _e.target_type != "invisible") continue;
		var _g = get_grid_position_from_world(_e.x, _e.y);
		// 索敌用战斗域上界（含第 10 列），老鼠出生就在场外那一列
		if (!combat_cell_in(_g.col,_g.row)) continue;
		if (abs(_g.col - _self.grid_col) <= _self.range_col && abs(_g.row - _self.grid_row) <= _self.range_row) array_push(_out, _e);
	}
	// 傀儡马代理（千里马）同样吃笋
	for (var _j = 0; _j < instance_number(obj_kuileima_decoy); _j++) {
		var _d = instance_find(obj_kuileima_decoy, _j);
		if (!instance_exists(_d) || _d.hp <= 0 || array_contains(_out, _d)) continue;
		var _g2 = get_grid_position_from_world(_d.x, _d.y);
		if (!combat_cell_in(_g2.col,_g2.row)) continue;
		if (abs(_g2.col - _self.grid_col) <= _self.range_col && abs(_g2.row - _self.grid_row) <= _self.range_row) array_push(_out, _d);
	}
	return _out;
}

/// @func chunsun_spawn_spikes()
/// @desc 在攻击范围内每格铺一张「刺」——**含本体自己那格**（本体只保留云底座，本体贴图不再承担刺的表现）
function chunsun_spawn_spikes() {
	for (var _c = -range_col; _c <= range_col; _c++) {
		for (var _r = -range_row; _r <= range_row; _r++) {
			var _cc = grid_col + _c;
			var _rr = grid_row + _r;
			// 刺也要铺到第 10 列，否则索敌到了却没有表现
			if (!combat_cell_in(_cc,_rr)) continue;
			var _wp = get_world_position_from_grid(_cc, _rr);
			var _fx = instance_create_depth(_wp.x, _wp.y, calculate_plant_depth(_cc, _rr, "gridless"), obj_chunsun_spike);
			_fx.sprite_index = spike_sprite;
			_fx.image_xscale = image_xscale;
			_fx.image_yscale = image_yscale;

			// 傲慢龙柱的青苹果：春笋的穿刺同样可以直接秒杀（触发苹果的「消失」动画）
			with (obj_longzhu_green_apple) {
				if (hp > 0 && col == _cc && row == _rr) hp = 0;
			}
		}
	}
}

/// @func chunsun_deal_damage(targets)
/// @desc 精英(防爆)只吃[攻击力]伤害；非精英直接顶飞秒杀——直接销毁（同面粉袋碾压写法，
///       不进敌人死亡流程 → 无尸体），并生成向上击飞的表现
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
		var _fx = instance_create_depth(_kx, _ky, -3000, obj_chunsun_launch_fx);
		_fx.sprite_index = _kspr;
		_fx.image_index = _kidx;
		_fx.image_xscale = _kxs;
		_fx.image_yscale = _kys;
		// 直接销毁：Destroy 事件照常跑（从 enemy_by_type 注销 + 掉金币判定）
		with (_t) instance_destroy();
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
	// 待机：春笋长在云上循环（资源 20-30）；范围内有老鼠、间隔到点且还有剩余次数才出手
	image_index = IDLE_FIRST + (_f mod (IDLE_LAST - IDLE_FIRST + 1));
	if (array_length(tg) > 0 && attack_timer <= 0 && attack_count < max_attack) {
		phase = 3;
		anim_tick = 0;
		swing_done = false;
	}
	exit;
}

if (phase == 3) {
	// 攻击：本体固定停在云底座那一帧、不会消失；刺由范围内每格（含本体自己那格）的 obj_chunsun_spike 负责
	image_index = ATK_BODY_FRAME;
	if (!swing_done) {
		swing_done = true;
		attack_count++;
		attack_timer = cycle;
		chunsun_spawn_spikes();
		chunsun_deal_damage(tg);
	}
	if (_f > ATK_HOLD_TICKS - 1) {
		if (attack_count >= max_attack) {
			instance_destroy();
			exit;
		}
		phase = 2;
		anim_tick = 0;
	}
}
