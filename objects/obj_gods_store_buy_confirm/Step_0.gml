selected_button = -1;
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

for (var i = 0; i < array_length(buttons); i++)
{
    var btn = buttons[i];
    var btn_x = x + btn[0];
    var btn_y = y + 70;
    var btn_width = btn[2];
    var btn_height = btn[3];
    
    if (point_in_rectangle(mx, my, btn_x - (btn_width / 2), btn_y - (btn_height / 2), btn_x + (btn_width / 2), btn_y + (btn_height / 2)))
    {
        selected_button = i;
        
        if (mouse_check_button_released(mb_left))
        {
            switch (i)
            {
                case 1:
                    obj_gods_store_bg.is_submenu_opened = false;
                    instance_destroy();
                    break;
                
                case 0:
                    obj_gods_store_bg.is_submenu_opened = false;
                    
                    with (banding_buy_btn)
                    {
                        if (btn_type == "evo")
                        {
                            // 进化凭证：只进背包（合成屋-金卡进化用），不顺带解锁金卡
                            add_material_amount("oracle_stone", -cost);
                            add_material_amount(mod_evo_credit_id(target_item), 1);
                        }
                        else if (btn_type == "card")
                        {
                            add_material_amount("oracle_stone", -cost);
                            unlock_card(target_item, 0, 0, global.save_data.unlocked_items.max_skill_level);
                        }
                        else if (btn_type == "tvoucher")
                        {
                            // 转职凭证道具：只进背包（合成屋-卡片转职 消耗它），不直接改卡形态
                            add_material_amount("oracle_stone", -cost);
                            add_material_amount(transfer_credit_id(target_item, target_shape), 1);
                        }
                        else if (btn_type == "shape")
                        {
                            add_material_amount("oracle_stone", -cost);
                            upgrade_card_shape(target_item, target_shape);
                        }
                        else if (btn_type == "recipe")
                        {
                            // 食谱道具：只进背包（融合页用它当「融合菜谱」，用掉扣 1 本）
                            add_material_amount("oracle_stone", -cost);
                            add_material_amount(recipe_id, 1);
                        }
                    }
                    
                    with (obj_gods_store_bg)
                        gods_shop_list_recharge();
                    
                    instance_destroy();
                    break;
            }
            
            audio_play_sound(snd_button, 0, 0);
        }
        
        break;
    }
}

if (keyboard_check_pressed(vk_escape))
    instance_destroy();