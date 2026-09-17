

	if other.hp > 0 and row == other.grid_row  and can_hit(target_type,other.target_type){
		with(other){
			audio_play_sound(hit_sound,0,0)
			damage_amount = other.damage
			damage_type = other.damage_type
			event_user(0)
	
		}
		instance_destroy()
		if sprite_index == spr_chocolatepult_bullet_large{
			if shape >= 1{
				if other.stun_timer <240{
					other.stun_timer = 240
				}
			}
			else{
				if other.stun_timer <420{
					other.stun_timer = 420
				}
			}
			other.stun_sprite = spr_mouse_stick
		}
		else{
			var inst = instance_create_depth(x,y,depth,obj_coffeecup_bullet_effect)
			inst.sprite_index = spr_chocolatepult_bullet_effect
			inst.image_xscale = 1.2
			inst.image_yscale = 1.2
		}
		hit_enemy = true
		hitted_enemy = other.id
		// 计算子弹飞行时间（基于水平距离和预设速度）
	    var distance_x = other.x + global.grid_cell_size_x
	    var flight_time = 30
    
	    // 计算子弹所需的速度向量
	    var total_distance_x = distance_x - x
	    var total_distance_y = 300//enemy_y - inst.y
    
	    // 抛物线运动参数计算:cite[6]
	    move_speed = total_distance_x / flight_time
		cgravity = (2 * total_distance_y) / (flight_time * flight_time)
	    cvspeed = (total_distance_y - 0 * cgravity * flight_time * flight_time) / flight_time
	}
	
