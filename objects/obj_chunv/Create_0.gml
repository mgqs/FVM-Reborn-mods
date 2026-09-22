event_inherited();
plant_id = "chunv";
current_level = 1;
obj_type = object_index;
event_user(0);

sprite_list = [spr_chunv_0_3, spr_chunv_0_2, spr_chunv_0_1];

if (shape == 1)
{
    sprite_list = [spr_chunv_1_4, spr_chunv_1_3, spr_chunv_1_2];
}

if (shape == 2)
{
    sprite_list = [spr_chunv_2_4, spr_chunv_2_3, spr_chunv_2_2];
}

sprite_index = sprite_list[0];

idle_anim = 10;
flash_speed = 5;
plant_type = "shield_outer";
is_slowdown = false;
bleed_damage = 0;
current_hp = hp;
attack_timer = 0;
heal_wait = 60;
