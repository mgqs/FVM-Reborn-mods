 // Inherit the parent event
event_inherited();
hp = 1100
maxhp = 1100
helmet_hp = 1083
move_anim = 8
attack_anim = 4
death_anim = 12
move_speed = 0.9
mouse_id = "kuafu_barrier"
attack_range = 90

target_type = "air"

state = ENEMY_STATE.APPEAR
sprite_index = spr_kuafu_barrier_air
special_ash = true
immune_to_ash = true
anim_timer = 0
target_col = irandom_range(4,6)
y -= 30
move_anim = 16
attack_anim = 6
death_anim = 17
