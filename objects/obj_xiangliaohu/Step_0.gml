if (global.is_paused) exit;
event_inherited();

if (!buff_cells_refreshed){
    mod_buff_source_add(id);   // buff_value 已在 Create 从 custom["增幅倍率"] 取好
    refresh_buff_cells();
    global.buff_dirty = true;
    buff_cells_refreshed = true;
}
