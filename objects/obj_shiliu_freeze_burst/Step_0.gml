// 按帧播完即销毁（不依赖动画结束事件，避免帧数/速度不匹配时残留）
if (global.is_paused) {
    exit;
}

if (!sprite_exists(sprite_index)) {
    instance_destroy();
    exit;
}

total_frames = sprite_get_number(sprite_index);

timer++;
var _frame = floor(timer / frame_speed);
if (_frame >= total_frames) {
    instance_destroy();
    exit;
}

image_index = _frame;
