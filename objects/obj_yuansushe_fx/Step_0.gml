// obj_yuansushe_fx Step：按 fx_frame_ticks 逐帧推进，播完即销
// （不能用 image_speed + image_index >= 帧数 判完：5~6 帧的精灵只闪 0.1 秒，看不清）
if (global.is_paused)
    exit;

var _num = sprite_get_number(sprite_index);
if (_num <= 0)
{
    instance_destroy();
    exit;
}

// 首帧才拿得到真实精灵（创建方在 instance_create 之后才赋 sprite_index）
if (fx_max_index <= 0)
{
    fx_max_index = _num - 1;
    if (fx_life <= 0)
        fx_life = _num * max(1, fx_frame_ticks);
}

fx_timer++;
image_index = min(floor(fx_timer / max(1, fx_frame_ticks)), fx_max_index);

if (fx_timer >= fx_life)
    instance_destroy();
