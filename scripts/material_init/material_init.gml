function material_init(){
	material_registry_init()
	register_material("natural_spices",{"name":"天然香料",
										"description":"天然香料：强化1~6星卡片所需材料",
										"icon":0,
										"pos_x":0,
										"pos_y":0})
	register_material("secret_spices",{"name":"秘制香料",
										"description":"秘制香料：强化7~10星卡片所需材料\n在火山岛关卡获取",
										"icon":1,
										"pos_x":1,
										"pos_y":0})
	register_material("royal_spices",{"name":"皇室香料",
										"description":"皇室香料：强化11~16星卡片所需材料\n在浮空岛卤料花园之后的关卡获取",
										"icon":2,
										"pos_x":2,
										"pos_y":0})
	register_material("clover_1",{"name":"1级四叶草",
										"description":"1级四叶草：将卡片突破至7星所需材料\n在深渊岛之后的关卡获取",
										"icon":3,
										"pos_x":0,
										"pos_y":1})
	register_material("clover_2",{"name":"2级四叶草",
										"description":"2级四叶草：将卡片突破至10星所需材料\n在火山岛雪顶火山之后的关卡获取",
										"icon":4,
										"pos_x":1,
										"pos_y":1})
	register_material("clover_3",{"name":"3级四叶草",
										"description":"3级四叶草：将卡片突破至13星所需材料\n在浮空岛十三香中心岛之后的关卡获取",
										"icon":5,
										"pos_x":2,
										"pos_y":1})
	register_material("clover_4",{"name":"4级四叶草",
										"description":"4级四叶草：将卡片突破至14星所需材料\n等待星际穿越开放获取",
										"icon":9,
										"pos_x":3,
										"pos_y":1})
	register_material("less_crystal",{"name":"初级强化水晶",
										"description":"初级强化水晶：强化1~5星宝石所需材料",
										"icon":6,
										"pos_x":0,
										"pos_y":2})
	register_material("middle_crystal",{"name":"中级强化水晶",
										"description":"中级强化水晶：强化6~10星宝石所需材料\n在火山岛关卡获取",
										"icon":7,
										"pos_x":1,
										"pos_y":2})
	register_material("advanced_crystal",{"name":"高级强化水晶",
										"description":"高级强化水晶：强化11~15星宝石所需材料\n等待星际穿越开放获取",
										"icon":8,
										"pos_x":2,
										"pos_y":2})
	register_material("copper_cookbook_fragment",{"name":"铜食谱碎片",
										"description":"铜食谱碎片：解锁上等佳肴槽位所需材料\n在火山遗迹的瀑布遗迹获取",
										"icon":10,
										"pos_x":0,
										"pos_y":3})
	register_material("silver_cookbook_fragment",{"name":"银食谱碎片",
										"description":"银食谱碎片：解锁秘制佳肴槽位所需材料\n在火山遗迹的丛林遗迹获取",
										"icon":11,
										"pos_x":1,
										"pos_y":3})
	register_material("gold_cookbook_fragment",{"name":"金食谱碎片",
										"description":"金食谱碎片：解锁极品佳肴槽位所需材料\n在火山遗迹的基地遗迹获取",
										"icon":12,
										"pos_x":2,
										"pos_y":3})
	register_material("oracle_stone",{"name": "神谕之石",
										"description": "神谕之石：在诸神商店兑换神使和凭证所需材料",
										"icon": 13,        // 取决于图集中下一个可用的图标索引
										"pos_x": 3,       // 在背包网格中的显示位置
										"pos_y": 0
	});
	register_material("cross_server_gold_medal",{"name": "黄金徽章",
										"description": "黄金徽章：跨服远征奖励，用于跨服黄金商店兑换",
										"icon": 0,
										"pos_x": 3,
										"pos_y": 2
	});
	register_material("cross_server_silver_medal",{"name": "白银徽章",
										"description": "白银徽章：跨服远征奖励，用于跨服白银商店兑换",
										"icon": 0,
										"pos_x": 3,
										"pos_y": 3
	});
	register_material("less_camp_coin",{"name":"补给币",
										"description":"补给币：购买番外卡片一转所需货币\n通关探险营地关卡获取",
										"icon":13,
										"pos_x":0,
										"pos_y":4})
	register_material("camp_coin",{"name":"营地金币",
										"description":"营地金币：购买番外卡片二转所需货币\n完成探险营地支线任务获取",
										"icon":14,
										"pos_x":1,
										"pos_y":4})
}

// ══════════════════════════════════════════════════════════════════════
// 道具「最低获取方式」（背包道具页悬停提示用）
//   只登记有明确产出的养成材料；顺序按关卡推进顺序排，不要随手重排
//   —— 玩家看到的第一项就是最早能刷到的关卡。
//   未登记的道具返回空数组，提示框不追加这一段。
// ══════════════════════════════════════════════════════════════════════

/// @function material_min_source_list(_material_id)
/// @desc 该道具最早可获取的关卡名数组（空数组 = 未登记）
function material_min_source_list(_material_id) {
	switch (_material_id) {
		case "natural_spices":    return ["曲奇岛"];
		case "secret_spices":     return ["芥末小屋", "勇士神殿", "松露大厅", "金枪鱼洋流", "戚风营地"];
		case "royal_spices":      return ["月桂天空", "勇士港口", "坚果高台", "天妇罗漩涡", "黑提丛林"];
		case "clover_1":          return ["深渊", "金枪鱼洋流", "戚风营地", "松露大厅"];
		case "clover_2":          return ["雪顶火山", "勇士神殿", "海葵洋流", "坚果高台"];
		case "clover_3":          return ["十三香中心岛", "勇士火山", "勇士天妇罗"];
		case "clover_4":          return ["诸神宝殿"];
		case "less_crystal":      return ["神殿"];
		case "middle_crystal":    return ["勇士神殿", "芥末小屋", "戚风营地", "金枪鱼洋流", "松露大厅"];
		case "advanced_crystal":  return ["诸神宝殿"];
	}
	return [];
}

/// @function material_min_source_text(_material_id[, _max_chars])
/// @desc 拼成提示框用的多行文本（未登记返回 ""）；每行最多 _max_chars 个字，
///       默认 18，超出就换行——tooltip 不做自动折行，太长会横向拉爆
///       注意：GML 少传实参会报 GM1020（多传不报），所以第二个参数必须靠
///       argument[1] 读取，不能写在形参列表里，否则单参调用编译不过
function material_min_source_text(_material_id) {
	var _list = material_min_source_list(_material_id);
	var _n = array_length(_list);
	if (_n <= 0) return "";
	var _max = (argument_count >= 2) ? argument[1] : 18;

	var _lines = [];
	var _cur = "";
	for (var i = 0; i < _n; i++) {
		var _item = _list[i];
		if (_cur == "") {
			_cur = _item;
			continue;
		}
		var _cand = _cur + "，" + _item;
		if (string_length(_cand) > _max) {
			array_push(_lines, _cur);
			_cur = _item;
		} else {
			_cur = _cand;
		}
	}
	if (_cur != "") array_push(_lines, _cur);

	var _txt = "最低获取方式：";
	for (var j = 0; j < array_length(_lines); j++) {
		_txt += "\n" + _lines[j];
	}
	return _txt;
}
