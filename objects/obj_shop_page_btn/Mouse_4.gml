if not obj_shop_bg.is_submenu_opened{
	if btn_type == "prev"{
		if obj_shop_bg.current_page > 1{
			obj_shop_bg.current_page --
		}
	}
	else if btn_type == "next"{
		if obj_shop_bg.current_page < obj_shop_bg.current_max_page{
			obj_shop_bg.current_page ++
		}
	}
	audio_play_sound(snd_button,0,0)
	with obj_shop_bg{
		shop_list_recharge()
	}
}