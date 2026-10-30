image_xscale = 1;
image_yscale = 1;
image_speed = 0;
is_one_shot = false;
frame_counter = 0;
flash_speed = 3;
center_screen = false;
scale_multiplier = 1;
// 左半屏铺满（2026-10-28）：为真时把内容框等比缩进「0..room_width/2 × 0..room_height」并裁掉溢出，
// 不看 scale_multiplier、也不受 sprite 原点影响（妖化变身 spr_yao_bianshen2 用）
left_half = false;
// left_half 用的「内容框」（源图像素）：0 表示改用 sprite 自动 bbox。
// 立绘类贴图画布四周有大量透明留白（如 spr_yao_bianshen2 画布 1811x2044，可见内容只有
// 稳定帧的 684,679,518,603），必须由调用方给出稳定的那一块，否则按 bbox 缩会缩成一小团。
half_src_x = 0;
half_src_y = 0;
half_src_w = 0;
half_src_h = 0;
