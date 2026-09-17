event_inherited();
plant_id = "chunv";
current_level = 1;
obj_type = object_index;
event_user(0);
inner_inst = instance_create_depth(x, y - 18, depth + 2, obj_chunv_inner);
inner_inst.parent_plant = id;
sprite_list = [spr_chunv_0_0, spr_chunv_0_0, spr_chunv_0_1];

if (shape == 1)
{
    sprite_list = [spr_chunv_1_0, spr_chunv_1_1, spr_chunv_1_2];
    inner_inst.sprite_index = spr_chunv_1_3;
}

if (shape == 2)
{
    sprite_list = [spr_chunv_2_0, spr_chunv_2_1, spr_chunv_2_2];
    inner_inst.sprite_index = spr_chunv_2_3;
    inner_inst.y -= 5;
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
