if (global.is_paused)
    exit;

event_inherited();

if (!buff_cells_refreshed)
{
    buff_value = atk / 100;
    ds_list_add(global.buff_sources, id);
    refresh_buff_cells();
    global.buff_dirty = true;
    buff_cells_refreshed = true;
}

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;
