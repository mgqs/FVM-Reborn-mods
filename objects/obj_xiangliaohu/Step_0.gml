if (global.is_paused) exit;
event_inherited();

if (!buff_cells_refreshed){
    ds_list_add(global.buff_sources, id);   // buff_value 已在 Create 从 custom["增幅倍率"] 取好
    refresh_buff_cells();
    global.buff_dirty = true;
    buff_cells_refreshed = true;
}
