 // Inherit the parent event
event_inherited();
hp = 1000
maxhp = 1000
helmet_hp = 990
move_anim = 8
attack_anim = 4
death_anim = 12
move_speed = 0.72
mouse_id = "windmill_fish_mouse"
attack_range = 90

target_type = "air"

state = ENEMY_STATE.APPEAR
sprite_index = spr_windmill_fish_mouse_air
special_ash = true
immune_to_ash = true
anim_timer = 0
target_col = irandom_range(4,6)
y -= 30