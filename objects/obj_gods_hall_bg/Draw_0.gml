draw_set_alpha(0.5);
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
draw_self();
var inv = global.save_data.inventory;
var amt = 0;

for (var i = 0; i < array_length(inv); i++)
{
    if (inv[i].id == "oracle_stone")
    {
        amt = inv[i].amount;
        break;
    }
}

draw_set_font(font_yuan);
draw_set_color(c_white);
draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
draw_text(1144, 909, string(global.save_data.player.gold));
draw_text(1367, 909, string(amt));

if (global.save_data.player.wish_count >= 25)
{
    draw_set_color(c_lime);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(639, 285, "保底：" + string(global.save_data.player.wish_count) + " / 25");
}
else
{
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(639, 285, "保底：" + string(global.save_data.player.wish_count) + " / 25");
}
