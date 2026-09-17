if (!obj_gods_store_bg.is_submenu_opened && !is_disabled)
{
    audio_play_sound(snd_button, 0, 0);
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
    
    if (btn_type == "card")
    {
        if (amt >= cost || global.debug)
        {
            var inst = instance_create_depth(room_width / 2, room_height / 2, depth - 3, obj_gods_store_buy_confirm);
            inst.banding_buy_btn = id;
            obj_gods_store_bg.is_submenu_opened = true;
        }
        else
        {
            show_notice("神谕之石不足", 60);
        }
    }
    else if (btn_type == "shape")
    {
        if (meet_requirements)
        {
            if (amt >= cost || global.debug)
            {
                var inst = instance_create_depth(room_width / 2, room_height / 2, depth - 3, obj_gods_store_buy_confirm);
                inst.banding_buy_btn = id;
                obj_gods_store_bg.is_submenu_opened = true;
            }
            else
            {
                show_notice("神谕之石不足", 60);
            }
        }
        else
        {
            show_notice("卡片未解锁或未达到可转职等级，无法兑换凭证！", 60);
        }
    }
}
