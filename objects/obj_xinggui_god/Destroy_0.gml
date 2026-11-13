// obj_xinggui_god Destroy 事件：清掉光环与四角装饰，并触发一次增幅重算
for (var _i = 0; _i < array_length(xg_corner_effects); _i++)
{
    if (instance_exists(xg_corner_effects[_i]))
        instance_destroy(xg_corner_effects[_i]);
}
xg_corner_effects = [];

if (instance_exists(xg_halo))
    instance_destroy(xg_halo);

if (variable_global_exists("xg_corner_owner") && global.xg_corner_owner == id)
    global.xg_corner_owner = noone;

if (variable_global_exists("buff_apply_id")) global.buff_apply_id++;

event_inherited();
