if global.is_paused{
	exit
}

timer ++

if state == "appear"{
	image_index = floor(timer/5) mod 12
	if timer >= 12 * 5 - 1{
		timer = 0
		state = "attack"
	}
}
if state == "attack"{
	x += move_speed
	with obj_card_parent{
		if abs(x-other.x) <= 50 && grid_row == other.grid_row{
			if plant_id != "cotton_candy" && plant_type != "coffee" && plant_id != "soda_bubble"{
				var inst = instance_create_depth(other.x,other.y,other.depth,obj_coke_bomb_explode)
				inst.sprite_index = spr_conch_mouse_bullet_effect
				instance_destroy(other)
			}
			if plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"  && plant_id != "soda_bubble"{
				hp -= 20
				event_user(2)
			}
		}
	}
}

if x < -200 || x > 2200 || y < -200 || y > 1200{
	instance_destroy()
}