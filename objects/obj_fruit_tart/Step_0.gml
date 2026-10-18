if global.is_paused{
	exit
}
event_inherited(); 
if (!buff_cells_refreshed)
{
    buff_value = atk / 100;
    ds_list_add(global.buff_sources, id);
    buff_cells = [];
    var _left = (shape >= 2) ? 0 : grid_col - 1;
    for (var _col = _left; _col >= 0; _col--)
        array_push(buff_cells, [_col, grid_row, buff_value]);
    global.buff_dirty = true;
    buff_cells_refreshed = true;
}

