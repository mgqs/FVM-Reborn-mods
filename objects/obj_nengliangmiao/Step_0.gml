// obj_nengliangmiao Step：维护投手增幅网格（首次登记增幅源、挪格重建）
if (global.is_paused) exit;

event_inherited();
if (hp <= 0) exit;

if (!buff_cells_refreshed)
{
    buff_value = (variable_instance_exists(id, "base_cycle") ? base_cycle : cycle) / 60 / 100;
    ds_list_add(global.buff_sources, id);
    refresh_buff_cells();
    global.buff_dirty = true;
    buff_cells_refreshed = true;
    last_buff_col = grid_col;
    last_buff_row = grid_row;
}
else if (grid_col != last_buff_col || grid_row != last_buff_row)
{
    buff_value = (variable_instance_exists(id, "base_cycle") ? base_cycle : cycle) / 60 / 100;
    refresh_buff_cells();
    global.buff_dirty = true;
    last_buff_col = grid_col;
    last_buff_row = grid_row;
}
