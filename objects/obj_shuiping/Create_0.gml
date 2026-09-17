event_inherited();
plant_id = "shuiping";
obj_type = object_index;
current_level = 1;
event_user(0);
sprite_index = spr_shuiping;

if (shape == 1)
    sprite_index = spr_shuiping_1;
else if (shape == 2)
    sprite_index = spr_shuiping_2;

generation = 0;
attack_anim = 7;
can_mouse_list = ["can_mouse"];
idle_anim = 9;
flash_speed = 5;
plant_type = "normal";
invincible = true;

if (shape >= 1)
    atk *= 1.3;
