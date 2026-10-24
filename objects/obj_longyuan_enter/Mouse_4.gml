if (obj_player_info_ui.menu_type == 0)
{
    // 龙渊地图限制：玩家等级达到 20 级后才能进入
    if (global.save_data.player.level < 20)
    {
        show_notice("达到20级以进入龙渊", 60);
        exit;
    }
    audio_play_sound(snd_button, 0, 0);
    global.map_id = "longyuan";
    global.map_name = "龙渊";
    if (room != room_map) global.gui_stack.to(room_map);
}
