var gacha_card_disabled = (btn_type == "card" && (is_eternal_gacha_mode() || is_random_gift_mode()));
var gacha_weapon_disabled = (btn_type == "weapon" && is_eternal_gacha_mode() && gacha_is_mod_weapon(target_item));
var gacha_gem_disabled = (btn_type == "gem" && is_eternal_gacha_mode() && gacha_is_mod_gem(target_item));
if is_disabled || gacha_card_disabled || gacha_weapon_disabled || gacha_gem_disabled{
	image_blend = c_gray
}
if btn_type == "attire" && is_attire_owned{
	draw_sprite_ext(spr_common_button,image_index,x,y,
		 1.0, 1.0,
		 0,is_disabled ? c_gray : c_white,1)
	draw_set_font(font_yuan)
	draw_set_color(c_white)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_text_transformed(x,y,is_attire_equipped ? "已穿戴" : "穿戴",0.9,0.9,0)
}
else{
	draw_self()
}
draw_set_font(font_yuan)
draw_set_color(c_black)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_text(x,y-110,goods_name)
draw_set_font(font_number)
if not is_disabled && not is_attire_owned{
	draw_set_color(c_yellow)
	draw_text(x,y-62,string(cost)+"G")
	if point_in_rectangle(mouse_x,mouse_y,x-280,y-120,x-120,y-20){
		tooltip = true
	}
	else{
		tooltip = false
	}
}
