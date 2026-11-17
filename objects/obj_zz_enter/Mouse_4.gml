if (room == room_battle) exit;
if (obj_player_info_ui.menu_type != 0 || instance_exists(obj_zz_bg)) exit;
if (!point_in_rectangle(mouse_x, mouse_y, x, y, x + sprite_width, y + sprite_height)) exit;

audio_play_sound(snd_button, 0, 0);
instance_create_depth(room_width / 2, room_height / 2, -5, obj_zz_bg);
obj_player_info_ui.menu_type = 4;
obj_world_map_button.world_map = 2;
