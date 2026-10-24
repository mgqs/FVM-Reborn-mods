/// ============================================================
/// 龙柱（七色龙柱）机制模块
/// ------------------------------------------------------------
/// 龙柱是关卡障碍物，默认固定生成在地图正中间的格子；两种形态：
///   未封印 = 悬浮（悬浮待机；触发效果时 前摇 → 悬浮施法）
///   被「桥头米线」封印 = 插地（插入地面 → 地面待机；触发效果时 地面施法）
///   米线断裂 = 立刻解封，播放 飞起
///
/// 四类龙柱机制：
///   cheng 松露大厅(橙)：未封印 → 周期对 3x3 卡片催眠
///                       有封印 → 周期对 3x3 卡片加「清醒」效果（期间不会被老鼠催眠）
///   lv    百味关(绿)  ：未封印 → 周期摧毁 3x3 卡片
///                       有封印 → 周期对 3x3 卡片施加「保护」效果（复用星穹马一转的 zodiac_guard 减伤）
///   huang 贪婪(黄)    ：未封印 → 大幅限制火苗栏最大火苗上限
///                       有封印 → 周期把 3x3 内卡片的部分耗能以火苗形式返还产出
///                       米线断裂 → 立刻把火苗扣至当前上限
///                       ≥4 根贪婪龙柱被封印 → 火苗栏可存储最大上限被提升
///   lv2   傲慢(青绿)  ：未封印 → 周期把 3x3 内的「攻击类」卡片感染成【青苹果】
///                       有封印 → 周期统计 3x3 内攻击类卡片数量，向场上最靠近自身的
///                                老鼠发射等量追踪【红苹果】子弹
///
/// 米线接口（obj_mixian 由使用者自行实现，只需调用下面 3 个函数）：
///   longzhu_bridge_connect(_owner, _x1, _y1, _x2, _y2)  每步上报一根封印线
///   longzhu_bridge_disconnect(_owner)                   米线断裂/被摧毁时调用
///   longzhu_bridge_clear()                              清空本步触碰（可选，正常无需调用）
/// 也可以直接给某根龙柱设置 longzhu_force_sealed = true / false 来强制封印/解封。
/// ============================================================

/// ---------- 可调常量 ----------
#macro LONGZHU_INTERVAL                 900   // 效果触发周期（帧）
#macro LONGZHU_AWAKE_TIME               1800  // 「清醒」+「不可催眠」持续（帧）：覆盖完整施法周期，解封时立即清除
#macro LONGZHU_PROTECT_TIME             900   // 「保护」效果持续（帧）——对齐星穹马一转 zodiac_guard_duration
#macro LONGZHU_PROTECT_HITS             1     // 「保护」可抵挡次数——对齐星穹马一转
#macro LONGZHU_GREEDY_LIMIT             1000  // 存在未封印贪婪龙柱时的火苗上限基数
#macro LONGZHU_GREEDY_RETURN_RATIO      0.5   // 贪婪返还能量比例（按 3x3 内卡片耗能计算）
#macro LONGZHU_RED_APPLE_DAMAGE         2000  // 红苹果子弹伤害
#macro LONGZHU_RED_APPLE_SPEED          5     // 红苹果子弹速度
#macro LONGZHU_RED_APPLE_LIFE           600   // 红苹果子弹最长存活（帧）
#macro LONGZHU_GREEN_APPLE_HP           2000000 // 青苹果耐久
#macro LONGZHU_GREEN_APPLE_HEAL         10000 // 青苹果每次为接触老鼠回复的体力
#macro LONGZHU_GREEN_APPLE_HEAL_INTERVAL 30   // 青苹果治疗间隔（帧）
#macro LONGZHU_GREEN_APPLE_LIFE          2400 // 青苹果存活时长（帧）
#macro LONGZHU_PILLAR_BASE_DEPTH        (49)   // 龙柱绘制深度：地图(50)之上，卡片/敌人(-10~-320)之下
#macro LONGZHU_APPLE_DEPTH_OFFSET       (-1100) // 苹果绘制深度
#macro LONGZHU_SCALE                    2      // 龙柱本体精灵放大倍数

