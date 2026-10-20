function craft_rule_registry_init(){
	global.card_craft_rules = ds_map_create()
	global.gem_craft_rules = ds_map_create()
}

function register_card_craft_rule(target_level,info){
	ds_map_add(global.card_craft_rules,target_level,info)
}

function get_card_craft_rule(target_level){
	return ds_map_find_value(global.card_craft_rules,target_level)
}

function register_gem_craft_rule(target_level,info){
	ds_map_add(global.gem_craft_rules,target_level,info)
}

function get_gem_craft_rule(target_level){
	return ds_map_find_value(global.gem_craft_rules,target_level)
}

function craft_rule_init(){
	craft_rate_settings_init()
	craft_rule_registry_init()
	register_card_craft_rule(
		"1",
		{
		"spices_require":"natural_spices",
		"spices_amount":5,
		"clover_require":"none",
		"clover_amount":0,
		"gold_amount":300
		}
	)
	register_card_craft_rule(
		"2",
		{
		"spices_require":"natural_spices",
		"spices_amount":10,
		"clover_require":"none",
		"clover_amount":0,
		"gold_amount":300
		}
	)
	register_card_craft_rule(
		"3",
		{
		"spices_require":"natural_spices",
		"spices_amount":15,
		"clover_require":"none",
		"clover_amount":0,
		"gold_amount":300
		}
	)
	register_card_craft_rule(
		"4",
		{
		"spices_require":"natural_spices",
		"spices_amount":25,
		"clover_require":"none",
		"clover_amount":0,
		"gold_amount":300
		}
	)
	register_card_craft_rule(
		"5",
		{
		"spices_require":"natural_spices",
		"spices_amount":35,
		"clover_require":"none",
		"clover_amount":0,
		"gold_amount":300
		}
	)
	register_card_craft_rule(
		"6",
		{
		"spices_require":"natural_spices",
		"spices_amount":55,
		"clover_require":"none",
		"clover_amount":0,
		"gold_amount":400
		}
	)
	register_card_craft_rule(
		"7",
		{
		"spices_require":"secret_spices",
		"spices_amount":55,
		"clover_require":"clover_1",
		"clover_amount":1,
		"gold_amount":400
		}
	)
	register_card_craft_rule(
		"8",
		{
		"spices_require":"secret_spices",
		"spices_amount":100,
		"clover_require":"none",
		"clover_amount":0,
		"gold_amount":700
		}
	)
	register_card_craft_rule(
		"9",
		{
		"spices_require":"secret_spices",
		"spices_amount":150,
		"clover_require":"none",
		"clover_amount":0,
		"gold_amount":700
		}
	)
	register_card_craft_rule(
		"10",
		{
		"spices_require":"secret_spices",
		"spices_amount":150,
		"clover_require":"clover_2",
		"clover_amount":2,
		"gold_amount":1300
		}
	)
	register_card_craft_rule(
		"11",
		{
		"spices_require":"royal_spices",
		"spices_amount":200,
		"clover_require":"none",
		"clover_amount":0,
		"gold_amount":2600
		}
	)
	register_card_craft_rule(
		"12",
		{
		"spices_require":"royal_spices",
		"spices_amount":245,
		"clover_require":"none",
		"clover_amount":0,
		"gold_amount":2600
		}
	)
	register_card_craft_rule(
		"13",
		{
		"spices_require":"royal_spices",
		"spices_amount":300,
		"clover_require":"clover_3",
		"clover_amount":3,
		"gold_amount":5200
		}
	)
	register_card_craft_rule(
		"14",
		{
		"spices_require":"royal_spices",
		"spices_amount":355,
		"clover_require":"clover_4",
		"clover_amount":4,
		"gold_amount":5200
		}
	)
	register_card_craft_rule(
		"15",
		{
		"spices_require":"royal_spices",
		"spices_amount":420,
		"clover_require":"none",
		"clover_amount":0,
		"gold_amount":10000
		}
	)
	register_card_craft_rule(
		"16",
		{
		"spices_require":"royal_spices",
		"spices_amount":500,
		"clover_require":"none",
		"clover_amount":0,
		"gold_amount":10000
		}
	)
	
	
	register_gem_craft_rule(
		"1",
		{
		"crystal_require":"less_crystal",
		"crystal_amount":5,
		"gold_amount":300
		}
	)
	register_gem_craft_rule(
		"2",
		{
		"crystal_require":"less_crystal",
		"crystal_amount":10,
		"gold_amount":300
		}
	)
	register_gem_craft_rule(
		"3",
		{
		"crystal_require":"less_crystal",
		"crystal_amount":15,
		"gold_amount":300
		}
	)
	register_gem_craft_rule(
		"4",
		{
		"crystal_require":"less_crystal",
		"crystal_amount":25,
		"gold_amount":300
		}
	)
	register_gem_craft_rule(
		"5",
		{
		"crystal_require":"less_crystal",
		"crystal_amount":35,
		"gold_amount":300
		}
	)
	register_gem_craft_rule(
		"6",
		{
		"crystal_require":"middle_crystal",
		"crystal_amount":55,
		"gold_amount":400
		}
	)
	register_gem_craft_rule(
		"7",
		{
		"crystal_require":"middle_crystal",
		"crystal_amount":75,
		"gold_amount":400
		}
	)
	register_gem_craft_rule(
		"8",
		{
		"crystal_require":"middle_crystal",
		"crystal_amount":100,
		"gold_amount":700
		}
	)
	register_gem_craft_rule(
		"9",
		{
		"crystal_require":"middle_crystal",
		"crystal_amount":130,
		"gold_amount":700
		}
	)
	register_gem_craft_rule(
		"10",
		{
		"crystal_require":"middle_crystal",
		"crystal_amount":160,
		"gold_amount":1300
		}
	)
	register_gem_craft_rule(
		"11",
		{
		"crystal_require":"advanced_crystal",
		"crystal_amount":200,
		"gold_amount":2600
		}
	)
	register_gem_craft_rule(
		"12",
		{
		"crystal_require":"advanced_crystal",
		"crystal_amount":245,
		"gold_amount":2600
		}
	)
	register_gem_craft_rule(
		"13",
		{
		"crystal_require":"advanced_crystal",
		"crystal_amount":300,
		"gold_amount":5200
		}
	)
	register_gem_craft_rule(
		"14",
		{
		"crystal_require":"advanced_crystal",
		"crystal_amount":355,
		"gold_amount":5200
		}
	)
	register_gem_craft_rule(
		"15",
		{
		"crystal_require":"advanced_crystal",
		"crystal_amount":420,
		"gold_amount":10000
		}
	)
}

