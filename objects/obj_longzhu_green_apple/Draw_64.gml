/// 青苹果血条：沿用 obj_enemy_parent / obj_card_parent 的绘制样式
if (global.is_paused) exit;
if (hp <= 0 || longzhu_action == "消失") exit;

draw_set_alpha(0.5);

var bar_x = x;
var bar_y = y - 30;
var bar_width = 80;
var bar_height = 20;

// 边框（白色空心）
draw_set_color(c_white);
draw_rectangle(bar_x - bar_width / 2, bar_y, bar_x + bar_width / 2, bar_y + bar_height, true);

// 血量比例
var hp_ratio = clamp(hp / max_hp, 0, 1);

// 主体（紫色填充）
draw_set_color(c_purple);
draw_rectangle(bar_x - bar_width / 2, bar_y, bar_x - bar_width / 2 + bar_width * hp_ratio, bar_y + bar_height, false);

// 数字
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(font_yuan);
draw_set_color(c_white);
draw_text(x, bar_y + 9, string(hp));

draw_set_alpha(1);