/// 动画播放步率：SWF 标签按 10 帧/秒设计，折算到当前房间帧率
function longzhu_anim_rate() {
	return max(1, game_get_speed(gamespeed_fps) / 10);
}

/// 龙渊关卡的龙柱颜色；global.longzhu_kind 可用于特殊关卡手动覆盖。
function longzhu_kind_for_level() {
	var _level = variable_global_exists("level_id") ? string(global.level_id) : "";
	switch (_level) {
		case "longyuan_1":
		case "longyuan_2": return "cheng";
		case "longyuan_3": return "lv";
		case "longyuan_4":
		case "longyuan_5": return "huang";
		case "longyuan_6": return "lv2";
	}
	if (variable_global_exists("longzhu_kind") && global.longzhu_kind != "") return global.longzhu_kind;
	return "cheng";
}

function longzhu_setup_level_pillars() {
	if (global.longzhu_level_pillars_setup) return;
	global.longzhu_level_pillars_setup = true;
	var _level = string(global.level_id);
	var _kind = longzhu_kind_for_level();
	var _positions = [];
	switch (_level) {
		case "longyuan_1": _positions = [[6, 1], [6, 5]]; break;
		case "longyuan_2": _positions = [[6, 1], [2, 3], [6, 5]]; break;
		case "longyuan_3": _positions = [[1, 3], [7, 3]]; break;
		case "longyuan_4": _positions = [[2, 1], [6, 2], [4, 5]]; break;
		case "longyuan_5": _positions = [[3, 1], [6, 1], [3, 5], [6, 5]]; break;
		case "longyuan_6": _positions = [[2, 1], [6, 1], [2, 5], [6, 5]]; break;
		default: return;
	}
	var _first = instance_find(obj_longzhu, 0);
	if (_level == "longyuan_1" || _level == "longyuan_2") {
		with (obj_longzhu) instance_destroy();
		global.longzhu_orange_wave1_done = false;
		global.longzhu_orange_wave2_done = false;
		return;
	}
	if (instance_exists(_first)) {
		_first.col = _positions[0][0]; _first.row = _positions[0][1];
		var _pos = get_world_position_from_grid(_first.col, _first.row);
		_first.x = _pos.x; _first.y = _pos.y;
		longzhu_setup(_first, _kind);
	} else longzhu_spawn(_kind, _positions[0][0], _positions[0][1]);
	for (var _i = 1; _i < array_length(_positions); ++_i) longzhu_spawn(_kind, _positions[_i][0], _positions[_i][1]);
}

function longzhu_update_level_pillars(_wave) {
	var _level = string(global.level_id);
	if ((_level == "longyuan_1" || _level == "longyuan_2") && _wave >= 0 && !global.longzhu_orange_wave1_done) {
		global.longzhu_orange_wave1_done = true;
		var _kind = longzhu_kind_for_level();
		longzhu_spawn(_kind, 6, 1);
		longzhu_spawn(_kind, _level == "longyuan_1" ? 6 : 2, _level == "longyuan_1" ? 5 : 3);
	}
	if (_level == "longyuan_2" && _wave >= 1 && !global.longzhu_orange_wave2_done) {
		global.longzhu_orange_wave2_done = true;
		longzhu_spawn(longzhu_kind_for_level(), 6, 5);
	}
}

