// Inherit the parent event
event_inherited();

mouse_id = "travel_record"
jump_times = 0
state = BOSS_STATE.APPEAR
hp = 50000
maxhp = 50000
immune_to_ash = true
wait_time = 0
cave = noone
sprite_index = spr_travel_record_appear
is_boss = true

hpbar_inst = instance_create_depth(450,1040,-900,obj_boss_hpbar)
hpbar_inst.target_boss = id
hpbar_inst.boss_id = mouse_id

skill_2_pos = [[2,6],[3,5],[4,4],[3,3],[4,2],[5,1]]

awake_card_id_list = []

if obj_battle.boss_count > 0{
	hpbar_inst.y -= 40
}

target_pos = {"row":-1,"col":-1}

avaliable_pos = ds_list_create()

x_move_speed = 0
y_move_speed = 0