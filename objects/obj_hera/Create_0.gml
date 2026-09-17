event_inherited();
plant_id = "hera";
current_level = 1;
obj_type = object_index;
event_user(0);
inner_inst = instance_create_depth(x, y - 18, depth + 2, obj_hera_inner);
inner_inst.parent_plant = id;
sprite_list = [spr_hera_outer_1, spr_hera_outer_2, spr_hera_outer_3];

if (shape == 1)
{
    sprite_list = [spr_hera_1_outer_1, spr_hera_1_outer_2, spr_hera_1_outer_3];
    inner_inst.sprite_index = spr_hera_inner;
    hp *= 1.25;
    atk *= 1.25;
}

if (shape == 2)
{
    sprite_list = [spr_hera_2_outer_1, spr_hera_2_outer_2, spr_hera_2_outer_3];
    inner_inst.sprite_index = spr_hera_inner;
    inner_inst.y -= 5;
    hp *= 1.25;
    atk *= 1.25;
}

if (shape == 3)
{
    sprite_list = [spr_hera_3_outer_1, spr_hera_3_outer_2, spr_hera_3_outer_3];
    inner_inst.sprite_index = spr_hera_inner;
    inner_inst.y -= 5;
    hp *= 1.25;
    atk *= 1.25;
}

sprite_index = sprite_list[0];
idle_anim = 11;
flash_speed = 5;
plant_type = "shield_outer";
can_mouse_list = ["can_mouse"];
is_slowdown = false;
bleed_damage = 0;
current_hp = hp;
attack_timer = 0;
is_clone = false;
spawn_init = false;
