event_inherited();
// 归元马送回鼠：能力同平民鼠，动画帧段 0-7送回登场 / 7-15行走 / 16-23啃咬 / 23-34死亡
gy_return_start = 0;
gy_return_end = 7;
gy_walk_start = 7;
gy_walk_end = 15;
gy_bite_start = 16;
gy_bite_end = 23;
gy_death_start = 23;
gy_death_end = min(34,sprite_get_number(sprite_index)-1);
gy_returning = true;
timer = 0;
