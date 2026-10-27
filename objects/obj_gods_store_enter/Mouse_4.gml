if (obj_gods_hall_bg.wish_completed && !obj_gods_hall_bg.is_submenu_opened)
{
    audio_play_sound(snd_button, 0, 0);
    instance_create_depth((room_width / 2) - 5, room_height / 2, depth - 10, obj_gods_store_bg);
    obj_gods_hall_bg.is_submenu_opened = true;
}
