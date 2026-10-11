global.zodiac_flame_mult = 1;
global.zodiac_query_card = id;
with (obj_yanyantu) event_user(0);
var inst = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
inst.sprite_index = spr_sun_flame;
inst.value = floor((flame_produce) * global.zodiac_flame_mult);
var inst2 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
inst2.sprite_index = spr_sun_flame;
inst2.value = floor((flame_produce) * global.zodiac_flame_mult);
var inst3 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
inst3.sprite_index = spr_sun_flame;
inst3.value = floor((flame_produce) * global.zodiac_flame_mult);
var inst4 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
inst4.sprite_index = spr_sun_flame;
inst4.value = floor((flame_produce) * global.zodiac_flame_mult);
var inst5 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
inst5.sprite_index = spr_sun_flame;
inst5.value = floor((flame_produce) * global.zodiac_flame_mult);
var inst6 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
inst6.sprite_index = spr_sun_flame;
inst6.value = floor((flame_produce) * global.zodiac_flame_mult);

if (shape >= 1)
{
    var inst7 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
    inst7.sprite_index = spr_sun_flame;
    inst7.value = floor((flame_produce) * global.zodiac_flame_mult);
    var inst8 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
    inst8.sprite_index = spr_sun_flame;
    inst8.value = floor((flame_produce) * global.zodiac_flame_mult);
}

if (shape >= 2)
{
    var inst9 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
    inst9.sprite_index = spr_sun_flame;
    inst9.value = floor((flame_produce) * global.zodiac_flame_mult);
    var inst10 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
    inst10.sprite_index = spr_sun_flame;
    inst10.value = floor((flame_produce) * global.zodiac_flame_mult);
}

if (shape >= 3)
{
    var inst10 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
    inst10.sprite_index = spr_sun_flame;
    inst10.value = floor((flame_produce) * global.zodiac_flame_mult);
    var inst11 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
    inst11.sprite_index = spr_sun_flame;
    inst11.value = floor((flame_produce) * global.zodiac_flame_mult);
}
