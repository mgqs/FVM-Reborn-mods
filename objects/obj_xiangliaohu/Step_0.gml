if (global.is_paused) exit;
event_inherited();

if (!buff_cells_refreshed){
    buff_value = atk / 100;      // 倍率型：注册表存 ×100 整数
    ds_list_add(global.buff_sources, id);
    refresh_buff_cells();
    global.buff_dirty = true;
    buff_cells_refreshed = true;
}
