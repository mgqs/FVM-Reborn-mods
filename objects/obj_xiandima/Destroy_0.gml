// 清理停靠中的飞马子弹
for (var i = 0; i < array_length(zodiac_stored); i++) if (instance_exists(zodiac_stored[i])) instance_destroy(zodiac_stored[i]);
if (variable_global_exists("buff_apply_id")) global.buff_apply_id++;
event_inherited();
