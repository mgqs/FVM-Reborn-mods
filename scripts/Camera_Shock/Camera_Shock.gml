function Camera_Shock(_duration,_magnitude){
	inst = instance_create_depth(0,0,0,obj_camera)
    inst.shake_active = true;
    inst.shake_duration = _duration;
    inst.shake_time_remaining = _duration;
    inst.shake_magnitude = _magnitude;
    
    // 记录当前摄像机位置作为基准
    var _cam = view_get_camera(0); // 假设使用第一个视图的摄像机
    inst.shake_base_x = 0//camera_get_view_x(_cam);
    inst.shake_base_y = 0//camera_get_view_y(_cam);
}