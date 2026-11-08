if not obj_tower_cake_bg.is_submenu_opened{
	// 2026-11-08：右下「本层解锁的转职凭证」的翻页（跟左上关卡列表的翻页互不影响）
	if btn_type == "credit_prev" or btn_type == "credit_next"{
		var _bgp = obj_tower_cake_bg
		if btn_type == "credit_prev" and _bgp.credit_page > 1{
			_bgp.credit_page --
			global.audio.play(snd_button,0,0)
			with (_bgp){ refresh_credit_grid() }
		}
		else if btn_type == "credit_next" and _bgp.credit_page < _bgp.credit_total_page{
			_bgp.credit_page ++
			global.audio.play(snd_button,0,0)
			with (_bgp){ refresh_credit_grid() }
		}
		exit
	}

	if btn_type == "prev"{
		if obj_tower_cake_bg.current_page > 1{
			obj_tower_cake_bg.current_page --
			obj_tower_cake_bg.level_select = -1
		}
	}
	else if btn_type == "next"{
		if obj_tower_cake_bg.current_page < obj_tower_cake_bg.total_page{
			obj_tower_cake_bg.current_page ++
			obj_tower_cake_bg.level_select = -1
		}
	}
	else if btn_type == "min"{
		obj_tower_cake_bg.current_page = 1
		obj_tower_cake_bg.level_select = -1
	}
	else if btn_type == "max"{
		obj_tower_cake_bg.current_page = obj_tower_cake_bg.total_page
		obj_tower_cake_bg.level_select = -1
	}
	global.audio.play(snd_button,0,0)
	instance_destroy(obj_tower_cake_card_reward)
	with obj_tower_cake_bg{
		global.tower_cake_page = current_page
		refresh_level_button()
		clear_credit_grid()
	}
	
}
