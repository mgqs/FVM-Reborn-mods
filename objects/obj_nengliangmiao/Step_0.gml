// obj_nengliangmiao Step：维护投手增幅网格（首次登记增幅源、挪格重建）
if (global.is_paused) exit;

event_inherited();
if (hp <= 0) exit;

// 星级 / 技能 / 形态变了就重取一次倍率（建实例之后才写入的情况：升星、转职、换技能）
if (current_level != _nl_lv || skill != _nl_sk || shape != _nl_sh)
{
    _nl_lv = current_level; _nl_sk = skill; _nl_sh = shape;
    var _ni = get_plant_data_with_skill("nengliangmiao", shape, clamp(current_level, 0, 16), skill);
    throw_buff_value = (_ni != undefined && ds_map_exists(_ni, "投掷增幅")) ? _ni[? "投掷增幅"] : 1;
    buff_value = throw_buff_value;
    refresh_buff_cells();
    global.buff_dirty = true;
}

if (!buff_cells_refreshed)
{
    buff_value = throw_buff_value;   // Create 里从 custom["投掷增幅"] 取好（不再借 cycle 存）
    ds_list_add(global.buff_sources, id);
    refresh_buff_cells();
    global.buff_dirty = true;
    buff_cells_refreshed = true;
    last_buff_col = grid_col;
    last_buff_row = grid_row;
}
else if (grid_col != last_buff_col || grid_row != last_buff_row)
{
    buff_value = throw_buff_value;   // Create 里从 custom["投掷增幅"] 取好（不再借 cycle 存）
    refresh_buff_cells();
    global.buff_dirty = true;
    last_buff_col = grid_col;
    last_buff_row = grid_row;
}
