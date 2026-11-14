if (global.is_paused)
    exit;

event_inherited();

if (!buff_cells_refreshed)
{
    // 三条通道一起重建（移位 / 转职后必须刷新，见 Create_0）
    buff_value = atk / 100;
    var _radius = (shape >= 1) ? 2 : 1;
    buff_outputs = [
        { type: "sprayer",        cells: cells_square(grid_col, grid_row, _radius, buff_value) },
        { type: "sprayer_attach", cells: cells_square(grid_col, grid_row, _radius, buff_value) },
        { type: "sprayer_coffee", cells: cells_row(grid_row, buff_value) }
    ];
    global.buff_dirty = true;
    buff_cells_refreshed = true;
}

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;
