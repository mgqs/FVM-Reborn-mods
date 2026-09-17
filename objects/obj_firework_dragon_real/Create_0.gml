event_inherited();
plant_id = "firework_dragon_real";
obj_type = object_index;
flame_produce = 75;
first_produce_delay = 60;
event_user(0);

if (shape == 1)
    sprite_index = spr_firework_dragon_1;
else if (shape == 2)
    sprite_index = spr_firework_dragon_2;
else
    sprite_index = spr_firework_dragon;

attack_anim = 24;
idle_anim = 9;
plant_type = "normal";
invincible = true;

if (shape >= 1)
{
    for (var i = 0; i < 2; i++)
    {
        var inst = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
        inst.value = 75;
    }
}