event_inherited();
plant_id = "gaia";
obj_type = object_index;
current_level = 1;
event_user(0);
sprite_index = spr_gaia;

if (shape == 1)
    sprite_index = spr_gaia_1;
else if (shape == 2)
    sprite_index = spr_gaia_2;
else if (shape == 3)
    sprite_index = spr_gaia_3;

attack_anim = 21;
idle_anim = 11;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
// 攻击类型：normal（陆鼠 + 障碍）；灰烬入口 can_hit_ash 另放行 非主流·高跷
target_type = "normal";
target_x = -4;
target_y = 0;
target_row = 0;

if (shape == 0)
    cooldown_timer = cycle;
else
    cooldown_timer = 30;

attacking = false;
