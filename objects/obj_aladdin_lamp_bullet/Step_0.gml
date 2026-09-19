if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 1;
var _cy = global.grid_offset_y + ((global.grid_rows * global.grid_cell_size_y) / 2);
var _max_dist = ((global.grid_rows * global.grid_cell_size_y) / 2) + 100;
var _dist = abs(y - _cy);
var _spd = 6 + (8 * (1 - (_dist / max(_max_dist, 1))));
_spd = clamp(_spd, 4, 12);

if (direction == 270)
    y += _spd;
else
    y -= _spd;

var _top = global.grid_offset_y - 81;
var _bot = global.grid_offset_y + (global.grid_rows * global.grid_cell_size_y) + 81;

if (y < _top || y > _bot)
    instance_destroy();
