if global.is_paused{
	exit
}


if obj_battle.current_wave >= elite_wave && obj_battle.wave_timer <= 1{
	if global.save_data.unlocked_items.elite_unlocked{
		level_stage = "elite"
		// 已经抽过「BOSS 随机音乐」就不再切回 elite_music，否则会把随机曲顶掉
		if !obj_battle_music_controller.music_picked && obj_battle_music_controller.battle_music != global.level_data.elite_music && obj_battle.level_stage != "boss"{
			with obj_battle_music_controller{
				new_battle_music = global.level_data.elite_music
				event_user(10)
			}
		}
	}
	else{
		//global.is_paused = true
		//global.game_over = true
		//var inst = instance_create_depth(room_width/2,room_height/2,-3001,obj_game_over)
		//inst.sprite_index = spr_win
		//global.audio.play(snd_win,0,0)
	}
}