/// 金马盛典 · 转转抽奖 / 幸运星兑换
/// ────────────────────────────────────────────────────────────────
/// 数值唯一事实源：改概率、保底、价格只动本文件，界面只读。
///
/// 奖池与保底对齐诸神宝殿（objects/obj_gods_hall_bg/Create_0.gml）：
///   金币 37.4%（与诸神 244/90/40 同比例）／四叶草 62%／幸运星 0.6%
///   每 50 抽一次保底：
///     偶数轮 → 80% 4 级四叶草 8/16/24/32（升满后固定 32）+ 20% 幸运星
///     奇数轮 → 100% 幸运星，60% / 20% / 15% / 5% → 5 / 10 / 15 / 25
///
/// 存档字段（global.save_data.player）：
///   zz_pulls      距上次保底已抽次数（0..49）
///   zz_pity_level 已触发保底次数（决定奇偶轮与四叶草档位）
///   zz_spent      累计消耗金币
/// 幸运星是材料（material_init 的 zz_star），走背包，不走玩家字段。

#macro ZZ_PITY_EVERY 50
#macro ZZ_STAR_ID "zz_star"

/// @desc 补齐存档字段（老存档没有这些字段）
function zz_save_init() {
	if (!variable_struct_exists(global.save_data.player, "zz_pulls"))      global.save_data.player.zz_pulls = 0;
	if (!variable_struct_exists(global.save_data.player, "zz_pity_level")) global.save_data.player.zz_pity_level = 0;
	if (!variable_struct_exists(global.save_data.player, "zz_spent"))      global.save_data.player.zz_spent = 0;
}

/// @desc 档位消耗（0=单抽 1=五连 2=五十连）
///   2026-11-20 用户口径：三档抽数为 1 / 5 / 50，单价统一 2 万/抽
///   （1 抽 2 万 / 5 抽 10 万 / 50 抽 100 万），中间档不再是十连。
function zz_cost(_tier) {
	switch (_tier) {
		case 0: return 20000;
		case 2: return 1000000;
	}
	return 100000;
}

/// @desc 档位抽数
function zz_pull_count(_tier) {
	switch (_tier) {
		case 0: return 1;
		case 2: return 50;
	}
	return 5;
}

/// @desc 档位按钮文案（金币数）
function zz_tier_label(_tier) {
	return string(zz_cost(_tier));
}

/// @desc 距离下次保底剩余次数
function zz_pity_left() {
	zz_save_init();
	return ZZ_PITY_EVERY - global.save_data.player.zz_pulls;
}

/// @desc 下次保底的档位说明（顶部文案用）
function zz_pity_tier_text() {
	zz_save_init();
	if (global.save_data.player.zz_pity_level mod 2 == 0) return "4级四叶草";
	return "幸运星";
}

/// @desc 普通奖池（权重合计 1000）
function zz_pool() {
	return [
		{id:"gold",      name:"金币",       qty:2000,  w:244},
		{id:"gold",      name:"金币",       qty:5000,  w:90},
		{id:"gold",      name:"金币",       qty:10000, w:40},
		{id:"clover_1",  name:"1级四叶草",  qty:1,     w:200},
		{id:"clover_2",  name:"2级四叶草",  qty:1,     w:180},
		{id:"clover_3",  name:"3级四叶草",  qty:1,     w:140},
		{id:"clover_4",  name:"4级四叶草",  qty:1,     w:70},
		{id:"clover_5",  name:"5级四叶草",  qty:1,     w:20},
		{id:"clover_6",  name:"6级四叶草",  qty:1,     w:7},
		{id:"clover_s",  name:"S级四叶草",  qty:1,     w:2},
		{id:"clover_ss", name:"SS级四叶草", qty:1,     w:1},
		{id:ZZ_STAR_ID,  name:"幸运星",     qty:5,     w:3},
		{id:ZZ_STAR_ID,  name:"幸运星",     qty:10,    w:2},
		{id:ZZ_STAR_ID,  name:"幸运星",     qty:25,    w:1}
	];
}

/// @desc 保底奖励；_level 为已触发的保底次数
function zz_pity_reward(_level) {
	if (_level mod 2 == 0) {
		if (irandom(99) < 80) {
			var _step = min(_level div 2, 3);
			var _qty_list = [8, 16, 24, 32];
			var _qty = _qty_list[_step];
			return {id:"clover_4", name:"4级四叶草", qty:_qty, pity:true};
		}
	}
	var _r = irandom(99);
	var _q = 5;
	if (_r < 60)       _q = 5;
	else if (_r < 80)  _q = 10;
	else if (_r < 95)  _q = 15;
	else               _q = 25;
	return {id:ZZ_STAR_ID, name:"幸运星", qty:_q, pity:true};
}

