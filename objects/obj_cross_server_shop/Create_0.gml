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

// 分区排序（2026-10-22 定）：
//   白银：卡片优先（融合卡 → 金卡 → 普卡），宝石武器一律排最后；
//   黄金：1 转优先 → 2 转 → 宝石武器。
// 同一档位内仍按「卡片分组首次出现的顺序」+ 本体/一转/二转排列。
var _shop_lists = [exchange_cards, silver_cards];
for (var _list_index = 0; _list_index < array_length(_shop_lists); _list_index++) {
    var _list = _shop_lists[_list_index];
    var _is_silver = (_list_index == 1);
    var _group_order = ds_map_create();
    var _next_group_order = 0;
    var _keys = ds_map_create();          // 商品 id -> [分区, 卡片子档, 组序, 形态]

    for (var _i = 0; _i < array_length(_list); _i++) {
        var _id = _list[_i];
        var _goods = global.goods_map[? _id];
        var _group_id = variable_struct_exists(_goods, "card_id") ? _goods.card_id : _id;
        if (!ds_map_exists(_group_order, _group_id)) {
            ds_map_add(_group_order, _group_id, _next_group_order);
            _next_group_order++;
        }
        var _shape = variable_struct_exists(_goods, "card_shape") ? _goods.card_shape : 0;
        var _is_card = variable_struct_exists(_goods, "type") && _goods.type == "card";
        var _rank = 2;                    // 2 = 宝石武器，两个页签都排最后
        var _sub = 0;
        if (_is_card) {
            if (_is_silver) {
                _rank = 0;
                _sub = is_fusion_card(_group_id) ? 0 : (gacha_is_gold_card(_group_id) ? 1 : 2);
            }
            else {
                _rank = (_shape >= 2) ? 1 : 0;    // 0 = 1 转，1 = 2 转
            }
        }
        ds_map_add(_keys, _id, [_rank, _sub, ds_map_find_value(_group_order, _group_id), _shape]);
    }

    // 稳定插入排序：分区 → 卡片子档 → 分组 → 形态
    for (var _i = 1; _i < array_length(_list); _i++) {
        var _item = _list[_i];
        var _item_key = _keys[? _item];
        var _insert_at = _i;

        while (_insert_at > 0) {
            var _previous = _list[_insert_at - 1];
            var _previous_key = _keys[? _previous];
            var _move_previous = false;
            if (_previous_key[0] != _item_key[0]) _move_previous = _previous_key[0] > _item_key[0];
            else if (_previous_key[1] != _item_key[1]) _move_previous = _previous_key[1] > _item_key[1];
            else if (_previous_key[2] != _item_key[2]) _move_previous = _previous_key[2] > _item_key[2];
            else _move_previous = _previous_key[3] > _item_key[3];
            if (!_move_previous) break;
            _list[_insert_at] = _previous;
            _insert_at--;
        }
        _list[_insert_at] = _item;
    }
    ds_map_destroy(_keys);
    ds_map_destroy(_group_order);

    if (_list_index == 0) exchange_cards = _list;
    else silver_cards = _list;
}

// 动态计算总页数（每页16个商品）
var _cards = shop_type == 0 ? exchange_cards : silver_cards;
total_pages = max(1, ceil(array_length(_cards) / 16));
