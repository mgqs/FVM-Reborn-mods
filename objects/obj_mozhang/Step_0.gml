if (global.is_paused)
    exit;

event_inherited();

if (!buff_cells_refreshed)
{
    buff_value = atk / 100;
    buff_cells = [];
    var radius = (shape >= 1) ? 2 : 1;
    add_square(buff_cells, grid_col, grid_row, radius, buff_value);
    add_row(buff_cells, grid_row, buff_value);
    global.buff_dirty = true;
    buff_cells_refreshed = true;
}

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;
