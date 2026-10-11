global.zodiac_flame_mult = 1;
global.zodiac_query_card = id;
with (obj_yanyantu) event_user(0);
if grow_timer < 90*60{
	var inst = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
	inst.value = floor((flame_produce - 10) * global.zodiac_flame_mult)
	inst.sprite_index = spr_flame_small
	if shape == 2{
		var inst2 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
		inst2.value = floor((flame_produce-10) * global.zodiac_flame_mult)
		inst2.sprite_index = spr_flame_small
	}
}
else{
	var inst = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
	inst.value = floor(flame_produce * global.zodiac_flame_mult);
	if shape == 2{
		var inst2 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
		inst2.value = floor(flame_produce * global.zodiac_flame_mult);
	}
}
