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
// 第 3 页签「配方材料」：融合菜谱（深度融合 / 灵魂融合）从转职凭证页单独拆出来卖
//   贴图 = 桌面 shapes/328.png（未选中） / 330.png（选中），spr_gods_store_select_btn_3 三帧：0 常态 / 1 选中 / 2 悬停
var btn3 = instance_create_depth(x - 377, y - 363, depth - 1, obj_gods_store_select_btn);
btn3.button_index = 3;
btn3.sprite_index = spr_gods_store_select_btn_3;
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
        // 融合卡卖的是「食谱道具」：初融 = type "card" + sell_recipe（卖本体食谱），深/灵 = type "recipe"
        var _is_recipe1 = (_g1.type == "recipe");
        var _is_base_recipe1 = (variable_struct_exists(_g1, "sell_recipe") && _g1.sell_recipe);
        if (shop_button_select == 1)
        {
            // 防御卡：只放卡本体 + 进化凭证（**所有融合菜谱，含初融，都已挪到第 3 页「配方材料」**）
            if ((_g1.type == "card" && !_is_base_recipe1) || _g1.type == "evo") array_push(_picked, _gid1);
        }
        else if (shop_button_select == 2)
        {
            // 转职凭证：三/四/终转凭证（tvoucher）与 shape 商品，食谱不再混在这一页
            if (_g1.type == "tvoucher" || _g1.type == "shape") array_push(_picked, _gid1);
        }
        else if (shop_button_select == 3)
        {
            // 配方材料：初融（本体食谱）+ 深度融合 + 灵魂融合，一条不落
            if (_is_recipe1 || _is_base_recipe1) array_push(_picked, _gid1);
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
            // 第 3 页里「初融菜谱」是 type "card" + sell_recipe，按钮/售罄/工具提示都走第 1 页那套逻辑
            var _use_card_layout = (shop_button_select == 1);
            if (shop_button_select == 3)
            {
                var _gid_t = ds_list_find_value(gods_goods_list, (i * 4) + j + ((current_page - 1) * 16));
                if (_gid_t != undefined)
                {
                    var _gd_t = ds_map_find_value(global.gods_goods_map, _gid_t);
                    if (variable_struct_exists(_gd_t, "sell_recipe") && _gd_t.sell_recipe) _use_card_layout = true;
                }
            }
            if (_use_card_layout)
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
                    // 名字统一走 gods_goods_name()：evo = 卡名（进化凭证）/ tvoucher = 卡名（X转凭证）
                    //   绝对不要再直接读 _goods_b1.display_name —— 那字段 2026-10-27 已从 evo/tvoucher 里删掉
                    inst.goods_name = gods_goods_name(_goods_b1);
                    // 进化凭证（第 1 页的 evo）：悬停提示写「卡名（进化凭证）/ 进化路线 / 描述 / 用途」
                    //   与背包凭证页同一套字（mod_evo_tooltip），2026-10-28 用户要求
                    if (_goods_b1.type == "evo") {
                        inst.tooltip_text = mod_evo_tooltip(_goods_b1.unlock_item_id, _goods_b1.description);
                    } else {
                        inst.tooltip_text = _goods_b1.description;
                    }
                    inst.recipe_id = _is_recipe_b1 ? _goods_b1.recipe_id : "";
                    // 食谱档位：0 = 初融 / 1 = 深度融合 / 2 = 灵魂融合；非食谱 = -1
                    //   抽卡模式只禁**初融**，深/灵菜谱可买（2026-10-28 用户口径），Draw / Mouse 都读它
                    //   ⚠️ 不能写成三元：第 1 页的融合卡本体是 type "card" + recipe_id + sell_recipe，
                    //      **没有 target_shape 字段**（初融就是 0），直接 `.target_shape` 会崩（2026-10-28 实测）
                    inst.recipe_shape = -1;
                    if (_is_recipe_b1) {
                        inst.recipe_shape = 0;
                        if (variable_struct_exists(_goods_b1, "target_shape")) inst.recipe_shape = _goods_b1.target_shape;
                    }
                    // 2026-10-27：第一页的「金卡」已换成进化凭证（type "evo"），买的是道具不是卡
                    var _is_evo_b1 = (_goods_b1.type == "evo");
                    inst.btn_type = _is_recipe_b1 ? "recipe" : (_is_evo_b1 ? "evo" : "card");

                    if (_is_recipe_b1)
                    {
                        // 🔴 2026-10-30 用户口径：**已经拥有对应形态就不能买**
                        //   初融菜谱对应形态 0 → 只要这张融合卡已经拥有（max_shape >= 0）就售罄；
                        //   背包里还留着一本同样的食谱也算售罄（旧口径保留，避免重复囤）
                        var _own0 = transfer_credit_card_max_shape(_goods_b1.unlock_item_id);
                        if (has_fusion_recipe(_goods_b1.unlock_item_id, 0) || _own0 >= 0) inst.is_disabled = true;
                    }
                    else if (_is_evo_b1)
                    {
                        // 进化凭证：**只能有 1 张** —— 背包里已有一张，或这张金卡已经进化出来了 → 售完
                        //   判定统一走 mod_evo_buyable_locked（Draw 的售罄罩调的是同一个，别再各写一份）
                        inst.is_disabled = mod_evo_buyable_locked(_goods_b1.unlock_item_id);
                    }
                    else
                    {
                        // 金卡本体（当前没有 type:"card" 商品 —— 金卡全改成 evo 凭证了；
                        // 这段留着给以后真要直接上架卡本体的商品）
                        var is_unlocked = false;

                        for (var k = 0; k < array_length(global.save_data.unlocked_cards); k++)
                        {
                            if (global.save_data.unlocked_cards[k].id == _goods_b1.unlock_item_id)
                            {
                                is_unlocked = true;
                                break;
                            }
                        }

                        // 2026-10-27 用户口径：前置体系只属于「金卡进化 / 食灵融合」，
                        //   诸神商店不再校验任何前置 —— 卡类商品只保留「已拥有就不再卖」
                        if (is_unlocked)
                            inst.is_disabled = true;
                    }
                }
            }
            else if ((shop_button_select == 2 || shop_button_select == 3))
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
                    // 名字统一走 gods_goods_name()（不读 display_name，tvoucher 那类已经没这个字段了）
                    inst.goods_name = gods_goods_name(goods_info);
                    inst.tooltip_text = goods_info.description;
                    inst.recipe_id = _is_recipe_b2 ? goods_info.recipe_id : "";
                    inst.recipe_shape = -1;                       // 同上：第 2 页也可能缺字段
                    if (_is_recipe_b2) {
                        inst.recipe_shape = 1;
                        if (variable_struct_exists(goods_info, "target_shape")) inst.recipe_shape = goods_info.target_shape;
                    }
                    // 三/四/终转凭证现在是「买道具」（type "tvoucher"），不再直接升形态
                    var _is_tv_b2 = (goods_info.type == "tvoucher");
                    inst.btn_type = _is_recipe_b2 ? "recipe" : (_is_tv_b2 ? "tvoucher" : "shape");

                    if (_is_recipe_b2)
                    {
                        // 🔴 2026-10-30 用户口径：**已经拥有对应形态就不能买**
                        //   深度菜谱 target_shape 1 / 灵魂菜谱 2 → 卡的 max_shape >= 该档就售罄；
                        //   背包里还留着一本同样的食谱也算售罄（旧口径保留）
                        // ⚠️ 初融菜谱没有 target_shape 字段，缺字段按 0 处理，别直接点出来会崩
                        var _rshape_b2 = variable_struct_exists(goods_info, "target_shape") ? goods_info.target_shape : 0;
                        var _own_b2 = transfer_credit_card_max_shape(goods_info.unlock_item_id);
                        if (has_fusion_recipe(goods_info.unlock_item_id, _rshape_b2) || _own_b2 >= _rshape_b2)
                            inst.is_disabled = true;
                    }
                    else if (_is_tv_b2)
                    {
                        // 2026-10-27 用户口径：凭证购买**任意** —— 不再要求「先拥有这张卡」，
                        //   且**不限量**（背包里已有一张同款凭证也能再买）；
                        //   唯一拦截 = 这一档已经转上去了（再买没意义）
                        var _tv_info = get_card_info_simple(goods_info.unlock_item_id);
                        if (is_struct(_tv_info) && _tv_info.max_shape >= goods_info.target_shape)
                            inst.is_disabled = true;
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
