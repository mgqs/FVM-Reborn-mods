// obj_shiliu_ash_fx Step —— 按帧播完一遍碎冰后自毁
if (global.is_paused) exit;

if (!sprite_exists(sprite_index)) {
    instance_destroy();
    exit;
}

frame_timer++;
if (frame_timer >= frame_speed) {
    frame_timer = 0;
    image_index++;
}

if (image_index >= sprite_get_number(sprite_index)) {
    instance_destroy();
}
