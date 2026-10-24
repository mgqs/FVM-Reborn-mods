if (global.is_paused) exit;
life--;
if (life <= 0) {instance_destroy(); exit;}
if (follow != noone) {
    if (instance_exists(follow)) {
        x = follow.x;
        y = follow.y + follow_y_offset;
        if (variable_instance_exists(id, "yanyantu_target")) depth = follow.depth + 1;
    }
    else follow = noone;
}
