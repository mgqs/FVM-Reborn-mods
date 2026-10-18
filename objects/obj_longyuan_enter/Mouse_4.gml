if (obj_player_info_ui.menu_type == 0)
{
    audio_play_sound(snd_button, 0, 0);
    global.map_id = "longyuan";
    global.map_name = "龙渊";
    if (room != room_map) global.gui_stack.to(room_map);
}
