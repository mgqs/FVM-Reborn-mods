// obj_yuansushe 用户事件 1（Other_11）：出弹
//   0/1 转：1 颗，颜色 黄→紫→蓝→红 循环
//   2 转：2 颗，第一颗按同一循环、第二颗恒红（官方「黄+红 / 紫+红 / 蓝+红 / 红+红」）
//   第二颗晚 8 帧出膛，读起来像"连吐两口"而不是同一个点冒两颗。
var _c0 = ys_step;

ys_fire_one(_c0, 0);
if (ys_bullet_count >= 2)
    ys_fire_one(ys_second_color, 8);

var _next = (_c0 + 1) mod 4;
ys_step = _next;
ys_pending_eye = _next;    // Step 里回到待机后切图

audio_play_sound(snd_shot, 0, 0);