/// @desc 发奖（金币进 player.gold，幸运星/四叶草进背包材料）
function zz_grant(_r) {
	if (_r.id == "gold") {
		global.save_data.player.gold += _r.qty;
		return;
	}
	add_material_amount(_r.id, _r.qty);
}

/// @desc 抽一次；_give 省略时立即发放（批量抽奖传 false，由 zz_grant_batch 合并发放省存档）
function zz_roll_one(_give) {
	zz_save_init();
	var _is_pity = (global.save_data.player.zz_pulls >= ZZ_PITY_EVERY - 1);
	var _r = undefined;

	if (_is_pity) {
		_r = zz_pity_reward(global.save_data.player.zz_pity_level);
		global.save_data.player.zz_pity_level++;
		global.save_data.player.zz_pulls = 0;
	} else {
		var _pool = zz_pool();
		var _total = 0;
		for (var i = 0; i < array_length(_pool); i++) _total += _pool[i].w;
		var _rnd = irandom(_total - 1);
		for (var j = 0; j < array_length(_pool); j++) {
			_rnd -= _pool[j].w;
			if (_rnd < 0) {
				_r = {id:_pool[j].id, name:_pool[j].name, qty:_pool[j].qty, pity:false};
				break;
			}
		}
		if (is_undefined(_r)) _r = {id:_pool[0].id, name:_pool[0].name, qty:_pool[0].qty, pity:false};
		global.save_data.player.zz_pulls++;
	}

	var _should_give = (argument_count < 1) ? true : _give;
	if (_should_give) zz_grant(_r);
	return _r;
}

/// @desc 合并发放一批结果：同类合并，最多 10 次 add_material_amount（每次内部会存盘）
function zz_grant_batch(_items) {
	var _gold = 0;
	var _mats = {};
	for (var i = 0; i < array_length(_items); i++) {
		var _it = _items[i];
		if (_it.id == "gold") {
			_gold += _it.qty;
		} else {
			if (!variable_struct_exists(_mats, _it.id)) _mats[$ _it.id] = 0;
			_mats[$ _it.id] += _it.qty;
		}
	}
	if (_gold > 0) global.save_data.player.gold += _gold;
	var _keys = variable_struct_get_names(_mats);
	for (var k = 0; k < array_length(_keys); k++)
		add_material_amount(_keys[k], _mats[$ _keys[k]]);
	save_file(global.save_slot);
}

/// @desc 扣金币并批量抽奖
/// @return {ok, msg, items, cost, count}
function zz_pull_batch(_tier) {
	zz_save_init();
	var _cost = zz_cost(_tier);
	var _n = zz_pull_count(_tier);
	if (global.save_data.player.gold < _cost)
		return {ok:false, msg:"金币不足", items:[], cost:_cost, count:0};

	global.save_data.player.gold -= _cost;
	global.save_data.player.zz_spent += _cost;

	var _items = [];
	for (var i = 0; i < _n; i++) array_push(_items, zz_roll_one(false));
	zz_grant_batch(_items);
	return {ok:true, msg:"", items:_items, cost:_cost, count:_n};
}

/// @desc 按道具合并（五十连结算用）
function zz_aggregate(_items) {
	var _order = ["clover_1", "clover_2", "clover_3", "clover_4", "clover_5",
	              "clover_6", "clover_s", "clover_ss", ZZ_STAR_ID, "gold"];
	var _sum = {};
	var _pity = {};
	for (var i = 0; i < array_length(_items); i++) {
		var _it = _items[i];
		if (!variable_struct_exists(_sum, _it.id)) _sum[$ _it.id] = 0;
		_sum[$ _it.id] += _it.qty;
		if (_it.pity) _pity[$ _it.id] = true;
	}
	var _out = [];
	for (var k = 0; k < array_length(_order); k++) {
		var _id = _order[k];
		if (variable_struct_exists(_sum, _id) && _sum[$ _id] > 0)
			array_push(_out, {id:_id, qty:_sum[$ _id], pity:variable_struct_exists(_pity, _id)});
	}
	return _out;
}

/// @desc 道具显示名（材料 → 卡片 → 兜底 id）
function zz_item_name(_id) {
	if (_id == "gold") return "金币";
	// global.material_pool 是 ds_map，但 value 是 struct（register_material 传的是 {} 字面量）
	//   → 外层用 ds_map_exists，里层必须用 variable_struct_exists
	if (ds_map_exists(global.material_pool, _id)) {
		var _info = global.material_pool[? _id];
		if (variable_struct_exists(_info, "name")) return _info.name;
	}
	var _shape = get_plant_shape_data(_id, 0);
	if (_shape != undefined && ds_map_exists(_shape, "name")) return _shape[? "name"];
	return _id;
}

