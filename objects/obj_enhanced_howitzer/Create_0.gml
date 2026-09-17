image_xscale = 1.6
image_yscale = 1.6
image_speed = 0
image_alpha = 0
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
weapon_id = "enhanced_howitzer"
weapon_info = get_weapon_info(weapon_id)
atk = weapon_info.atk
cycle = weapon_info.cycle

target_enemy = noone

if get_gem_index("power_gem")!= -1{
	atk = weapon_info.atk_impact[get_gem_level("power_gem")]
}
if get_gem_index("gale_gem")!= -1{
	cycle = weapon_info.cycle_impact[get_gem_level("gale_gem")]
}