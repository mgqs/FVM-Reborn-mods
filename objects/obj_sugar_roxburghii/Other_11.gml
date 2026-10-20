can_stun_enemy = false
var stun_probability = 10
if shape >= 2{
	stun_probability = 20
}
var rm = irandom_range(1,100)
if rm <= stun_probability{
	can_stun_enemy = true
}

with obj_enemy_parent{
	if place_meeting(x,y,other) && hp > 0  && grid_row == other.grid_row && can_hit(other.target_type,target_type){
		damage_type = "throw"
		damage_amount = other.atk
		event_user(0)
		audio_play_sound(snd_hit1,0,0)
		if other.can_stun_enemy && stun_timer < 180{
			stun_timer = 180
			stun_sprite = spr_mouse_stun
		}
	}
}