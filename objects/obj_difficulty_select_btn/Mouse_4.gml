// 切换状态
if room != room_battle{
	if config_key == "difficulty"{
		if b_type == "next"{
			if state < 5{
				state ++
			}
			else{
				state = 0
			}
		}
		else{
			if state > 0{
				state --
			}
			else{
				state = 5
			}
		}
	}
	global.audio.play(snd_button,0,0)
	// 保存到配置文件
	if (config_key != "") {
	    ini_open("config.ini");
	    ini_write_real("settings", config_key, state);
	    ini_close();
	}

	if (config_key == "difficulty"){
		global.difficulty = state

		// 永恒 / 不朽 开局奖励互斥：这里只开窗，发奖在 obj_start_reward 里点「领取」才走
		if (!is_undefined(difficulty_start_reward_of(state)) && difficulty_start_reward_available(state)){
			if (!instance_exists(obj_start_reward)){
				var _sr = instance_create_depth(0, 0, -16000, obj_start_reward)
				_sr.sr_diff = state
			}
		}
		else if (state == 5 && global.play_mode == 0 && immortal_pick_pending()
			&& !instance_exists(obj_immortal_pick)){
			// 老存档迁移：开局奖励算领过了（领的是不朽），但三选一还没结算 → 仍然补弹
			instance_create_depth(0, 0, -16000, obj_immortal_pick)
		}
	}
}
else{
	global.audio.play(snd_button,0,0)
	show_notice("无法在游戏中修改难度",60)
}
