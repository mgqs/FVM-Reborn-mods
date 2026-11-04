event_inherited();
plant_id = "firework_dragon_real";
obj_type = object_index;
flame_produce = 75;
first_produce_delay = 420;
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
    // 一转以上的额外火苗同样按 [火苗产量] 结算（星级影响产量），
    // 原来硬编码 75 会让这几朵火苗永远停留在 0 星数值。
    for (var i = 0; i < 2; i++)
    {
        var inst = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
        inst.value = flame_produce;
    }
}