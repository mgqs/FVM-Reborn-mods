// Inherit the parent event
event_inherited();

mouse_id = "mario_mouse"
jump_times = 0
state = BOSS_STATE.APPEAR
hp = 9000
maxhp = 9000
immune_to_ash = true
wait_time = 5 * 60
cave = noone
pipeline = noone
sprite_index = spr_mario_mouse_appear
is_boss = true

hpbar_inst = instance_create_depth(450,1040,-900,obj_boss_hpbar)
hpbar_inst.target_boss = id
hpbar_inst.boss_id = mouse_id

pipe_row = "land"

if obj_battle.boss_count > 0{
	hpbar_inst.y -= 40
}