/// ---------- 生成 ----------
/// 生成一根龙柱。_col/_row 省略(-1)时固定落在「地图正中间的格子」。
/// 返回值：obj_longzhu 实例
function longzhu_spawn(_kind, _col = -1, _row = -1) {
	if (_col < 0) _col = floor((global.grid_cols - 1) / 2);
	if (_row < 0) _row = floor((global.grid_rows - 1) / 2);
	var _pos = get_world_position_from_grid(_col, _row);
	var _inst = instance_create_depth(_pos.x, _pos.y, LONGZHU_PILLAR_BASE_DEPTH, obj_longzhu);
	_inst.col = _col;
	_inst.row = _row;
	longzhu_setup(_inst, _kind);
	longzhu_flame_cap_refresh();
	return _inst;
}

/// 初始化（或切换）某根龙柱的种类与动画
function longzhu_setup(_inst, _kind) {
	_inst.longzhu_kind = _kind;
	_inst.longzhu_anims = longzhu_pillar_anims(longzhu_pillar_sprite(_kind));
	_inst.longzhu_sealed = false;
	_inst.longzhu_action = "";
	_inst.longzhu_frame = 0;
	_inst.longzhu_once = false;
	_inst.longzhu_timer = 0;
	_inst.longzhu_ready = false;
	_inst.longzhu_effect_timer = 0;
	longzhu_clip_set(_inst, "出生", true);
	longzhu_flame_cap_refresh();
}

/// ---------- 动画驱动 ----------
/// 切换龙柱当前动作（_once=true 表示播完不循环）
function longzhu_clip_set(_inst, _action, _once = false) {
	with (_inst) {
		if (!variable_struct_exists(longzhu_anims, _action)) {
			show_debug_message("龙柱缺少动作: " + longzhu_kind + "/" + _action);
			return;
		}
		longzhu_action = _action;
		longzhu_once = _once;
		longzhu_timer = 0;
		longzhu_frame = 0;
		var _clip = longzhu_anims[$ _action];
		sprite_index = _clip[0];
		image_index = _clip[1] - 1;
	}
}

/// 按本地计时器驱动当前动作帧
function longzhu_clip_frame(_inst, _rate = 0) {
	if (_rate <= 0) _rate = longzhu_anim_rate();
	with (_inst) {
		if (longzhu_action == "") return;
		var _clip = longzhu_anims[$ longzhu_action];
		var _len = _clip[2] - _clip[1] + 1;
		var _f = floor(longzhu_timer / _rate);
		longzhu_frame = longzhu_once ? min(_f, _len - 1) : (_f mod _len);
		image_index = _clip[1] - 1 + longzhu_frame;
	}
}

/// 非循环动作是否已播完
function longzhu_clip_done(_inst, _rate = 0) {
	if (_rate <= 0) _rate = longzhu_anim_rate();
	if (!variable_struct_exists(_inst.longzhu_anims, _inst.longzhu_action)) return true;
	var _clip = _inst.longzhu_anims[$ _inst.longzhu_action];
	return _inst.longzhu_once && (_inst.longzhu_timer >= (_clip[2] - _clip[1] + 1) * _rate);
}

