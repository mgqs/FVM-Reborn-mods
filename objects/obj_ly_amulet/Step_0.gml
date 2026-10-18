if (global.is_paused) exit;
if (!instance_exists(owner) || owner.hp <= 0 || hp <= 0) { instance_destroy(); exit; }
timer++;
if (mode == "fly") {
    if (!instance_exists(target) || target.hp <= 0) {
        target = noone;
        var _left = 1000000000;
        with (obj_card_parent) {
            if (hp > 0 && grid_row == other.lane && plant_id != "player" && plant_type != "coffee" && !invincible && x < _left) { _left = x; other.target = id; }
        }
    }
    image_index = floor(timer / 6) mod 6;
    if (instance_exists(target)) {
        var _dir = point_direction(x, y, target.x, target.y - 40);
        x += lengthdir_x(4, _dir); y += lengthdir_y(4, _dir);
        if (point_distance(x, y, target.x, target.y - 40) < 12) { mode = "transform"; timer = 0; }
    } else x -= 4;
    if (timer > 600 || x < global.grid_offset_x - 100) instance_destroy();
} else {
    image_index = 6 + min(11, floor(timer / 6));
    if (timer >= 72) {
        if (instance_exists(target) && target.hp > 0 && !target.invincible) {
            var _pos = {x: target.x, y: target.y};
            var _owner = owner;
            with (target) { no_revive_record = true; is_shoveled = true; instance_destroy(); }
            instance_create_depth(_pos.x, _pos.y, depth, obj_ly_fuzhou_minion, {ly_owner: _owner});
        }
        instance_destroy();
    }
}
