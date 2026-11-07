// 2026-11-07：条件从「hp <= 0」改成「只要不是铲除就炸」—— 战神齿轮 / 木鸭木轮 / 滚木、
//   洞君、阿诺这类都是满血直接 instance_destroy()，按 hp <= 0 判会整片不炸。
var _shoveled = variable_instance_exists(id, "is_shoveled") && is_shoveled;

if (!_shoveled)
{
    var _boom = instance_create_depth(x, y, depth + 1, obj_guihuajiu_boom);
    _boom.shape       = shape;
    _boom.grid_col    = grid_col;
    _boom.grid_row    = grid_row;
    _boom.boom_damage = boom_damage;
    _boom.boom_cross  = boom_cross;
    _boom.boom_type   = boom_type;
    _boom.burn_total  = burn_total;
    _boom.burn_cross  = burn_cross;
    _boom.burn_type   = burn_type;
    _boom.drunk_time  = drunk_time;
    _boom.drunk_mult  = drunk_mult;
}

event_inherited();
