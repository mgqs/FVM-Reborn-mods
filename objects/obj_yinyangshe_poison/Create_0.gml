// obj_yinyangshe_poison（中毒）Create 事件
// 挂在某只老鼠身上的持续毒伤：总伤害分 yy_ticks 次跳完，跟着宿主走，
// 宿主死了 / 被销毁就自己消失。
//   总伤害由子弹算好传进来：攻击力 × 火盆倍率 × 3（0/1 转）或 4.5（2 转）
yy_host     = noone;
yy_total    = 0;
yy_ticks    = 3;
yy_tick_gap = 20;
yy_timer    = 0;

image_speed = 0;
image_index = 0;
yy_anim = 0;

depth = -300;
visible = true;
