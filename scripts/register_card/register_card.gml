/// @function register_card(card_id, obj, shapes_array)
/// @desc 注册新卡牌到卡池
function register_card(card_id, _obj, _shapes_array) {
    var card = ds_map_create();
    card[? "obj"] = _obj; // 存储基础对象
    card[? "shapes"] = ds_list_create(); // 创建形态列表
    
    // 遍历形态数组，将每个形态数据存储到列表中
    for(var i = 0; i < array_length(_shapes_array); i++) {
        var shape_data = ds_map_create();
        var shape_info = _shapes_array[i];
        
        shape_data[? "shape"] = shape_info.shape;
        shape_data[? "sprite"] = shape_info.sprite;
        shape_data[? "cost"] = shape_info.cost;
        shape_data[? "cooldown"] = shape_info.cooldown;
        shape_data[? "description"] = shape_info.description;
		shape_data[? "obj"] = _obj;
		shape_data[? "plant_type"] = shape_info.plant_type;
		shape_data[? "feature_type"] = shape_info.feature_type;
		shape_data[? "target_card"] = shape_info.target_card;
		if struct_exists(shape_info,"place_preview"){
			shape_data[? "place_preview"] = shape_info.place_preview
		}
        
        ds_list_add(card[? "shapes"], shape_data);
    }
    
    ds_list_add(global.player_deck, card_id, card);
}