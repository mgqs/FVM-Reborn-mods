if global.is_paused{
	exit
}
if global.level_file.level_time_feature == "daytime"{
	if flame_natural_growth_cycle > 0{
		flame_natural_growth_timer ++
		if flame_natural_growth_timer >= flame_natural_growth_cycle{
			var inst = instance_create_depth(950,-40,-1300,obj_flame)
			inst.mode = 0
			flame_natural_growth_timer = 0
		}
	}
}