/// ---------- 3x3 邻域 ----------
/// 是否为攻击类卡片（docs/卡片分类.md：直射/投掷/多向/专业防空/追踪/灰烬 共 98 张）
function longzhu_attack_card_ids() {
	if (!variable_global_exists("longzhu_attack_id_list")) {
		global.longzhu_attack_id_list = [
			// 一、直射类
			"double_water_pipe", "tiancheng", "war_god", "triple_wine_rack", "sheshou",
			"love_god", "xiao_long_bao", "ice_long_bao", "double_long_bao", "double_ice_long_bao",
			"triple_long_bao", "triple_ice_long_bao", "coffee_cup", "water_tea_cup", "corn_shooter",
			"gatlin_long_bao", "gatlin_ice_long_bao", "king_long_bao", "king_triple_long_bao", "fenjima",
			"double_blade_snake", "yufengma", "laipishe", "pizza_oven", "gongjiang_god",
			"yanhuangma", "shennong_god", "tar_sprayer", "odin", "houyi_god",
			// 二、投掷类
			"spoon_rabbit", "ymir", "sugar_ball_pult", "egg_boiler_pult", "ice_egg_boiler_pult",
			"ronghedan_god", "grilled_lizard_pult", "shuangyu", "thor", "salad_pult",
			"chocolate_pult", "stinky_tofu_pult", "pan_fried_bun", "zhurong", "lizi_god",
			// 三、多向类
			"coal_starfish", "ronghehaixing", "ghost_god", "starrabbit", "rig", "youyu_god",
			// 七、专业防空类
			"tang_hu_lu", "power_god", "sausage", "hotdog_cannon", "donut", "joker",
			// 九、追踪类
			"takoyaki", "juxie", "moon_god", "athena", "curry_lobster_cannon", "zeus",
			"ice_god", "cold_drew", "hongliukaochuan", "hufa_god", "xiandima", "guiyuanma",
			// 十一、灰烬类
			"chocolate_cannon", "gaia", "durian", "dragon_fruit", "heian_god",
			"guangming_god", "mojie", "chunsun", "coke_bomb", "kettle_bomb",
			"wine_bottle_bomb", "whisky_bomb", "panduola_god", "rabbit_lantern", "delicacy_firework",
			"ice_bucket_bomb", "aquarius_elve", "pufferfish", "baiyang", "bull_firework",
			"save_god", "yeziguo", "qingse_shishi", "flour_sack", "mouse_clip",
			"steel_wool", "skewer_bomb", "chili_powder", "dandantu", "mixian"
		];
	}
	return global.longzhu_attack_id_list;
}

/// 卡片是否为「攻击类」
function longzhu_is_attack_card(_card) {
	if (!instance_exists(_card) || _card.hp <= 0) return false;
	return array_get_index(longzhu_attack_card_ids(), _card.plant_id) != -1;
}

/// 收集以 (_col,_row) 为中心的 3x3 范围内所有存活卡片（含中心格），返回实例数组
function longzhu_cards_in_3x3(_col, _row) {
	var _out = [];
	for (var _c = _col - 1; _c <= _col + 1; ++_c) {
		if (_c < 0 || _c >= global.grid_cols) continue;
		for (var _r = _row - 1; _r <= _row + 1; ++_r) {
			if (_r < 0 || _r >= global.grid_rows) continue;
			var _list = ds_grid_get(global.grid_plants, _c, _r);
			var _n = ds_list_size(_list);
			for (var _i = 0; _i < _n; ++_i) {
				var _inst = _list[| _i];
				if (instance_exists(_inst) && _inst.hp > 0) array_push(_out, _inst);
			}
		}
	}
	return _out;
}

/// ---------- 卡片效果 ----------
/// 催眠：置为睡眠状态（卡片 Step 会自动生成睡眠特效）
function longzhu_sleep_card(_card) {
	if (!instance_exists(_card) || _card.hp <= 0) return;
	if (_card.plant_id == "player") return;
	// 处于米线清醒印记期间不可被催眠
	if (_card.awake_buff_timer > 0) return;
	with (_card) { state = CARD_STATE.SLEEP; }
}

/// 清醒：写入清醒计时器，期间卡片会自行脱离睡眠且不会被再次催眠
/// 封印期间每 15s 在 3x3 内每张卡片右上角播放一次 spr_mixian_effect2
function longzhu_awake_card(_card) {
	if (!instance_exists(_card) || _card.hp <= 0) return;
	if (_card.plant_id == "player") return;
	var _pillar_id = id;
	with (_card) {
		awake_buff_timer = max(awake_buff_timer, LONGZHU_AWAKE_TIME);
		mixian_awake_source = _pillar_id;

		var _fx = instance_create_depth(x + 34, y - 62, depth - 1, obj_mixian_fx);
		_fx.fx_sprite = spr_mixian_effect2;
		_fx.fx_frames = sprite_get_number(spr_mixian_effect2);
		_fx.fx_rate = 5;
	}
}

