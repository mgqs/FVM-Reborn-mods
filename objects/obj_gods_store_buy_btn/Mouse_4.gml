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
    
    // 抽卡模式（含欧皇）：卡片类不能买（跟普通商店禁买防御卡同一套口径）；随机礼盒不在此列
    if ((btn_type == "evo" || btn_type == "card" || btn_type == "recipe")
        && is_eternal_gacha_mode())
    {
        show_notice("抽卡模式只能买转职凭证", 60);
        exit;
    }

    if (btn_type == "evo")
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
    else if (btn_type == "card")
    {
        if (!meet_requirements)
        {
            show_notice(requirement_notice, 60);
        }
        else if (amt >= cost || global.debug)
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
    else if (btn_type == "tvoucher")
    {
        // 三/四/终转凭证道具：买到手进背包，去合成屋-卡片转职 用（不在这里直接升形态）
        if (!meet_requirements)
        {
            show_notice(requirement_notice, 60);
        }
        else if (amt >= cost || global.debug)
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
    else if (btn_type == "recipe")
    {
        // 融合卡的食谱道具：买到手进背包，不直接解锁卡 / 不直接升形态
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
}
