var inst = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
inst.value = flame_produce;
var inst2 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
inst2.value = flame_produce;
var inst3 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
inst3.value = flame_produce;

if (shape >= 1)
{
    var inst4 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
    inst4.value = flame_produce;
}

if (shape == 2)
{
    var inst5 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
    inst5.value = flame_produce;
}