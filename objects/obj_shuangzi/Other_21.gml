global.zodiac_flame_mult = 1;
global.zodiac_query_card = id;
with (obj_yanyantu) event_user(0);
var inst = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
inst.value = floor((flame_produce) * global.zodiac_flame_mult);
var inst2 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
inst2.value = floor((flame_produce) * global.zodiac_flame_mult);

if (shape == 2)
{
    var inst3 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
    inst3.value = floor((flame_produce) * global.zodiac_flame_mult);
}
