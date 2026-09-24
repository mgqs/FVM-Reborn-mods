event_inherited();
plant_id = "save_god";
obj_type = object_index;
event_user(0);
spawned = false;
image_speed = 0;
anim_frame = 0;
idle_anim = 17;

if (shape == 3)
    idle_anim = 21;

if (shape == 0)
    sprite_index = spr_save_god_0;
else if (shape == 1)
    sprite_index = spr_save_god_1;
else if (shape == 2)
    sprite_index = spr_save_god_2;
else if (shape == 3)
    sprite_index = spr_save_god_3;
