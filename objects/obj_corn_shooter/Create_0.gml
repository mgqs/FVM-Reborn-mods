event_inherited();
plant_id = "corn_shooter";
obj_type = object_index;
sprite_index = spr_corn_shooter;
current_level = 1;
event_user(0);

if (shape == 1)
    sprite_index = spr_corn_shooter_1;
else if (shape == 2)
    sprite_index = spr_corn_shooter_2;

attack_anim = 12;
idle_anim = 11;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