/// 龙柱解封时清除由它施加的清醒印记
function longzhu_clear_awake_source(_pillar) {
	with (obj_card_parent) {
		if (variable_instance_exists(id, "mixian_awake_source") && mixian_awake_source == _pillar) {
			mixian_awake_source = noone;
			awake_buff_timer = 0;
		}
	}
}

/// 摧毁：清空血量，走卡片既有死亡流程（Destroy 事件会清理网格）
function longzhu_destroy_card(_card) {
	if (!instance_exists(_card) || _card.hp <= 0) return;
	if (_card.plant_id == "player") return; // 龙柱只作用于卡片，不杀死玩家角色
	if (_card.invincible) return;
	with (_card) { hp = 0; event_user(2); }
}

/// 保护：复用星穹马一转的「减伤」机制（卡片自身字段，无需独立对象）
/// —— 写入 zodiac_guard_time / zodiac_guard_hits / zodiac_guard_hp，
///    由 obj_card_parent/Step_0.gml 与 Other_12.gml 每步自动回补血量、抵挡伤害（含致命伤）。
function longzhu_protect_card(_card) {
	if (!instance_exists(_card) || _card.hp <= 0) return;
	// 已在保护中（例如星穹马已施加）则不再重复覆盖
	if (variable_instance_exists(_card, "zodiac_guard_time") && _card.zodiac_guard_time > 0) return;
	variable_instance_set(_card, "zodiac_guard_time", LONGZHU_PROTECT_TIME);
	variable_instance_set(_card, "zodiac_guard_hits", LONGZHU_PROTECT_HITS);
	variable_instance_set(_card, "zodiac_guard_hp", _card.hp);
}

/// 感染：把攻击类卡片替换为【青苹果】（该格暂时不再有卡片）
function longzhu_infect_card(_card, _owner) {
	if (!instance_exists(_card) || _card.hp <= 0) return noone;
	var _cx = _card.x, _cy = _card.y, _cd = _card.depth;
	var _col = _card.grid_col, _row = _card.grid_row;
	with (_card) { hp = 0; event_user(2); }
	var _apple = instance_create_depth(_cx, _cy, _cd + LONGZHU_APPLE_DEPTH_OFFSET, obj_longzhu_green_apple);
	_apple.col = _col;
	_apple.row = _row;
	_apple.longzhu_owner = _owner;
	return _apple;
}

/// ---------- 贪婪：火苗 ----------
/// 重算火苗上限（每步调用；无贪婪龙柱时保持基础值）
function longzhu_flame_cap_refresh() {
	if (!variable_global_exists("flame_cap_base")) global.flame_cap_base = 15000;
	var _cap = global.flame_cap_base;
	var _unsealed = 0, _sealed = 0;
	with (obj_longzhu) {
		if (longzhu_kind != "huang") continue;
		if (longzhu_sealed) _sealed++; else _unsealed++;
	}
	var _total = _unsealed + _sealed;
	// 全体贪婪龙柱被封印后，火苗上限提升至基础值（15000）
	if (_total > 0) _cap = _sealed == _total ? global.flame_cap_base : LONGZHU_GREEDY_LIMIT + 500 * _sealed;
	global.flame_cap = _cap;
	return _cap;
}

/// 当前火苗上限
function longzhu_flame_cap() {
	if (!variable_global_exists("flame_cap")) longzhu_flame_cap_refresh();
	return global.flame_cap;
}

/// 立即把火苗扣减至当前上限（米线断裂时调用）
function longzhu_greedy_flame_clamp() {
	var _cap = longzhu_flame_cap_refresh();
	if (global.flame > _cap) global.flame = _cap;
}

