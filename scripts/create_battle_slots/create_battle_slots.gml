/// @function create_battle_slots()
/// @desc 根据当前卡组创建战斗卡槽（空槽跳过，非空卡按顺序排布）
function create_battle_slots() {
    var start_x = 535;
    var y_pos = 90;
    var x_spacing = 90;
	var y_spacing = 118;
    
    var n = 0;
    var max_slot = deck_slot_max();
    for(var i = 0; i < max_slot; i++) {
        if (deck_slot_is_empty(i)) continue; // 跳过空槽
        var deck_entry = global.selected_deck[| i];
        if (deck_entry[? "card_id"] == "lihe" && !is_random_gift_mode()) continue;
        // 卡组里缓存的是「加入卡组那一刻」的形态数据。之后在魔塔/商店转职过的话，
        // 缓存还停在第 0 转 —— 表现出来就是「已经是 2 转了，卡槽里还是 0 转外观」，
        // 放下去也是 0 转数值。这里每场开打前按存档里的当前形态重新取一次。
        var _card_id = deck_entry[? "card_id"];
        var _slot_shape = deck_entry[? "shape"];
        var _save_info = get_card_info_simple(_card_id);
        if (_save_info != false && variable_struct_exists(_save_info, "shape")) {
            _slot_shape = max(_slot_shape, _save_info.shape);
        }
        var card_data = deck_get_card_data(_card_id, _slot_shape);
        if (card_data == noone) card_data = deck_entry[? "data"];
        var inst = noone
		if n <= 14{
			inst = instance_create_depth(
            start_x + n * x_spacing, 
            y_pos, 
            -5, 
            obj_card_slot
        );
		}
		else{
			inst = instance_create_depth(
            start_x + 14 * x_spacing, 
            y_pos+(n-14)*y_spacing, 
            -5, 
            obj_card_slot
        )
		}
        
        inst.cost = card_data[? "cost"];
        // raw_cooldown = 卡面原始冷却（连词条都没乘过）。卡槽 Step 每帧用
        // hex_card_cooldown(raw, id) × 二期倍率 重算，这样任何「冷却 -X%」类词条
        // 都是抽到即生效，不必等下一关重建卡槽
        inst.raw_cooldown  = card_data[? "cooldown"];
        inst.base_cooldown = hex_card_cooldown(card_data[? "cooldown"], _card_id);
        inst.cooldown = max(1, round(inst.base_cooldown * hex_b3_slot_cd_mult()));
        inst.card_obj = card_data[? "obj"]; 
        inst.card_spr = card_data[? "sprite"];
		inst.place_preview = card_data[? "place_preview"]
        inst.description = card_data[? "description"];
        inst.slot_index = n + 1;
		inst.card_id = _card_id;
        inst.shape = _slot_shape; // 存储形态信息（取存档里的当前形态，不是卡组缓存）
		inst.cshape = _slot_shape;
		inst.depth = -2000
		//show_debug_message("植物卡槽已生成，id：" + inst.card_id)
        n++
    }
}
