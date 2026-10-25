var _page_alpha = (instance_exists(obj_shop_bg)) ? obj_shop_bg.pg_alpha : 1;
draw_set_alpha(_page_alpha);
var gacha_card_disabled = (btn_type == "card" && (is_eternal_gacha_mode() || is_random_gift_mode()));
var gacha_weapon_disabled = (btn_type == "weapon" && is_eternal_gacha_mode() && gacha_is_mod_weapon(target_item));
var gacha_gem_disabled = (btn_type == "gem" && is_eternal_gacha_mode() && gacha_is_mod_gem(target_item));
if is_disabled || gacha_card_disabled || gacha_weapon_disabled || gacha_gem_disabled{
	image_blend = c_gray
}
if btn_type == "attire" && is_attire_owned{
	draw_sprite_ext(spr_common_button,image_index,x,y,
		 1.0, 1.0,
		 0,is_disabled ? c_gray : c_white,ui_anim_alpha(id))
	draw_set_font(font_yuan)
	draw_set_color(c_white)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_text_transformed(x,y,is_attire_equipped ? "已穿戴" : "穿戴",0.9,0.9,0)
}
else{
	draw_self()
}
draw_set_alpha(_page_alpha * ui_anim_alpha(id));
draw_set_font(font_yuan)
draw_set_color(c_black)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_text(x,y-110,goods_name)
draw_set_font(font_number)
if not is_disabled && not is_attire_owned{
	draw_set_color(c_yellow)
	if (btn_type == "credit" && coin_type == "prestige"){
		// 威望价：数字 + 左侧小图标（金币页仍走下面的 xxxG）
		draw_text(x + 18, y-62, string(cost))
		draw_sprite_ext(spr_prestige_icon, 0, x - 26, y-62, 0.7, 0.7, 0, c_white, 1)
	}
	else{
		draw_text(x,y-62,string(cost)+"G")
	}
}
// 爬塔门槛小字（2026-10-26 用户要求）：凭证图标下方写一行「需通关12-2」，无门槛不写
// 字体用 font_pixel（原版像素味，用户 2026-10-26：别换字体，只是太小）→ 靠 draw_text_transformed 放大
// 2.0 是整数倍，像素字体放大不发虚；坐标：图标中心 (-199,-60)、图标 110px（底边 y-5），中心放 y+6
if (btn_type == "credit"){
	var _cpd = transfer_credit_parse(target_item)
	if (!is_undefined(_cpd)){
		var _fkey = transfer_credit_tower_floor_req(_cpd.card_id, _cpd.shape)
		if (_fkey > 0){
			var _ftxt = "需通关" + transfer_credit_tower_key_text(_fkey)
			var _fsc = 1.5
			draw_set_font(font_pixel)
			draw_set_halign(fa_center)
			draw_set_valign(fa_middle)
			draw_set_colour(c_black)
			draw_text_transformed(x - 199 + 1, y + 6 + 1, _ftxt, _fsc, _fsc, 0)
			draw_set_colour(c_white)
			draw_text_transformed(x - 199, y + 6, _ftxt, _fsc, _fsc, 0)
			draw_set_halign(fa_left)
			draw_set_valign(fa_top)
			draw_set_colour(c_white)
		}
	}
}

tooltip = false
draw_set_alpha(1)
