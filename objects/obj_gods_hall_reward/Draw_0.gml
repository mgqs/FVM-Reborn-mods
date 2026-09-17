draw_self();

if (hovered)
{
    var tooltip_x = mouse_x + 15;
    var tooltip_y = mouse_y + 15;
    var tooltip_text = string(reward_id[0]) + "x" + string(reward_id[1]);
    draw_set_color(c_black);
    draw_set_alpha(0.7);
    draw_rectangle(tooltip_x - 5, tooltip_y - 5, tooltip_x + string_width(tooltip_text) + 5, tooltip_y + string_height(tooltip_text) + 5, false);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text(tooltip_x, tooltip_y, tooltip_text);
}
