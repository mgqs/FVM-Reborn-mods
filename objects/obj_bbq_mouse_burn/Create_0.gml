// obj_bbq_mouse_burn（老鼠身上的辣椒燃烧特效）Create 事件
// 由 obj_burn_cell 在被烧到的那只鼠身上创建：跟着目标走，life 帧（1 秒）后或目标消失即销毁。
//   fx_spr   = 要画的精灵（调用方给，缺省用对象自带 spr_bbq_burn_mouse）
//   target   = 跟随的老鼠实例
image_speed = 0;
image_index = 0;
image_alpha = 1;
image_angle = 0;
image_xscale = 1.2;
image_yscale = 1.2;

fx_spr = -1;
target = noone;
life = 60;
life_total = 60;
t = 0;
y_off = 30;          // 相对老鼠原点（脚底）往上挪多少
