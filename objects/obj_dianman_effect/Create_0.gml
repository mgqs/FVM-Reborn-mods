// obj_dianman_effect（电鳗范围电弧）Create
// 2026-11-06 用户口径：**放下时不显示**，只在电鳗「放电那一下」才亮起来
//   由 obj_dianman 在本体放电帧把 active 打开，这里自己播一遍 13 帧就熄。
image_speed = 0;
image_index = 0;
image_alpha = 0;        // 创建即隐形
image_blend = c_white;
image_xscale = 1.8;
image_yscale = 1.8;
anim_t = 0;
active = false;
