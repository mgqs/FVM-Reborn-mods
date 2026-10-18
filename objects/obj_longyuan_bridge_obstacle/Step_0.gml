if (global.is_paused) exit;
event_inherited();
if (!instance_exists(id)) exit;

if (array_length(longyuan_bridge_path) <= 0) exit;

var _target = longyuan_bridge_path[longyuan_bridge_path_index];
var _pos = get_world_position_from_grid(_target[0], _target[1]);
var _speed = 2.5;
var _distance = point_distance(x, y, _pos.x, _pos.y);
if (_distance <= _speed) {
    x = _pos.x;
    y = _pos.y;
    longyuan_bridge_clear_cell(_target[0], _target[1]);
    longyuan_bridge_path_index++;
    if (longyuan_bridge_path_index >= array_length(longyuan_bridge_path)) {
        if (variable_global_exists("longyuan_bridge_obstacle_" + longyuan_bridge_track)) {
            global[$ "longyuan_bridge_obstacle_" + longyuan_bridge_track] = noone;
        }
        instance_destroy();
        exit;
    }
} else {
    var _direction = point_direction(x, y, _pos.x, _pos.y);
    x += lengthdir_x(_speed, _direction);
    y += lengthdir_y(_speed, _direction);
}
