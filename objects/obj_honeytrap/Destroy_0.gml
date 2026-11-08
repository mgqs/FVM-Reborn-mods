// obj_honeytrap Destroy 事件
// 卡被铲 / 被吃掉时，把停靠中的蜜蜂一起清掉，避免留下孤儿实例。
for (var _i = 0; _i < array_length(bees); _i++)
{
    if (instance_exists(bees[_i])) instance_destroy(bees[_i]);
}
if (variable_global_exists("buff_apply_id")) global.buff_apply_id++;
event_inherited();
