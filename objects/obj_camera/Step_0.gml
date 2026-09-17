if (shake_active) {
    var _cam = view_get_camera(0);
    
    // 计算衰减比例（线性衰减）
    var _t = 1 - (shake_time_remaining / shake_duration);
    var _current_magnitude = lerp(shake_magnitude, 0, _t);
    
    // 生成随机偏移
    var _offset_x = random_range(-_current_magnitude, _current_magnitude);
    var _offset_y = random_range(-_current_magnitude, _current_magnitude);
    
    // 应用偏移到摄像机
    camera_set_view_pos(_cam, shake_base_x + _offset_x, shake_base_y + _offset_y);
    
    // 更新时间
    shake_time_remaining--;
    if (shake_time_remaining <= 0) {
        shake_active = false;
        // 恢复原始位置
        camera_set_view_pos(_cam, shake_base_x, shake_base_y);
		instance_destroy()
    }
}

