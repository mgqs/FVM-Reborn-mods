with obj_battle{
	if boss_count > 1{
		boss_count--
	}
	else{
		boss_count = 0
		if  current_wave == total_wave-1 {
				battle_finish_win();
		}
		else{
			level_stage = "pre"
			current_wave += 1
			current_subwave = 0
		}
	}
}
global.save_data.unlocked_items.arno_killed = true
if global.save_data.unlocked_items.mario_mouse_killed && global.save_data.player.level < 7{
	global.save_data.player.level = 7
	show_notice("神殿已解锁",60)
}
instance_destroy(hpbar_inst)