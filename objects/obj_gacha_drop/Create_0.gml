// obj_gacha_drop - Create Event
if (!is_eternal_gacha_mode()) {
    instance_destroy();
    exit;
}

sprite_index = spr_lihe;
image_index = 0;
image_speed = 0;
state = 0; // 0 等待点击, 1 播放动画, 2 动画结束

depth = -3001;

// 以资源实际帧数为准，避免替换礼盒贴图后动画结束条件失效
anim_total_frames = sprite_get_number(sprite_index);
anim_frame = 0;
opened = false;

// 初始化抽卡奖励全局变量
gacha_init_reward();
