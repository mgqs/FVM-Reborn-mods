if grow_timer < 90*60{
	var inst = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
	inst.value = floor((flame_produce - 10) * zodiac_flame_multiplier(id))
	inst.sprite_index = spr_flame_small
	if shape == 2{
		var inst2 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
		inst2.value = floor((flame_produce-10) * zodiac_flame_multiplier(id))
		inst2.sprite_index = spr_flame_small
	}
}
else{
	var inst = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
	inst.value = floor(flame_produce * zodiac_flame_multiplier(id));
	if shape == 2{
		var inst2 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
		inst2.value = floor(flame_produce * zodiac_flame_multiplier(id));
	}
}