/// 贪婪：把 3x3 内卡片的部分耗能以火苗形式返还
function longzhu_greedy_return_flame(_cards) {
	var _gain = 0;
	for (var _i = 0; _i < array_length(_cards); ++_i) {
		var _c = _cards[_i];
		if (!instance_exists(_c) || _c.hp <= 0) continue;
		_gain += max(0, _c.cost) * LONGZHU_GREEDY_RETURN_RATIO;
	}
	if (_gain <= 0) return 0;
	var _cap = longzhu_flame_cap();
	global.flame = min(global.flame + round(_gain), _cap);
	return round(_gain);
}

/// ---------- 傲慢：红苹果子弹 ----------
/// 场上存活老鼠按到 (_px,_py) 的距离由近到远排序
function longzhu_enemies_by_distance(_px, _py) {
	var _mice = [];
	with (obj_enemy_parent) {
		if (hp > 0) array_push(_mice, id);
	}
	var _n = array_length(_mice);
	for (var _i = 1; _i < _n; ++_i) {
		var _key = _mice[_i];
		var _kd = point_distance(_px, _py, _key.x, _key.y);
		var _j = _i - 1;
		while (_j >= 0 && point_distance(_px, _py, _mice[_j].x, _mice[_j].y) > _kd) {
			_mice[_j + 1] = _mice[_j];
			--_j;
		}
		_mice[_j + 1] = _key;
	}
	return _mice;
}

/// 距离 (_px,_py) 最近的老鼠（无则 noone）
function longzhu_nearest_enemy(_px, _py) {
	var _best = noone, _best_d = 1000000000;
	with (obj_enemy_parent) {
		if (hp <= 0) continue;
		var _d = point_distance(_px, _py, x, y);
		if (_d < _best_d) { _best = id; _best_d = _d; }
	}
	return _best;
}

/// 向最近的若干老鼠发射 _count 枚追踪红苹果
function longzhu_fire_red_apples(_count, _owner, _px, _py, _depth) {
	var _mice = longzhu_enemies_by_distance(_px, _py);
	var _n = array_length(_mice);
	if (_n == 0) return 0;
	for (var _i = 0; _i < _count; ++_i) {
		var _b = instance_create_depth(_px, _py, _depth + LONGZHU_APPLE_DEPTH_OFFSET, obj_longzhu_red_apple);
		_b.longzhu_target = _mice[_i mod _n];
		_b.longzhu_owner = _owner;
		_b.damage = LONGZHU_RED_APPLE_DAMAGE;
	}
	return _count;
}

/// 对老鼠造成伤害（走敌人既有受击事件）
function longzhu_damage_mouse(_mouse, _damage) {
	if (!instance_exists(_mouse) || _mouse.hp <= 0) return;
	with (_mouse) { hp -= _damage; event_user(0); }
}

/// 青苹果为同格老鼠回复体力
function longzhu_heal_mouse(_mouse, _amount) {
	if (!instance_exists(_mouse) || _mouse.hp <= 0) return;
	with (_mouse) {
		var _cap = variable_instance_exists(id, "maxhp") ? maxhp : hp + _amount;
		hp = min(_cap, hp + _amount);
	}
}

/// 米线净化瞬间立即施加一次本柱效果（松露大厅=清醒，百味关=保护，贪婪=返还火苗）
/// 净化发生在米线 Step 中，此时 longzhu_sealed 可能尚未由龙柱 Step 更新，
/// 因此这里直接按「已封印」分支处理，避免误触发未封印效果。
function longzhu_purify_effect(_pillar) {
	if (!instance_exists(_pillar)) return;
	with (_pillar) {
		var _cards = longzhu_cards_in_3x3(col, row);
		var _n = array_length(_cards);
		switch (longzhu_kind) {
			case "cheng":
				for (var _i = 0; _i < _n; ++_i) longzhu_awake_card(_cards[_i]);
				break;
			case "lv":
				for (var _i = 0; _i < _n; ++_i) longzhu_protect_card(_cards[_i]);
				break;
			case "huang":
				longzhu_greedy_return_flame(_cards);
				break;
		}
		longzhu_effect_timer = 0;
	}
}

