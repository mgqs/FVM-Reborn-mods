hovered = point_in_rectangle(mouse_x, mouse_y, x - 105, y - 24, x + 105, y + 24);

if (hovered && mouse_check_button_pressed(mb_left)) {
    if (!instance_exists(obj_hex_list)) {
        var _mx = (instance_exists(obj_config_menu)) ? obj_config_menu.x : room_width / 2;
        var _my = (instance_exists(obj_config_menu)) ? obj_config_menu.y : room_height / 2;
        var _dp = (instance_exists(obj_config_menu)) ? obj_config_menu.depth : -100;
        instance_create_depth(_mx, _my, _dp - 500, obj_hex_list);
    }
    audio_play_sound(snd_button, 0, 0);
}
