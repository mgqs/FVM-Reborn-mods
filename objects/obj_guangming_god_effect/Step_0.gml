if (global.is_paused)
    exit;

frame_counter++;

var _total_frames = sprite_get_number(sprite_index);

if (is_one_shot)
{
    var _frame = floor(frame_counter / flash_speed);
    if (_frame >= _total_frames)
    {
        instance_destroy();
        exit;
    }
    image_index = _frame;
}
else
{
    image_index = floor(frame_counter / flash_speed) mod _total_frames;
}
