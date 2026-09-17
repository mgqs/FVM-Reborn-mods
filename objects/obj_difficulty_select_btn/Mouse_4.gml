// 切换状态
if room != room_battle{
	if config_key == "difficulty"{
		if b_type == "next"{
			if state < 3{
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
				state = 3
			}
		}
	}
	audio_play_sound(snd_button,0,0)
	// 保存到配置文件
	if (config_key != "") {
	    ini_open("config.ini");
	    ini_write_real("settings", config_key, state);
	    ini_close();
	}

	if (config_key == "difficulty"){
		global.difficulty = state
	}
}
else{
	audio_play_sound(snd_button,0,0)
	show_notice("无法在游戏中修改难度",60)
}