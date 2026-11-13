// obj_xinggui_god_effect Step 事件：暂停时停帧，其余交给 sprite 自身的循环
if (global.is_paused)
    image_speed = 0;
else
    image_speed = 0.5;
