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
                var card_data = deck_get_card_data(ds_map_find_value(global.gods_goods_map, ds_list_find_value(gods_goods_list, (i * 4) + j + ((current_page - 1) * 16))).unlock_item_id, 0);
            if (card_data != noone && ds_exists(card_data, ds_type_map))
            {
            var slot_sprite = (ds_map_find_value(card_data, "is_gold") == 1) ? spr_slot_1 : spr_slot;
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
        else if (shop_button_select == 2)
        {
            if (ds_list_find_value(gods_goods_list, (i * 4) + j + ((current_page - 1) * 16)) != undefined)
            {
                var goods_info = ds_map_find_value(global.gods_goods_map, ds_list_find_value(gods_goods_list, (i * 4) + j + ((current_page - 1) * 16)));
                var goods_spr = goods_info.spr;
                var target_card_id = goods_info.unlock_item_id;
                draw_sprite_ext(goods_spr, 0, ((x - 618) + (411 * j)) - 122, (y - 273) + (165 * i) + 25, 1.5, 1.5, 0, c_white, 1);
                var card_info_simple = get_card_info_simple(target_card_id);
                
                if (card_info_simple != false)
                {
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
