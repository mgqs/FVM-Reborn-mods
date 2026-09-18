if (global.is_paused) {
    image_speed = 0;
    exit;
}

image_speed = 0.75;

if (is_one_shot) {
    frame_counter++;
    var total_frames = floor(sprite_get_number(sprite_index) / image_speed);
    if (frame_counter >= total_frames) {
        instance_destroy();
    }
}
