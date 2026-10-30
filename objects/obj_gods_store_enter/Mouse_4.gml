if (obj_gods_hall_bg.wish_completed && !obj_gods_hall_bg.is_submenu_opened)
{
    // 2026-10-27：抽卡模式（星际/欧皇抽卡）不再禁用诸神商店，与普通模式一致
    audio_play_sound(snd_button, 0, 0);
    instance_create_depth((room_width / 2) - 5, room_height / 2, depth - 10, obj_gods_store_bg);
    obj_gods_hall_bg.is_submenu_opened = true;
}
