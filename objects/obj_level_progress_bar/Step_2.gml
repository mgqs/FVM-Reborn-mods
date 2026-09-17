if global.is_paused{
	exit
}


if obj_battle.current_wave >= elite_wave && obj_battle.wave_timer <= 1{
	if global.save_data.unlocked_items.elite_unlocked{
		level_stage = "elite"
		if obj_battle_music_controller.battle_music != global.level_data.elite_music && obj_battle.level_stage != "boss"{
			with obj_battle_music_controller{
				new_battle_music = global.level_data.elite_music
				event_user(0)
			}
		}
	}
	else{
		//global.is_paused = true
		//global.game_over = true
		//var inst = instance_create_depth(room_width/2,room_height/2,-3001,obj_game_over)
		//inst.sprite_index = spr_win
		//audio_play_sound(snd_win,0,0)
	}
}