var _shoveled = variable_instance_exists(id, "is_shoveled") && is_shoveled;

if (!_shoveled && hp <= 0)
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
