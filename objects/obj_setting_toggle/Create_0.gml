image_xscale = 1
image_yscale = 1

// 默认状态为关闭
state = false;
image_speed = 0; // 停止动画

// 配置键名（由创建者设置）
config_key = "";
tooltip_text = ""
if (config_key == "play_mode_gacha") state = (global.play_mode == 1);
if (config_key == "play_mode_lucky") state = (global.play_mode == 2);
if (config_key == "play_mode_gift") state = (global.play_mode == 3);

bounce_t = -1
bounce_frames = 10
bounce_amount = 0.12
bounce_prev = state
bounce_base_x = image_xscale
bounce_base_y = image_yscale