/// @desc 该卡片（0 形态）是否已解锁 —— 幸运星商店的卡片是「一次性」商品
function zz_card_owned(_id) {
	var _cards = global.save_data.unlocked_cards;
	for (var _k = 0; _k < array_length(_cards); _k++) {
		if (_cards[_k].id == _id) return true;
	}
	return false;
}

/// @desc 材料 id → spr_craft_material 帧号（与 material_init 的 icon 字段一致）
function zz_mat_frame(_id) {
	switch (_id) {
		case "clover_1":     return 3;
		case "clover_2":     return 4;
		case "clover_3":     return 5;
		case "clover_4":     return 9;
		case "clover_5":     return 19;
		case "clover_6":     return 20;
		case "clover_s":     return 21;
		case "clover_ss":    return 22;
		case "zz_star":      return 23;
		case "magic_spices": return 15;
		case "elf_spices":   return 16;
		case "angel_spices": return 17;
		case "saint_spices": return 18;
		// 三种老香料：幸运星商店已不卖，但强化界面 / 情报岛可能还要用这一层映射
		case "natural_spices": return 0;
		case "secret_spices":  return 1;
		case "royal_spices":   return 2;
	}
	return 0;
}

/// @desc 幸运星余额
function zz_star_amount() {
	return get_material_amount(ZZ_STAR_ID);
}

/// @desc 兑换商店商品表
///  2026-11-17 用户口径：
///    · 香料（皇室 / 魔幻 / 精灵 / 天使 / 圣灵）**全部下架**，改到跨服白银页按白银勋章卖
///    · 八张卡从跨服下架后放到这里，用幸运星换：幻幻鸡 66 / 百变蛇 108 / 战旗马 88 /
///      法师蛇 66 / 星星兔 54 / 炎炎兔 36 / 巫蛊蛇 36 / 旋风牛 36
///    · 四叶草 5/6/S/SS 保留
///  卡片带 card:true —— zz_buy_shop 据此走 unlock_card（一次性），否则走 add_material_amount
function zz_shop_list() {
	return [
		// ── 卡片（按价格从低到高，4 列刚好排满两行）──
		{id:"yanyantu",      qty:1, cost:36,  card:true},
		{id:"wugushe",       qty:1, cost:36,  card:true},
		{id:"xuanfengniu",   qty:1, cost:36,  card:true},
		{id:"starrabbit",    qty:1, cost:54,  card:true},
		{id:"magic_chicken", qty:1, cost:66,  card:true},
		{id:"fashishe",      qty:1, cost:66,  card:true},
		{id:"zhanqima",      qty:1, cost:88,  card:true},
		{id:"baibianshe",    qty:1, cost:108, card:true},
		// ── 四叶草 ──
		{id:"clover_5",      qty:3, cost:2},
		{id:"clover_6",      qty:3, cost:4},
		{id:"clover_s",      qty:3, cost:8},
		{id:"clover_ss",     qty:3, cost:16}
	];
}

/// @desc 兑换一件商品
/// 🔴 与玩法模式**无关**：普通 / 抽卡 / 欧皇 / 随机礼盒 / 海克斯 一律照常兑换
///    （2026-11-20 用户口径：抽卡、欧皇模式也要能正常兑换）。
///    商城（obj_shop_bg）那套「抽卡模式禁用卡片购买」是**金币商店**的口径，
///    幸运星兑换是活动货币、不属于抽卡路子，所以这里**不要**加 is_gacha_mode 之类的门禁。
///    之前抽卡/欧皇模式兑换不了，是商城的 obj_shop_buy_btn 与兑换页按钮逐像素重合、
///    抢走了鼠标点击（见 obj_shop_buy_btn/Mouse_4 顶部守卫），与这里的逻辑无关。
/// @return {ok, msg}
function zz_buy_shop(_idx) {
	var _list = zz_shop_list();
	if (_idx < 0 || _idx >= array_length(_list)) return {ok:false, msg:"商品不存在"};
	var _it = _list[_idx];
	var _is_card = variable_struct_exists(_it, "card") && _it.card;
	if (_is_card && zz_card_owned(_it.id))
		return {ok:false, msg:"已拥有该卡片"};
	if (zz_star_amount() < _it.cost)
		return {ok:false, msg:"幸运星不足（需 " + string(_it.cost) + "）"};

	add_material_amount(ZZ_STAR_ID, -_it.cost);
	if (_is_card) {
		// 卡片解锁走全局 unlock_card（第三参 = 形态 0，末参 = 技能上限，与跨服商店同口径）
		unlock_card(_it.id, 0, 0, global.save_data.unlocked_items.max_skill_level);
		save_file(global.save_slot);
		return {ok:true, msg:"兑换成功：" + zz_item_name(_it.id)};
	}
	add_material_amount(_it.id, _it.qty);
	return {ok:true, msg:"兑换成功：" + zz_item_name(_it.id) + " ×" + string(_it.qty)};
}
