// Inherit the parent event
event_inherited();

mouse_id = "ice_residue"
jump_times = 0
state = BOSS_STATE.APPEAR
hp = 12000
maxhp = 12000
immune_to_ash = true
wait_time = 0
cave = noone
sprite_index = spr_ice_residue_appear
is_boss = true
skill_count = 0

hpbar_inst = instance_create_depth(450,1040,-900,obj_boss_hpbar)
hpbar_inst.target_boss = id
hpbar_inst.boss_id = mouse_id

if obj_battle.boss_count > 0{
	hpbar_inst.y -= 40
}

shape = "ice"
spr_list = [spr_ice_residue_appear,spr_ice_residue_skill_1_ready,spr_ice_residue_skill_1,spr_ice_residue_skill_2,spr_ice_residue_disappear,spr_ice_residue_death]