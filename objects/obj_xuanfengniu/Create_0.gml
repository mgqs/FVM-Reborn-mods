event_inherited();
plant_id = "xuanfengniu";
obj_type = object_index;
event_user(0);

sprite_index = spr_xuanfengniu;
if (shape == 1)
    sprite_index = spr_xuanfengniu_1;
else if (shape == 2)
    sprite_index = spr_xuanfengniu_2;

attack_anim = 0;
idle_anim = sprite_get_number(sprite_index);
flash_speed = 5;

// 二转不占格：使用 plant_type = "gridless" 与全局机制对齐
if (shape >= 2) {
    plant_type = "gridless";
} else {
    plant_type = "normal";
}
target_type = "normal";
is_slowdown = false;
invincible = true;

// 一转及以上支持清障
can_clear_obstacles = (shape >= 1);

// 起手动画播放完一整轮后触发一次全屏吹走，随后卡片退场
prev_image_index = 0;
has_activated = false;
is_activating = false;

// 旋风牛只秒杀这些指定目标（真实 mouse_id）。
// airbrone_explosive_mouse 是旧版本“飞行喷火鼠”的兼容 ID。
instant_kill_mouse_ids = [
    "glider_mouse",
    "flight_barrier_mouse",
    "waste_flying_mouse",
    "paratrooper_mouse",
    "kamikaze_glider_mouse",
    "machine_bomb_mouse",
    "longyuan_dongfeng",
    "airbrone_explosive_mouse"
];
