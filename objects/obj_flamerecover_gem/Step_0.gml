if global.is_paused{
	exit
}
if global.debug{
	cooldown=60
}
if cooldown_timer>0 {cooldown_timer--}
else{
	for(var i = 0 ; i < flame_amount;i++){
		var inst = instance_create_depth(950,-40,-1300,obj_flame)
		inst.mode = 0
		inst.value = flame_value
	}
	cooldown_timer = cooldown
}