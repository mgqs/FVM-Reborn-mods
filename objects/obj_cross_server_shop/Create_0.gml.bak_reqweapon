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

// 🔴 2026-10-30：下列 13 张卡的 一/二转凭证已挪进**威望商店**（credit_shop_init），
//   所以从跨服黄金页剔除。只动这里的显示名单，**不改商品的 cross_server_shop 字段**——
//   那个字段同时用于「金币商店是否隐藏该商品」，改掉会让这些卡以 30000 金币在本体商店冒出来。
var _moved_to_prestige = [
    "zhanqima_1", "zhanqima_2", "yanyantu_1", "yanyantu_2", "wugushe_1", "wugushe_2",
    "kuileima_1", "kuileima_2", "yufengma_1", "yufengma_2", "fenjima_1", "fenjima_2",
    "guiyuanma_1", "guiyuanma_2", "yanhuangma_1", "yanhuangma_2", "yinhema_1", "yinhema_2",
    "xiandima_1", "xiandima_2", "xingqiongma_1", "xingqiongma_2",
    "starrabbit_1", "starrabbit_2", "yinghuoshe_1", "yinghuoshe_2"
];
for (var _mi = array_length(exchange_cards) - 1; _mi >= 0; _mi--) {
    if (array_get_index(_moved_to_prestige, exchange_cards[_mi]) != -1) array_delete(exchange_cards, _mi, 1);
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

// ── 购买确认窗（2026-10-28 用户要求）────────────────────────────────────────
//   点商品先弹「是否消耗 N 金/银勋章兑换 XX？」→ 确定才扣钱。
//   一转/二转凭证就是普通商品，一次买 1 张，**不需要自定义数量窗**
//   （数量窗只属于威望商店里那种可批量囤的凭证，跨服这里按原版手感走确认框）
confirm_id         = "";      // 非空 = 确认窗开着（存商品 key）
confirm_name       = "";
confirm_cost       = 0;
confirm_medal      = "";
confirm_medal_name = "";

/// @func cross_shop_confirm_rect(i) 确认窗按钮矩形（0 = 确定 / 1 = 取消）
function cross_shop_confirm_rect(_i){
    var _bx = x + ((_i == 0) ? -95 : 95);
    return [_bx - 62, y + 58, _bx + 62, y + 112];
}

/// @func cross_shop_confirm_open(id) 打开确认窗（只记录，不扣钱）
function cross_shop_confirm_open(_id){
    var _g = global.goods_map[? _id];
    if (!is_struct(_g)) return;
    confirm_id = _id;
    // 一转/二转凭证与商店、背包同一套叫法「卡名（X转凭证）」
    if (variable_struct_exists(_g, "card_id") && variable_struct_exists(_g, "card_shape") && _g.card_shape > 0)
        confirm_name = transfer_credit_name(_g.card_id, _g.card_shape);
    else
        confirm_name = variable_struct_exists(_g, "display_name") ? _g.display_name : _id;
    confirm_cost       = real(_g.cost);
    confirm_medal      = (shop_type == 0) ? "cross_server_gold_medal" : "cross_server_silver_medal";
    confirm_medal_name = (shop_type == 0) ? "金色勋章" : "白银勋章";
    audio_play_sound(snd_button, 0, 0);
}

/// @func cross_shop_buy_do() 确定：再查一次余额 → 扣勋章 → 发货
function cross_shop_buy_do(){
    var _id = confirm_id;
    confirm_id = "";
    if (_id == "" || !ds_map_exists(global.goods_map, _id)) return;
    var _g = global.goods_map[? _id];
    if (get_material_amount(confirm_medal) < confirm_cost && !global.debug){
        show_notice(confirm_medal_name + "不足", 60);
        return;
    }
    add_material_amount(confirm_medal, -confirm_cost);

    var _type    = _g.type;
    var _card_id = variable_struct_exists(_g, "card_id") ? _g.card_id : _id;
    var _shape   = variable_struct_exists(_g, "card_shape") ? _g.card_shape : 0;
    if (_type == "card"){
        if (_shape > 0){
            // 一 / 二转：发转职凭证（不去动形态，转职去合成屋）
            add_material_amount(transfer_credit_id(_card_id, _shape), 1);
        } else {
            unlock_card(_card_id, 0, _shape, global.save_data.unlocked_items.max_skill_level);
        }
    } else if (_type == "weapon"){
        unlock_weapon(_id);
    } else if (_type == "gem"){
        unlock_gem(_id);
    }
    save_file(global.save_slot);
    audio_play_sound(snd_button, 0, 0);
}
