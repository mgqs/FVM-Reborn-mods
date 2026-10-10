if (global.is_paused) exit;
life--;
if (life <= 0) {instance_destroy(); exit;}
if (follow != noone) {
    if (instance_exists(follow)) {x = follow.x; y = follow.y-30;}
    else follow = noone;
}