/// ---------- 龙柱周期效果总入口（在 obj_longzhu 实例内调用） ----------
function longzhu_apply_effect() {
	var _cards = longzhu_cards_in_3x3(col, row);
	var _n = array_length(_cards);
	var _i = 0;
	switch (longzhu_kind) {
		// 松露大厅（橙）：未封印 → 催眠；已封印 → 清醒
		case "cheng":
			for (_i = 0; _i < _n; ++_i) {
				if (longzhu_sealed) longzhu_awake_card(_cards[_i]);
				else longzhu_sleep_card(_cards[_i]);
			}
			break;

		// 百味关（绿）：未封印 → 摧毁；已封印 → 保护
		case "lv":
			for (_i = 0; _i < _n; ++_i) {
				if (longzhu_sealed) longzhu_protect_card(_cards[_i]);
				else longzhu_destroy_card(_cards[_i]);
			}
			break;

		// 贪婪（黄）：已封印 → 返还火苗（未封印时的上限限制由 longzhu_flame_cap_refresh 持续生效）
		case "huang":
			if (longzhu_sealed) longzhu_greedy_return_flame(_cards);
			break;

		// 傲慢（青绿）：未封印 → 感染成青苹果；已封印 → 按攻击卡数量发射红苹果
		case "lv2":
			if (!longzhu_sealed) {
				for (_i = 0; _i < _n; ++_i) {
					if (longzhu_is_attack_card(_cards[_i])) longzhu_infect_card(_cards[_i], id);
				}
			} else {
				var _atk_n = 0;
				for (_i = 0; _i < _n; ++_i) {
					if (longzhu_is_attack_card(_cards[_i])) _atk_n++;
				}
				if (_atk_n > 0) longzhu_fire_red_apples(_atk_n, id, x, y, depth);
			}
			break;
	}
}

/// ---------- 米线接口 ----------
/// 点到线段的最短距离
function longzhu_point_segment_distance(_px, _py, _x1, _y1, _x2, _y2) {
	var _dx = _x2 - _x1, _dy = _y2 - _y1;
	var _len2 = _dx * _dx + _dy * _dy;
	if (_len2 <= 0) return point_distance(_px, _py, _x1, _y1);
	var _t = clamp(((_px - _x1) * _dx + (_py - _y1) * _dy) / _len2, 0, 1);
	return point_distance(_px, _py, _x1 + _dx * _t, _y1 + _dy * _t);
}

/// 米线每步上报：线段 (_x1,_y1)-(_x2,_y2) 经过的龙柱被封印
function longzhu_bridge_connect(_owner, _x1, _y1, _x2, _y2) {
	var _r = max(global.grid_cell_size_x, global.grid_cell_size_y) * 0.6;
	with (obj_longzhu) {
		if (longzhu_point_segment_distance(x, y, _x1, _y1, _x2, _y2) <= _r) {
			longzhu_bridge_touch = true;
			longzhu_bridge_owner = _owner;
		}
	}
}

/// 米线断裂 / 被摧毁：立刻解封并（贪婪）扣减火苗
function longzhu_bridge_disconnect(_owner) {
	with (obj_longzhu) {
		if (longzhu_bridge_owner != _owner) continue;
		longzhu_bridge_owner = noone;
		longzhu_bridge_touch = false;
		if (longzhu_sealed) {
			longzhu_sealed = false;
			longzhu_clip_set(id, "飞起", true);
			longzhu_effect_timer = 0;
			longzhu_clear_awake_source(id);
		}
	}
	longzhu_greedy_flame_clamp();
}

/// 清空所有龙柱的本步米线触碰状态
function longzhu_bridge_clear() {
	with (obj_longzhu) {
		longzhu_bridge_touch = false;
		longzhu_bridge_owner = noone;
	}
}
