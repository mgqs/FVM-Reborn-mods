event_inherited();
plant_id = "cold_drew";
event_user(0);
sprite_index = spr_cold_drew_machine;
max_targets = 4;

if (shape == 1)
{
    sprite_index = spr_cold_drew_machine_1;
    max_targets = 5;
}
else if (shape == 2)
{
    sprite_index = spr_cold_drew_machine_2;
    max_targets = 6;
}

attack_anim = 13;
idle_anim = 11;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
target_type = "all";
main_target = -4;
cooldown = cycle;
