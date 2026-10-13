image_speed = 0;
image_xscale = 10;
image_yscale = 10;
is_closing = false;
selected_item = -1;
current_page = 1;
shop_type = 1;
exchange_cards = [];
silver_cards = [];
// 显示名单直接读取跨服注册分类，避免新增商品遗漏。
var _goods_ids = [];
ds_map_keys_to_array(global.goods_map, _goods_ids);
for (var _i = 0; _i < array_length(_goods_ids); _i++) {
    var _id = _goods_ids[_i];
    var _goods = global.goods_map[? _id];
    if (!variable_struct_exists(_goods, "cross_server_shop")) continue;
    if (_goods.cross_server_shop == "gold") array_push(exchange_cards, _id);
    else if (_goods.cross_server_shop == "silver") array_push(silver_cards, _id);
}

// 同一卡片的本体和转职卡连续显示，并按本体、一转、二转排列。
// 每个商店页签分别排序，保留商品分组首次出现时的整体顺序。
var _shop_lists = [exchange_cards, silver_cards];
for (var _list_index = 0; _list_index < array_length(_shop_lists); _list_index++) {
    var _list = _shop_lists[_list_index];
    var _group_order = ds_map_create();
    var _next_group_order = 0;

    for (var _i = 0; _i < array_length(_list); _i++) {
        var _goods = global.goods_map[? _list[_i]];
        var _group_id = variable_struct_exists(_goods, "card_id") ? _goods.card_id : _list[_i];
        if (!ds_map_exists(_group_order, _group_id)) {
            ds_map_add(_group_order, _group_id, _next_group_order);
            _next_group_order++;
        }
    }

    // 稳定插入排序：先比较卡片分组，再比较转职形态。
    for (var _i = 1; _i < array_length(_list); _i++) {
        var _item = _list[_i];
        var _item_goods = global.goods_map[? _item];
        var _item_group = variable_struct_exists(_item_goods, "card_id") ? _item_goods.card_id : _item;
        var _item_shape = variable_struct_exists(_item_goods, "card_shape") ? _item_goods.card_shape : 0;
        var _insert_at = _i;

        while (_insert_at > 0) {
            var _previous = _list[_insert_at - 1];
            var _previous_goods = global.goods_map[? _previous];
            var _previous_group = variable_struct_exists(_previous_goods, "card_id") ? _previous_goods.card_id : _previous;
            var _previous_shape = variable_struct_exists(_previous_goods, "card_shape") ? _previous_goods.card_shape : 0;
            var _move_previous = ds_map_find_value(_group_order, _previous_group) > ds_map_find_value(_group_order, _item_group)
                || (ds_map_find_value(_group_order, _previous_group) == ds_map_find_value(_group_order, _item_group)
                    && _previous_shape > _item_shape);
            if (!_move_previous) break;
            _list[_insert_at] = _previous;
            _insert_at--;
        }
        _list[_insert_at] = _item;
    }
    ds_map_destroy(_group_order);

    if (_list_index == 0) exchange_cards = _list;
    else silver_cards = _list;
}

// 动态计算总页数（每页16个商品）
var _cards = shop_type == 0 ? exchange_cards : silver_cards;
total_pages = max(1, ceil(array_length(_cards) / 16));
