event_inherited();
plant_id = "beef_hot_pot";
event_user(0);

if (shape == 0)
    sprite_index = spr_beef_hot_pot;
else if (shape == 1)
    sprite_index = spr_beef_hot_pot_1;
else if (shape == 2)
    sprite_index = spr_beef_hot_pot_2;

attack_anim = 44;
idle_anim = 11;
flash_speed = 5;
plant_type = "normal";
target_type = "pierce";
is_slowdown = false;
damage_timer = 0;
