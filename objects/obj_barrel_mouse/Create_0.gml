 // Inherit the parent event
event_inherited();
hp = 2700
maxhp = 2700
move_anim = 12
attack_anim = 4
death_anim = 13
move_speed = 0.45
immune_to_ash = true
mouse_id = "can_mouse"
can_dropped = false
anim_timer = 0
act_cooldown = 0

function into_act(){
	if state != ENEMY_STATE.ACTING && state != ENEMY_STATE.DIG && act_cooldown <= 0{
		state = ENEMY_STATE.ACTING
		sprite_index = spr_barrel_mouse_act
		anim_timer = 0
	}
}