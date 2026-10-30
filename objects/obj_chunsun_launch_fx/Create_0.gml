// 非精英鼠被秒杀后的「向上击飞」表现：复制老鼠贴图后上抛 + 翻滚 + 淡出
image_speed = 0;
launch_vy = -9;
launch_grav = 0.4;
launch_tick = 0;
image_alpha = 1;
launch_spin = random_range(-6, 6);   // 翻滚角速度（度/帧），正负随机 = 顺/逆时针
