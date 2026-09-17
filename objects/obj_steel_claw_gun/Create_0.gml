image_xscale = 1.6
image_yscale = 1.6
image_speed = 0
parent_player = noone
atk = 0
cycle = 0
grid_col = 0
grid_row = 0
flash_speed = 6
attack_anim = 6
timer = 0
state = CARD_STATE.IDLE;
attack_timer = 0
weapon_id = "steel_claw_gun"
weapon_info = get_weapon_info(weapon_id)
atk = weapon_info.atk
cycle = weapon_info.cycle

if get_gem_index("attack_gem")!= -1{
	atk = weapon_info.atk_impact[get_gem_level("attack_gem")]
}