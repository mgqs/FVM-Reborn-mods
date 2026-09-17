if (!obj_gods_store_bg.is_submenu_opened)
{
    obj_gods_store_bg.shop_button_select = button_index;
    obj_gods_store_bg.current_page = 1;
    
    with (obj_gods_store_bg)
        gods_shop_list_recharge();
    
    audio_play_sound(snd_button, 0, 0);
}
