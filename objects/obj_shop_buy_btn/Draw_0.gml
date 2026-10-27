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
		// 威望价（2026-10-26 用户口径，第三版）：照原版参考图 —— **白字 + 黑描边 + 加粗**
		//   工程里没有 bold 字体（font_yuan/所有字体 bold=false），所以：
		//   ① 加粗 = 白字右移 0.7px 再画一遍；② 描边 = 先按 8 方向各偏移 1px 画黑字
		//   一行写「100威望」，数字和「威望」同色（用户要求）
		var _ptxt = string(cost) + "威望"
		var _pts = 1.15                      // 字号：价格槽高 43px（sprite 24×1.8），16×1.15 ≈ 18.4 正好
		draw_set_font(font_yuan)
		draw_set_halign(fa_center)
		draw_set_valign(fa_middle)
		draw_set_colour(c_black)
		for (var _oy = -1; _oy <= 1; _oy++) {
			for (var _ox = -1; _ox <= 1; _ox++) {
				if (_ox == 0 && _oy == 0) continue
				draw_text_transformed(x + _ox, y - 62 + _oy, _ptxt, _pts, _pts, 0)
			}
		}
		draw_set_colour(c_white)
		draw_text_transformed(x, y - 62, _ptxt, _pts, _pts, 0)
		draw_text_transformed(x + 0.7, y - 62, _ptxt, _pts, _pts, 0)   // 模拟加粗
	}
	else{
		draw_text(x,y-62,string(cost)+"G")
	}
}
// 爬塔门槛小字（2026-10-26 用户改口径）
//   文案 = 「通过X-X层可买」（原来是「需通关X-X」）
//   颜色 = 黑色（原来白字 + 黑描边，在粉色底板上反而糊）
//   字号 1.5 → 1.1、中心从 y+6 上移到 y-6：原来贴着格子底边、还被格子裁掉一截
//   配合 obj_shop_bg 把凭证从 110 缩到 96 并上移 12px，字就不会压到凭证了
if (btn_type == "credit"){
	// 门槛 key 在 obj_shop_bg 建按钮时就算好了（凭证 = 卡+档位，兑换项 = credit_shape 默认表）
	// 没有这个变量时退回老算法（只对凭证有效）
	var _fkey = 0
	if (variable_instance_exists(id, "credit_floor_key")) {
		_fkey = credit_floor_key
	}
	else {
		var _cpd = transfer_credit_parse(target_item)
		if (!is_undefined(_cpd)) _fkey = transfer_credit_tower_floor_req(_cpd.card_id, _cpd.shape)
	}
	if (_fkey > 0){
		var _ftxt = "通过" + transfer_credit_tower_key_text(_fkey) + "层可买"
		var _fsc = 1.2                         // 门槛小字缩放（用户 2026-10-26：再大一点点）
		draw_set_font(font_pixel)
		draw_set_halign(fa_center)
		draw_set_valign(fa_middle)
		draw_set_colour(c_black)
		draw_text_transformed(x - 199, y - 4, _ftxt, _fsc, _fsc, 0)
		draw_set_halign(fa_left)
		draw_set_valign(fa_top)
		draw_set_colour(c_white)
	}
}

tooltip = false
draw_set_alpha(1)
