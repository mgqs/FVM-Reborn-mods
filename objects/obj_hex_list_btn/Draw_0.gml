draw_set_font(font_yuan);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_set_color(hovered ? #D9F3FF : #9DCFEC);
draw_roundrect(x - 105, y - 24, x + 105, y + 24, false);
draw_set_color(#17314C);
draw_text(x, y, label);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
