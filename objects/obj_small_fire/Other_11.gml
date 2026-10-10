var inst = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
inst.value = floor(flame_produce * zodiac_flame_multiplier(id));
if shape == 2{
	var inst2 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
	inst2.value = floor(flame_produce * zodiac_flame_multiplier(id));
}
