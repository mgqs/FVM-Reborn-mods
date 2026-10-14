hovered = point_in_rectangle(mouse_x, mouse_y, x - 105, y - 24, x + 105, y + 24);
if (hovered && mouse_check_button_pressed(mb_left)) {
    var panel_x = obj_config_menu.x;
    var panel_y = obj_config_menu.y;
    var panel_depth = obj_config_menu.depth;
    if (instance_exists(obj_player_info_ui)) obj_player_info_ui.menu_type = 4;
    var panel = instance_create_depth(panel_x, panel_y, panel_depth - 10, obj_mod_menu);
    panel.return_depth = panel_depth;
    if (instance_exists(obj_config_menu)) instance_destroy(obj_config_menu);
    audio_play_sound(snd_button, 0, 0);
}
