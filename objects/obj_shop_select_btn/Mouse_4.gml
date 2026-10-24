if not obj_shop_bg.is_submenu_opened{
var _pg_changed = (obj_shop_bg.shop_button_select != button_index);
var _pg_dir = (button_index > obj_shop_bg.shop_button_select) ? 1 : -1;
obj_shop_bg.shop_button_select = button_index
obj_shop_bg.current_page = 1
with obj_shop_bg{
	if (_pg_changed) {
		pg_dir = _pg_dir;
		pg_switch = true;
		pg_t = ui_anim_on(2) ? 0 : -1;
	}
	shop_list_recharge()
	}
global.audio.play(snd_button,0,0)
}
