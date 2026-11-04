// Inherit the parent event

if shield_hp > 0{
	sprite_index = spr_kuafu_landlady_shield
	attack_anim = 7
}
else{
	sprite_index = spr_kuafu_landlady
	attack_anim = 7
}
if shield_hp <= 0 && not armor_dropped{
	var inst = instance_create_depth(x-45,y-75,depth-1,obj_enemy_armor)
	inst.ground_y = y - 30
	inst.type = "shield"
	inst.x_speed = random_range(-3,-5)
	inst.y_speed = random_range(-1,-3)
	inst.cgravity = 0.8
	inst.sprite_index = spr_kuafu_landlady_door
	armor_dropped = true
}
event_inherited();