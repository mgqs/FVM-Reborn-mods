draw_set_alpha(1);
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
draw_self();
var inv = global.save_data.inventory;
var amt = 0;

for (var i = 0; i < array_length(inv); i++)
{
    if (inv[i].id == "oracle_stone")
    {
        amt = inv[i].amount;
        break;
    }
}

draw_set_font(font_yuan);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(1681, 123, string(amt));
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(956, 912, string(current_page) + "/" + string(current_max_page));
draw_sprite_ext(spr_shop_bg_2, 0, x, y, 1.8, 1.8, 0, c_white, 1);

for (var i = 0; i < 4; i++)
{
    for (var j = 0; j < 4; j++)
        draw_sprite_ext(spr_gods_shop_goods_bg, 0, (x - 618) + (411 * i), (y - 248) + (165 * j), 1.8, 1.8, 0, c_white, 1);
}

for (var i = 0; i < 4; i++)
{
    for (var j = 0; j < 4; j++)
    {
        if (shop_button_select == 1)
        {
            if (ds_list_find_value(gods_goods_list, (i * 4) + j + ((current_page - 1) * 16)) != undefined)
            {
                var _gid_d1 = ds_list_find_value(gods_goods_list, (i * 4) + j + ((current_page - 1) * 16));
                var _goods_d1 = ds_map_find_value(global.gods_goods_map, _gid_d1);
                if (variable_struct_exists(_goods_d1, "recipe_id"))
                {
                    // 融合卡本体格卖的是「本体食谱」道具：只画食谱图标（不垫卡底）。
                    // 格子里的「阳光消耗」是卡才有的，食谱没有 → 不画；神谕石价格在下面的购买按钮上
                    var _rs1 = _goods_d1.spr;
                    var _rsub1 = variable_struct_exists(_goods_d1, "spr_sub") ? _goods_d1.spr_sub : 0;
                    // 图标大小对齐左边的卡片格（卡底 89x118）→ 取最长边 90
                    var _rsc1 = 90 / max(sprite_get_width(_rs1), sprite_get_height(_rs1));
                    var _rx1 = ((x - 618) + (411 * j)) - 122;
                    var _ry1 = (y - 248) + (165 * i);
                    draw_sprite_ext(_rs1, _rsub1,
                        _rx1 + (sprite_get_xoffset(_rs1) - sprite_get_width(_rs1) * 0.5) * _rsc1,
                        _ry1 + (sprite_get_yoffset(_rs1) - sprite_get_height(_rs1) * 0.5) * _rsc1,
                        _rsc1, _rsc1, 0, c_white, 1);
                    if (has_fusion_recipe(_goods_d1.unlock_item_id, 0))
                    {
                        draw_set_color(c_black);
                        draw_set_alpha(0.5);
                        draw_rectangle(((x - 618) + (411 * j)) - 205, ((y - 248) + (165 * i)) - 82, (x - 618) + (411 * j) + 205, (y - 248) + (165 * i) + 82, false);
                        draw_set_alpha(1);
                        draw_sprite_ext(spr_sold_out, 0, (x - 618) + (411 * j), (y - 248) + (165 * i), 1.8, 1.8, 0, c_white, 1);
                        draw_set_color(c_white);
                    }
                    continue;
                }
                // 2026-10-27：进化凭证（type "evo"）不画卡图 —— 改画「金色底板 + 该金卡立绘」，
                //   跟背包 / 金卡进化页 / 抽卡弹窗同一套 mod_evo_draw_credit；凭证没有阳光消耗，卡底和造价都不画
                if (_goods_d1.type == "evo")
                {
                    var _ecx = ((x - 618) + (411 * j)) - 122;
                    var _ecy = (y - 248) + (165 * i);
                    mod_evo_draw_credit(_goods_d1.unlock_item_id, _ecx, _ecy, true, 96, 70);
                    // 售罄口径与 Create_0 的 is_disabled 走同一个判定：已有凭证 / 已拥有这张金卡
                    if (mod_evo_buyable_locked(_goods_d1.unlock_item_id))
                    {
                        draw_set_color(c_black);
                        draw_set_alpha(0.5);
                        draw_rectangle(((x - 618) + (411 * j)) - 205, ((y - 248) + (165 * i)) - 82, (x - 618) + (411 * j) + 205, (y - 248) + (165 * i) + 82, false);
                        draw_set_alpha(1);
                        draw_sprite_ext(spr_sold_out, 0, (x - 618) + (411 * j), (y - 248) + (165 * i), 1.8, 1.8, 0, c_white, 1);
                        draw_set_color(c_white);
                    }
                    continue;
                }
                var card_data = deck_get_card_data(ds_map_find_value(global.gods_goods_map, ds_list_find_value(gods_goods_list, (i * 4) + j + ((current_page - 1) * 16))).unlock_item_id, 0);
            if (card_data != noone && ds_exists(card_data, ds_type_map))
            {
            var _god_card_id = ds_map_find_value(global.gods_goods_map, ds_list_find_value(gods_goods_list, (i * 4) + j + ((current_page - 1) * 16))).unlock_item_id;
            var slot_sprite = is_fusion_card(_god_card_id) ? spr_slot_2 : ((ds_map_find_value(card_data, "is_gold") == 1) ? spr_slot_1 : spr_slot);
                draw_sprite_ext(slot_sprite, 0, ((x - 618) + (411 * j)) - 122, (y - 248) + (165 * i), 0.33, 0.33, 0, c_white, 1);
                draw_sprite_ext(ds_map_find_value(card_data, "sprite"), 0, ((x - 618) + (411 * j)) - 122, (y - 248) + (165 * i) + 25, 1, 1, 0, c_white, 1);
                draw_set_halign(fa_left);
                draw_set_valign(fa_middle);
                draw_set_color(c_black);
                draw_set_font(font_yuan);
                draw_text_ext_transformed(((x - 618) + (411 * j)) - 122 - 12, (y - 248) + (165 * i) + 40, string(ds_map_find_value(card_data, "cost")), 25, 1800, 1, 1, 0);
                draw_sprite_ext(spr_flame, 0, ((x - 618) + (411 * j)) - 122 - 24, (y - 248) + (165 * i) + 43, 0.3, 0.3, 0, c_white, 1);
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
                var is_unlocked = false;
                
                for (var k = 0; k < array_length(global.save_data.unlocked_cards); k++)
                {
                    if (global.save_data.unlocked_cards[k].id == ds_map_find_value(global.gods_goods_map, ds_list_find_value(gods_goods_list, (i * 4) + j + ((current_page - 1) * 16))).unlock_item_id)
                    {
                        is_unlocked = true;
                        break;
                    }
                }
                
                if (is_unlocked)
                {
                    draw_set_color(c_black);
                    draw_set_alpha(0.5);
                    draw_rectangle(((x - 618) + (411 * j)) - 205, ((y - 248) + (165 * i)) - 82, (x - 618) + (411 * j) + 205, (y - 248) + (165 * i) + 82, false);
                    draw_set_alpha(1);
                    draw_sprite_ext(spr_sold_out, 0, (x - 618) + (411 * j), (y - 248) + (165 * i), 1.8, 1.8, 0, c_white, 1);
                }
            }
            }
        }
        else if ((shop_button_select == 2 || shop_button_select == 3))
        {
            if (ds_list_find_value(gods_goods_list, (i * 4) + j + ((current_page - 1) * 16)) != undefined)
            {
                var goods_info = ds_map_find_value(global.gods_goods_map, ds_list_find_value(gods_goods_list, (i * 4) + j + ((current_page - 1) * 16)));
                var goods_spr = goods_info.spr;
                var target_card_id = goods_info.unlock_item_id;
                var _gsub = variable_struct_exists(goods_info, "spr_sub") ? goods_info.spr_sub : 0;
                var _gsc = 1.5;
                if (goods_info.type == "tvoucher")
                {
                    // 2026-10-27（用户要求）：转职凭证**不再用成品图**（spr_voucher_*），一律走通用绘制
                    //   transfer_credit_draw = 底板（按档位）+ 该卡立绘现拼，跟转职页 / 背包同一套口径；
                    //   哪个卡的卡面画歪了、顶框了、太小了，进商店一眼就能看出来
                    //   105 = 原来 70×70 成品图 × 1.5 的等大尺寸；x,y 传**左上角**（跟转职页一致）
                    var _tcx = ((x - 618) + (411 * j)) - 122;
                    var _tcy = ((y - 273) + (165 * i) + 25);
                    transfer_credit_draw(_tcx - 52.5, _tcy - 52.5, goods_info.unlock_item_id, goods_info.target_shape, 105, 0, 1);
                }
                else
                {
                    // 原点不一样（食谱图是 0,0，凭证是中心 4）→ 统一按「中心对齐」摆
                    draw_sprite_ext(goods_spr, _gsub,
                        (((x - 618) + (411 * j)) - 122) + (sprite_get_xoffset(goods_spr) - sprite_get_width(goods_spr) * 0.5) * _gsc,
                        ((y - 273) + (165 * i) + 25) + (sprite_get_yoffset(goods_spr) - sprite_get_height(goods_spr) * 0.5) * _gsc,
                        _gsc, _gsc, 0, c_white, 1);
                }

                if (variable_struct_exists(goods_info, "recipe_id"))
                {
                    // 食谱道具：形态已经练到了 → 售罄
                    // ⚠️ 初融菜谱是 type "card" + sell_recipe，**没有 target_shape 字段**，直接读会崩 →
                    //    第 3 页现在也会出现它们，所以缺字段时按 0（初融）处理
                    var _rshape = variable_struct_exists(goods_info, "target_shape") ? goods_info.target_shape : 0;
                    // 已经拥有对应形态 → 售罄（与 Create 里 is_disabled 的口径一致，2026-10-30）
                    var _rown = transfer_credit_card_max_shape(target_card_id);
                    if (has_fusion_recipe(target_card_id, _rshape) || _rown >= _rshape)
                    {
                        draw_set_color(c_black);
                        draw_set_alpha(0.5);
                        draw_rectangle(((x - 618) + (411 * j)) - 205, ((y - 248) + (165 * i)) - 82, (x - 618) + (411 * j) + 205, (y - 248) + (165 * i) + 82, false);
                        draw_set_alpha(1);
                        draw_sprite_ext(spr_sold_out, 0, (x - 618) + (411 * j), (y - 248) + (165 * i), 1.8, 1.8, 0, c_white, 1);
                    }
                }
                else
                {
                    var card_info_simple = get_card_info_simple(target_card_id);

                    if (card_info_simple != false)
                    {
                        // 已经转上去 → 盖售罄
                        // （2026-10-27 用户口径：凭证不限量，「背包里已有一张」不再算售罄）
                        if (get_card_info_simple(target_card_id).max_shape >= goods_info.target_shape)
                        {
                            draw_set_color(c_black);
                            draw_set_alpha(0.5);
                            draw_rectangle(((x - 618) + (411 * j)) - 205, ((y - 248) + (165 * i)) - 82, (x - 618) + (411 * j) + 205, (y - 248) + (165 * i) + 82, false);
                            draw_set_alpha(1);
                            draw_sprite_ext(spr_sold_out, 0, (x - 618) + (411 * j), (y - 248) + (165 * i), 1.8, 1.8, 0, c_white, 1);
                        }
                    }
                }
            }
        }
    }
}