#region 概率强化：参数、公式与判定
function craft_rate_settings_init(){
	var _enabled = true
	if !is_undefined(global.craft_rate_enabled) _enabled = global.craft_rate_enabled
	var _dropstar = true
	if !is_undefined(global.craft_dropstar_enabled) _dropstar = global.craft_dropstar_enabled
	var _assure = false
	if !is_undefined(global.craft_assure_enabled) _assure = global.craft_assure_enabled
	global.craft_rate = {
		enabled: _enabled,
		dropstar_enabled: _dropstar,
		dropstar_min: 5,
		assure_enabled: _assure,
		// 保险金费用：直接查表，依次对应 1★~15★（5★ 及以下不掉星所以是 0）；
		// 固定价格，不乘难度倍率（2026-10-19 按用户要求去掉）
		assure_gold_table: [0, 0, 0, 0, 0, 3000, 3900, 5800, 8200, 11600, 50000, 100000, 250000, 350000, 500000],
	// 升星率：分段衰减。1★ 固定必成；2★ 起逐级乘衰减并取整，换挡点见 tierN_at
	// 现值 → 1★ 100 / 2-5★ 90..66（-0.90）/ 6★ 49（-0.74，台阶）/ 7-9★ 43..32（-0.87）/ 10★ 16（-0.50，跳楼）/ 11-15★ 11..3（-0.70）/ 16★ 1（-0.34）
		rate_base: 100, rate_max: 100, rate_min: 1,
		// 随机浮动：每个卡片/宝石各自一个随机值 r(-1~1)，启动时随第一次用到生成、本次启动内固定。
		// 2★~spread_max_level（11★）按比例浮动 r*spread_ratio（低概率浮动幅度自然更小）；
		// 12★ 起改用固定点数浮动 r*spread_flat（幅度比前面小）；1★ 必成不浮动
		spread_ratio: 0.08, spread_max_level: 11, spread_flat: 0.57,
		tier1_decay: 0.90, tier2_at: 6, tier2_decay: 0.74,
		tier3_at: 7, tier3_decay: 0.87, tier4_at: 10, tier4_decay: 0.50,
		tier5_at: 11, tier5_decay: 0.70, tier6_at: 16, tier6_decay: 0.34,
		pity_bonus_min: 4, pity_bonus_max: 7,
		// 失败补偿最多累计 N 次：第 N+1 次起失败不再加成功率（成功升星会清零，不残留）
		pity_bonus_max_stack: 5,
		// 保底：连续失败满 N 次后强制必成。0 = 关闭（2026-10-14 按用户要求关掉，只剩每次失败的随机加成），需要时改回 5
		pity_guarantee: 0,
		fail_material_ratio: 1.0,
		fail_gold_ratio:     1.0
	}
}

function craft_rate_settings(){
	if is_undefined(global.craft_rate) craft_rate_settings_init()
	return global.craft_rate
}

function craft_dropstar_can_drop(current_level){
	var _s = craft_rate_settings()
	return _s.dropstar_enabled && current_level > _s.dropstar_min
}

/// @func craft_assure_active()
/// @desc 保险金是否生效：勾选了保险金，且失败掉星开着（否则没星可保）
function craft_assure_active(){
	var _s = craft_rate_settings()
	return _s.assure_enabled && _s.dropstar_enabled
}

