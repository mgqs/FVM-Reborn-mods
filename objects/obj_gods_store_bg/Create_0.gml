image_xscale = 1.8;
image_yscale = 1.8;
is_submenu_opened = false;
current_page = 1;
current_max_page = 10;
shop_button_select = 1;
gods_goods_list = ds_list_create();
instance_create_depth(x + 799, y - 480, depth - 1, obj_gods_store_closer);
var btn1 = instance_create_depth(x - 743, y - 363, depth - 1, obj_gods_store_select_btn);
btn1.button_index = 1;
btn1.sprite_index = spr_gods_store_select_btn_1;
var btn2 = instance_create_depth(x - 560, y - 363, depth - 1, obj_gods_store_select_btn);
btn2.button_index = 2;
btn2.sprite_index = spr_gods_store_select_btn_2;
var prev_btn = instance_create_depth(856, 912, depth - 1, obj_gods_store_page_btn);
prev_btn.btn_type = "prev";
var next_btn = instance_create_depth(1056, 912, depth - 1, obj_gods_store_page_btn);
next_btn.btn_type = "next";
gods_shop_list_recharge();

function gods_shop_list_recharge()
{
    ds_list_clear(gods_goods_list);
    var map_array = [];
    ds_map_keys_to_array(global.gods_goods_map, map_array);
    array_sort(map_array, true);
    var goods_array_size = array_length(map_array);

    // 先按页签收集商品（原始顺序 = 商品 id 字母序，稳定，拿来做同档内的次序）
    var _picked = [];
    for (var _i1 = 0; _i1 < goods_array_size; _i1++)
    {
        var _gid1 = map_array[_i1];
        var _g1 = ds_map_find_value(global.gods_goods_map, _gid1);
        // 融合卡卖的是「食谱道具」(type recipe)：本体食谱进本体页，深度/灵魂食谱进转职页
        var _is_recipe1 = (_g1.type == "recipe");
        if (shop_button_select == 1)
        {
            if (_g1.type == "card" || (_is_recipe1 && _g1.target_shape == 0)) array_push(_picked, _gid1);
        }
        else if (shop_button_select == 2)
        {
            if (_g1.type == "shape" || (_is_recipe1 && _g1.target_shape >= 1)) array_push(_picked, _gid1);
        }
    }

    // 排序（2026-10-23 沿用跨服商店口径）：融合卡(0) → 金卡(1) → 普卡(2)，
    // 档内按「卡片首次出现的顺序」排，同一张卡的 1/2/3 转相邻。
    // ⚠️ 这里不能调 gacha_is_gold_card()：它把「诸神商店里的卡」一律算金卡，
    //    那样除融合卡外全落进同一档，等于没排；改成直接读形态 0 的 is_gold 标记。
    if (array_length(_picked) > 1)
    {
        var _keys = ds_map_create();
        var _group_order = ds_map_create();
        var _next_group = 0;
        for (var _i2 = 0; _i2 < array_length(_picked); _i2++)
        {
            var _gid2 = _picked[_i2];
            var _goods2 = ds_map_find_value(global.gods_goods_map, _gid2);
            var _card_id2 = variable_struct_exists(_goods2, "unlock_item_id") ? _goods2.unlock_item_id : _gid2;

            var _tier = 2;
            if (is_fusion_card(_card_id2)) _tier = 0;
            else
            {
                var _shape_data = deck_get_card_data(_card_id2, 0);
                if (_shape_data != noone && ds_exists(_shape_data, ds_type_map)
                    && ds_map_find_value(_shape_data, "is_gold") == 1) _tier = 1;
            }

            if (!ds_map_exists(_group_order, _card_id2))
            {
                ds_map_add(_group_order, _card_id2, _next_group);
                _next_group++;
            }

            var _shape2 = variable_struct_exists(_goods2, "target_shape") ? _goods2.target_shape : 0;
            ds_map_add(_keys, _gid2, [_tier, ds_map_find_value(_group_order, _card_id2), _shape2]);
        }

        // 稳定插入排序：档位 → 卡片组序 → 形态
        for (var _i3 = 1; _i3 < array_length(_picked); _i3++)
        {
            var _item = _picked[_i3];
            var _item_key = _keys[? _item];
            var _insert_at = _i3;
            while (_insert_at > 0)
            {
                var _previous = _picked[_insert_at - 1];
                var _previous_key = _keys[? _previous];
                var _move_previous = false;
                if (_previous_key[0] != _item_key[0]) _move_previous = _previous_key[0] > _item_key[0];
                else if (_previous_key[1] != _item_key[1]) _move_previous = _previous_key[1] > _item_key[1];
                else _move_previous = _previous_key[2] > _item_key[2];
                if (!_move_previous) break;
                _picked[_insert_at] = _previous;
                _insert_at--;
            }
            _picked[_insert_at] = _item;
        }
        ds_map_destroy(_keys);
        ds_map_destroy(_group_order);
    }

    for (var _i4 = 0; _i4 < array_length(_picked); _i4++) ds_list_add(gods_goods_list, _picked[_i4]);
    
    instance_destroy(obj_gods_store_buy_btn);
    
    for (var i = 0; i < 4; i++)
    {
        for (var j = 0; j < 4; j++)
        {
            if (shop_button_select == 1)
            {
                var _gid_b1 = ds_list_find_value(gods_goods_list, (i * 4) + j + ((current_page - 1) * 16));
                if (_gid_b1 != undefined)
                {
                    var _goods_b1 = ds_map_find_value(global.gods_goods_map, _gid_b1);
                    // 融合卡的本体格卖的是「本体食谱」道具（type 仍是 card，见 gods_shop_init 注释）
                    var _is_recipe_b1 = variable_struct_exists(_goods_b1, "recipe_id");

                    var inst = instance_create_depth((x - 615) + (411 * j) + 77, (y - 251) + (165 * i) + 60, depth - 1, obj_gods_store_buy_btn);
                    inst.target_item = _goods_b1.unlock_item_id;
                    inst.cost = _goods_b1.cost;
                    inst.goods_name = (_is_recipe_b1 && variable_struct_exists(_goods_b1, "recipe_name")) ? _goods_b1.recipe_name : _goods_b1.display_name;
                    inst.tooltip_text = _goods_b1.description;
                    inst.recipe_id = _is_recipe_b1 ? _goods_b1.recipe_id : "";
                    inst.btn_type = _is_recipe_b1 ? "recipe" : "card";

                    if (_is_recipe_b1)
                    {
                        // 只看背包里还有没有这本食谱：用掉了就能再买（哪怕卡已经练上去了）
                        if (has_fusion_recipe(_goods_b1.unlock_item_id, 0)) inst.is_disabled = true;
                    }
                    else
                    {
                        var is_unlocked = false;

                        for (var k = 0; k < array_length(global.save_data.unlocked_cards); k++)
                        {
                            if (global.save_data.unlocked_cards[k].id == _goods_b1.unlock_item_id)
                            {
                                is_unlocked = true;
                                break;
                            }
                        }

                        if (is_unlocked)
                            inst.is_disabled = true;
                        else if (!fusion_prereq_met(inst.target_item, 2))
                        {
                            // 诸神商店口径：前置卡要练到二转（与抽卡共用同一份前置表，只是门槛不同）
                            // 例外①：命运女神只要创造神本体（prereq_body_only），提示里就不带「二转」
                            // 例外②：前置全是「没有二转」的卡（幻幻鸡 / 蓝莓塔）时不写「二转」
                            var _need_txt = (prereq_body_only(inst.target_item) || !fusion_prereq_any_upgradable(inst.target_item)) ? "" : "二转";
                            inst.meet_requirements = false;
                            inst.requirement_notice = "需先拥有[" + fusion_prereq_name(inst.target_item) + "]" + _need_txt + "才能兑换！";
                        }
                    }
                }
            }
            else if (shop_button_select == 2)
            {
                var _gid_b2 = ds_list_find_value(gods_goods_list, (i * 4) + j + ((current_page - 1) * 16));
                if (_gid_b2 != undefined)
                {
                    var goods_info = ds_map_find_value(global.gods_goods_map, _gid_b2);
                    // 融合卡的深度融合 / 灵魂融合卖的是「食谱道具」（type recipe）
                    var _is_recipe_b2 = variable_struct_exists(goods_info, "recipe_id");

                    var inst = instance_create_depth((x - 615) + (411 * j) + 77, (y - 251) + (165 * i) + 60, depth - 1, obj_gods_store_buy_btn);
                    inst.target_item = goods_info.unlock_item_id;
                    inst.target_shape = goods_info.target_shape;
                    inst.cost = goods_info.cost;
                    inst.goods_name = goods_info.display_name;
                    inst.tooltip_text = goods_info.description;
                    inst.recipe_id = _is_recipe_b2 ? goods_info.recipe_id : "";
                    inst.btn_type = _is_recipe_b2 ? "recipe" : "shape";

                    if (_is_recipe_b2)
                    {
                        // 同上：只看背包里还有没有这本食谱（灵融之后还能回头再买初融 / 深融食谱）
                        if (has_fusion_recipe(goods_info.unlock_item_id, goods_info.target_shape)) inst.is_disabled = true;
                    }
                    else
                    {
                        var card_unlocked = false;
                        var shape_unlocked = false;
                        var shape_too_small = false;

                        for (var k = 0; k < array_length(global.save_data.unlocked_cards); k++)
                        {
                            if (global.save_data.unlocked_cards[k].id == goods_info.unlock_item_id)
                            {
                                card_unlocked = true;
                                var current_card_shape = get_card_info_simple(goods_info.unlock_item_id).max_shape;

                                if (current_card_shape >= goods_info.target_shape)
                                    shape_unlocked = true;
                                else if (current_card_shape < (goods_info.target_shape - 1))
                                    shape_too_small = true;

                                break;
                            }
                        }

                        if (shape_unlocked)
                            inst.is_disabled = true;
                        else if (!card_unlocked || shape_too_small)
                            inst.meet_requirements = false;
                    }
                }
            }
        }
    }
}
