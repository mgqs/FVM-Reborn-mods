if global.is_paused{
	exit
}
if (global.enemy_hpbar && hp > 0) {
	draw_set_alpha(0.5)
	
    // 血条位置（在植物上方）
    var bar_x = x;
    var bar_y = y - 30;
    var bar_width = 80;
    var bar_height = 20;
    
    // 绘制血条背景（灰色）
    //draw_set_color(c_gray);
    //draw_rectangle(bar_x-bar_width/2, bar_y, bar_x + bar_width/2, bar_y + bar_height, false);
	draw_set_color(c_white);
    draw_rectangle(bar_x-bar_width/2, bar_y, bar_x + bar_width/2, bar_y + bar_height, true);
    
    // 计算血量比例
    var hp_ratio = hp / maxhp;
    hp_ratio = clamp(hp_ratio, 0, 1);
    
    // 绘制血条主体（绿色）
    draw_set_color(c_purple);
	
    draw_rectangle(bar_x-bar_width/2, bar_y, bar_x-bar_width/2 + bar_width * hp_ratio, bar_y + bar_height, false);
	
	if shield_hp > 0 && shield_max_hp != 0{
		 // 计算护盾比例
	    var shield_ratio = shield_hp / shield_max_hp;
	    shield_ratio = clamp(shield_ratio, 0, 1);
    
	    // 绘制护盾条主体（绿色）
	    draw_set_color(c_aqua);
	
	    draw_rectangle(bar_x-bar_width/2, bar_y, bar_x-bar_width/2 + bar_width * shield_ratio, bar_y + bar_height, false);
	}
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_set_font(font_yuan)
	draw_set_color(c_white)
	if shield_hp > 0{
		draw_set_colour(c_black)
	}
	draw_text(x,bar_y+9,string(hp))
	draw_set_alpha(1)
}