/// @func craft_assure_gold(current_level)
/// @desc 保险金费用：查 assure_gold_table（依次对应 1★~15★，5★ 及以下为 0，那几星不掉星）；
///       固定价格，不乘难度倍率；超出表长按最高档
function craft_assure_gold(current_level){
	var _s = craft_rate_settings()
	var _idx = clamp(current_level - 1, 0, array_length(_s.assure_gold_table) - 1)
	return _s.assure_gold_table[_idx]
}

/// @func craft_rate_base(target_level)
/// @desc 分段衰减的基础升星率（不含保底）：1★ 必成，其后逐级乘当前档位的衰减并取整
function craft_rate_base(target_level){
	var _s = craft_rate_settings()
	if target_level <= 1 return _s.rate_max
	var _rate = _s.rate_base
	for (var _lv = 2; _lv <= target_level; _lv++){
		if _lv >= _s.tier6_at _rate *= _s.tier6_decay
		else if _lv >= _s.tier5_at _rate *= _s.tier5_decay
		else if _lv >= _s.tier4_at _rate *= _s.tier4_decay
		else if _lv >= _s.tier3_at _rate *= _s.tier3_decay
		else if _lv >= _s.tier2_at _rate *= _s.tier2_decay
		else _rate *= _s.tier1_decay
		_rate = round(_rate)
	}
	return clamp(_rate, _s.rate_min, _s.rate_max)
}

/// @func craft_rate_spread(id)
/// @desc 该卡片/宝石本次启动的随机浮动值（-1 ~ 1）：每个 id 各自独立，本次启动内固定不变
function craft_rate_spread(_id){
	if _id == "" return 0
	if is_undefined(global.craft_rate_spread) global.craft_rate_spread = {}
	var _key = string(_id)
	if variable_struct_exists(global.craft_rate_spread, _key){
		return variable_struct_get(global.craft_rate_spread, _key)
	}
	var _spread = random_range(-1, 1)
	variable_struct_set(global.craft_rate_spread, _key, _spread)
	return _spread
}

/// @func craft_rate_rolled(id, target_level)
/// @desc 带随机浮动的基础升星率（不含保底，保留小数）：1★ 必成不浮动；
///       2★~spread_max_level 按比例浮动，其之上按固定点数浮动（幅度更小）
function craft_rate_rolled(_id, target_level){
	var _s = craft_rate_settings()
	var _rate = craft_rate_base(target_level)
	if target_level <= 1 return _rate
	var _r = craft_rate_spread(_id)
	if target_level <= _s.spread_max_level return min(_rate * (1 + _r * _s.spread_ratio), _s.rate_max)
	return clamp(_rate + _r * _s.spread_flat, _s.rate_min, _s.rate_max)
}

function craft_rate_with_pity(_id, target_level, bonus, fail_streak){
	var _s = craft_rate_settings()
	if !_s.enabled return 100
	var _rate = craft_rate_rolled(_id, target_level)
	if is_undefined(bonus) bonus = 0
	if is_undefined(fail_streak) fail_streak = 0
	_rate += bonus
	if _s.pity_guarantee > 0 && fail_streak >= _s.pity_guarantee _rate = 100
	return clamp(_rate, 0, 100)
}

// 卡片与宝石共用同一张升星率表（用户要求「宝石跟同一套」），保留各自的函数名方便以后分化
function get_card_craft_rate(card_id, target_level, bonus, fail_streak){
	return craft_rate_with_pity(card_id, target_level, bonus, fail_streak)
}

function get_gem_craft_rate(gem_id, target_level, bonus, fail_streak){
	return craft_rate_with_pity(gem_id, target_level, bonus, fail_streak)
}

function get_card_craft_rate_base(card_id, target_level){
	var _s = craft_rate_settings()
	if !_s.enabled return 100
	return craft_rate_rolled(card_id, target_level)
}

function get_gem_craft_rate_base(gem_id, target_level){
	var _s = craft_rate_settings()
	if !_s.enabled return 100
	return craft_rate_rolled(gem_id, target_level)
}

function get_card_craft_rate_now(card_id){
	if card_id == "" return 0
	var _info = get_card_info_simple(card_id)
	if _info == false return 0
	return get_card_craft_rate(card_id, _info.max_level + 1, get_card_craft_bonus(card_id), get_card_fail_streak(card_id))
}

function get_gem_craft_rate_now(gem_id){
	if gem_id == "" return 0
	return get_gem_craft_rate(gem_id, get_gem_max_level(gem_id) + 1, get_gem_craft_bonus(gem_id), get_gem_fail_streak(gem_id))
}

function craft_roll(rate){
	if !craft_rate_settings().enabled return true
	return random(100) < rate
}

function craft_rate_color(rate){
	if rate >= 80 return c_lime
	if rate >= 50 return c_yellow
	if rate >= 25 return c_orange
	return c_red
}
#endregion
