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
		difficulty_grant_immortal_start_cards()
		if (state == 5) && global.play_mode == 0
			&& !variable_struct_exists(global.save_data, "immortal_start_cards_notice_given")
			&& array_length(global.save_data.completed_levels) == 0{
			show_notice("不朽难度奖励：15万金币 + 暖暖鸡 + 自选一张卡", 60)
			global.save_data.immortal_start_cards_notice_given = true
			save_file(global.save_slot)
		}
		// 切换到不朽难度时，新存档发放原有难度奖励。
		if (state == 5) && !variable_struct_exists(global.save_data, "immortal_bonus_given"){
			if array_length(global.save_data.completed_levels) == 0{
				global.save_data.player.gold += 150000
				show_notice("不朽难度奖励：+150,000 金币", 60)
			}
			global.save_data.immortal_bonus_given = true
			save_file(global.save_slot)
		}
		// 三选一：还没结算就当场弹窗（点完不朽当帧创建，不等下一帧 / 切房间）
		//   depth 用 GM 合法下限 -16000（旧值 -99999 超出 ±16000 范围）
		if (state == 5) && global.play_mode == 0 && immortal_pick_pending()
			&& !instance_exists(obj_immortal_pick){
			instance_create_depth(0, 0, -16000, obj_immortal_pick)
		}
	}
}
else{
	global.audio.play(snd_button,0,0)
	show_notice("无法在游戏中修改难度",60)
}
