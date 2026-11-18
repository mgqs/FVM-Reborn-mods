// obj_jiejiema Destroy 事件
// 领队被铲 / 被打死 / 到点消失时，把挂在它名下的结界一起收走；
// 收走后下一帧剩下的马会重新选领队，结界按新阵型重新成形（计数也跟着清零）。
if (instance_exists(jj_field))
    instance_destroy(jj_field);

event_inherited();
