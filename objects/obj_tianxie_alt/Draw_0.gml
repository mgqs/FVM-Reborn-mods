// obj_tianxie_alt Draw：把卡面**顺时针转 90°（头朝右）**画出来
//   绘制点要按「内容中心压在实例坐标上」反推（常量见 Create_0 顶部）：
//     dx = + (cy - oy) * scale      dy = - (cx - ox) * scale
//   角度 90 = 顺时针 90°（GML 正角度在屏幕坐标里是顺时针）。
draw_sprite_ext(sprite_index, image_index, x + alt_dx, y + alt_dy, alt_scale, alt_scale, 90, c_white, image_alpha);
