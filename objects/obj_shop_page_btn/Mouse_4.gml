if not obj_shop_bg.is_submenu_opened{
	var _pg_flip = false;
	if btn_type == "prev"{
		if obj_shop_bg.current_page > 1{
			obj_shop_bg.current_page --
			_pg_flip = true;
		}
	}
	else if btn_type == "next"{
		if obj_shop_bg.current_page < obj_shop_bg.current_max_page{
			obj_shop_bg.current_page ++
			_pg_flip = true;
		}
	}
	global.audio.play(snd_button,0,0)
	var _pg_next = (btn_type == "next");
	with obj_shop_bg{
		shop_list_recharge()
		if (_pg_flip) {
			pg_dir = _pg_next ? 1 : -1;
			pg_switch = true;
			pg_t = ui_anim_on(2) ? 0 : -1;
		}
	}
}
