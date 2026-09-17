if (!obj_gods_store_bg.is_submenu_opened)
{
    if (btn_type == "prev")
    {
        if (obj_gods_store_bg.current_page > 1)
            obj_gods_store_bg.current_page--;
    }
    else if (btn_type == "next")
    {
        if (obj_gods_store_bg.current_page < obj_gods_store_bg.current_max_page)
            obj_gods_store_bg.current_page++;
    }
    
    audio_play_sound(snd_button, 0, 0);
    
    with (obj_gods_store_bg)
        gods_shop_list_recharge();
}
