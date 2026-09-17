if not obj_shop_bg.is_submenu_opened{

obj_shop_bg.shop_button_select = button_index
obj_shop_bg.current_page = 1
with obj_shop_bg{
		shop_list_recharge()
	}
audio_play_sound(snd_button,0,0)
}