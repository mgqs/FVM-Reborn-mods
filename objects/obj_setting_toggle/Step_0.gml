if (state) {
    image_index = 1; // 开启状态
} else {
    image_index = 0; // 关闭状态
}

if (state != bounce_prev) {
    bounce_prev = state
    if (ui_anim_on(2)) {
        bounce_t = 0
        bounce_base_x = image_xscale
        bounce_base_y = image_yscale
    } else {
        bounce_t = -1
    }
}
if (!ui_anim_on(2) && bounce_t >= 0) {
    bounce_t = -1
    image_xscale = bounce_base_x
    image_yscale = bounce_base_y
}
if (bounce_t >= 0) {
    bounce_t++
    if (bounce_t >= bounce_frames) {
        bounce_t = -1
        image_xscale = bounce_base_x
        image_yscale = bounce_base_y
    } else {
        var _s = 1 + bounce_amount * sin(pi * bounce_t / bounce_frames)
        image_xscale = bounce_base_x * _s
        image_yscale = bounce_base_y * _s
    }
}
