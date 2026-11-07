// obj_bbq_mouse_burn（老鼠身上的辣椒燃烧特效）Create 事件
// 由 obj_burn_cell 在被烧到的那只鼠身上创建：跟着目标走，life 帧（0.5 秒，和跳伤同节奏）后或目标消失即销毁。
//   fx_spr   = 要画的精灵（调用方给，缺省用对象自带 spr_bbq_burn_mouse）
//   target   = 跟随的老鼠实例
image_speed = 0;
image_index = 0;
image_alpha = 1;
image_angle = 0;
image_xscale = 1.6;
image_yscale = 1.6;

fx_spr = -1;
target = noone;
life = 30;
life_total = 30;
t = 0;
x_off = 0;           // 相对老鼠原点左右微调（正 = 右；法师蛇紫雾要往左一点）
y_off = 50;          // 相对老鼠原点（脚底）往上挪多少：30 时火焰压在脚上，50 才抬到腹部以上
