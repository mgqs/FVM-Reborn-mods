if (obj_player_info_ui.menu_type == 0)
{
    audio_play_sound(snd_button, 0, 0);
    instance_create_depth(room_width / 2, room_height / 2, -5, obj_gods_hall_bg);
    obj_player_info_ui.menu_type = 4;
    obj_world_map_button.world_map = 2;
}
