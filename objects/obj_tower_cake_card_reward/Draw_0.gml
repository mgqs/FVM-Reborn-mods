draw_self()

draw_set_halign(fa_center)
draw_set_valign(fa_middle)

// ── 威望格（2026-10-27 起魔塔奖励全部是威望，不再有卡片）────────────────
if (reward_kind != ""){
	// ① 图标：落在底板画面区中央
	draw_sprite_ext(spr_prestige_icon, 0, x, y-10, 1.6, 1.6, 0, c_white, 1);
	// ② 数字：压在底板那条白条上（跟原来「阳光消耗」同一行，黑字）
	draw_set_font(font_number)
	draw_set_colour(c_black)
	draw_text(x, y+43, string(prestige_amount));
	// ③ 首通 / 次通：原来「点击领取」那一行
	draw_set_font(font_yuan)
	draw_set_colour(c_white)
	draw_text(x, y+83, (reward_kind == "first") ? "首通" : "次通");

	if (dimmed){
		draw_set_alpha(0.5)
		draw_set_colour(c_black)
		draw_rectangle(x-sprite_width/2, y-sprite_height/2, x+sprite_width/2, y+sprite_height/2, 0)
		draw_set_alpha(1)
	}
	else if (on_click){
		draw_set_alpha(0.5)
		draw_set_colour(c_white)
		draw_rectangle(x-sprite_width/2, y-sprite_height/2, x+sprite_width/2, y+sprite_height/2, 0)
		draw_set_alpha(1)
	}

	// 悬停提示
	if (on_click){
		var _tooltip = ((reward_kind == "first") ? "首通奖励：" : "重复通关奖励：")
			+ string(prestige_amount) + " 威望"
			+ (dimmed ? "\n（首通威望已发放）" : "\n通关后自动发放");
		var tooltip_x = mouse_x - 15;
		var tooltip_y = mouse_y - 15;
		draw_set_font(font_yuan)
		draw_set_color(c_black)
		draw_set_alpha(0.7)
		draw_rectangle(tooltip_x - string_width(_tooltip) - 5, tooltip_y - 5,
		               tooltip_x + 5, tooltip_y + string_height(_tooltip) + 5, false)
		draw_set_halign(fa_left)
		draw_set_valign(fa_top)
		draw_set_alpha(1)
		draw_set_color(c_white)
		draw_text(tooltip_x - string_width(_tooltip), tooltip_y, _tooltip)
	}

	draw_set_colour(c_white)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	exit
}

// ── 旧「卡片奖励」绘制：塔关已经不再有卡奖励，留着兜底（万一还有带 card_id 的关）──
var card_data = deck_get_card_data(target_card_id,target_shape)
var card_name = "点击领取"//get_plant_shape_data(target_card_id,target_shape)[? "name"]

// 抽卡模式：形态奖励禁用
var gacha_disabled = is_eternal_gacha_mode();
if (gacha_disabled) {
	card_name = "随机奖励";
}

draw_set_colour(c_white)
draw_set_font(font_yuan)

if (gacha_disabled) {
	draw_sprite_ext(spr_lihe, 0, x, y+25, 0.5, 0.5, 0, c_gray, 1);
} else {
	draw_sprite_ext(card_data[? "sprite"],0,x,y+25,1,1,0,c_white,1);
}
draw_text(x,y+83,card_name)

// 绘制价格
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_set_color(c_black);
draw_set_font(font_number);
draw_text_ext_transformed(x-12, y+44, string(card_data[? "cost"]),25,1800,1,1,0);
draw_sprite_ext(spr_flame, 0, x-24, y+43, 0.3, 0.3, 0, c_white, 1);
draw_set_font(font_yuan)

if dimmed{
	draw_set_alpha(0.5)
	draw_set_colour(c_black)
	draw_rectangle(x-sprite_width/2,y-sprite_height/2,x+sprite_width/2,y+sprite_height/2,0)
	draw_set_alpha(1)
}
else if on_click{
	draw_set_alpha(0.5)
	draw_set_colour(c_white)
	draw_rectangle(x-sprite_width/2,y-sprite_height/2,x+sprite_width/2,y+sprite_height/2,0)
	draw_set_alpha(1)
}

//显示悬停提示
if on_click {
	// 获取鼠标位置
	var tooltip_x = mouse_x - 15;
	var tooltip_y = mouse_y - 15;

	// 获取提示文本

	var tooltip_text = ""

	tooltip_text = card_data[? "description"]

	// 绘制提示背景
	draw_set_font(font_yuan)
	draw_set_color(c_black);
	draw_set_alpha(0.7);
	draw_rectangle(tooltip_x - string_width(tooltip_text) - 5, tooltip_y - 5,
	                tooltip_x +5, tooltip_y + string_height(tooltip_text)+5, false);
	//绘制提示文本
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_text(tooltip_x- string_width(tooltip_text), tooltip_y, tooltip_text);
}
