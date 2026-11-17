/// 合成屋 · 卡片强化页 / 上卡 的槽位与材料分配表
/// ---------------------------------------------------------------------------
/// 为什么要这张表：以前槽位坐标（主卡 / 香料 / 四叶草 / 保险金）散落在 obj_craft_bg/Draw_0
/// 里，每加一个槽就要改绘制代码；抽成表以后「改版面」= 改这张表，
/// 后面的「多香料 / 多四叶草上卡」逻辑也直接按 `spice_order` 往里填，不用再动绘制。
///
/// 坐标口径：**相对合成屋面板中心 (x, y) 的偏移**，和 obj_craft_bg 的 x / y 同一套。
///   slot 字段：id / dx / dy / kind(card|spices|clover) / scale / bg_spr / label_spr
///   label_spr 是 spr_craft_slot_text 的帧号（0 = 主卡 / 1 = 香料 / 2 = 四叶草）
///
/// 数量文字的落点（相对对应槽位中心）：
///   香料：数量在槽**右侧**（槽下方是主卡槽，写字会压主卡边框）
///   四叶草：数量在槽下方
/// ---------------------------------------------------------------------------
function craft_slot_table() {
	return {
		slots: [
			{ id: "main",   dx: -305, dy:  100, kind: "card",   scale: 1.8,
			  bg_spr: "spr_craft_slot_bg",     label_spr: 0 },
			{ id: "spice1", dx: -305, dy:  -20, kind: "spices", scale: 1.8,
			  bg_spr: "spr_craft_material_bg", label_spr: 1 },
			{ id: "spice2", dx: -425, dy:  100, kind: "spices", scale: 1.8,
			  bg_spr: "spr_craft_material_bg", label_spr: 1 },
			{ id: "spice3", dx: -197, dy:  100, kind: "spices", scale: 1.8,   // 与主卡间距 108（左 120，视觉上右槽更贴一点）
			  bg_spr: "spr_craft_material_bg", label_spr: 1 },
			{ id: "clover", dx: -525, dy:  223, kind: "clover", scale: 1.8,
			  bg_spr: "spr_craft_material_bg", label_spr: 2 }
		],

		// 香料填充顺序：默认第一个 → 左 → 右（现在只用得到第一个）
		spice_order: ["spice1", "spice2", "spice3"],

		// 数量 / 提示文字相对槽位中心的偏移
		text_ofs: {
			spices_x: 54,         // 香料数量：槽右侧
			spices_y: -8,
			spices_hint_y: 16,    // 「使用了高级香料」
			clover_y: 55,         // 四叶草数量：槽下方
			clover_hint_y: 80     // 「使用了高级四叶草」
		}
	};
}

/// @function craft_slot_lookup(_table, _id)
/// @desc 按 id 取槽位定义（找不到返回 undefined）
function craft_slot_lookup(_table, _id) {
	var _n = array_length(_table.slots);
	for (var i = 0; i < _n; i++) {
		if (_table.slots[i].id == _id) return _table.slots[i];
	}
	return undefined;
}
