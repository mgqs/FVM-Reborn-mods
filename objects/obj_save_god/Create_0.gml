event_inherited();
plant_id = "save_god";
obj_type = object_index;
event_user(0);
spawned = false;
idle_anim = 17;
cooldown_timer = 3600;
attacking = false;

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
