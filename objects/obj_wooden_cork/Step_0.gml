if global.is_paused{
	exit
}

event_inherited(); 
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

attack_timer++

if attack_timer >= current_flash_speed * 40 - 1{
	with obj_mouse_hole{
		if grid_row == other.grid_row && grid_col == other.grid_col{
			instance_destroy()
		}
	}
	instance_destroy()
}