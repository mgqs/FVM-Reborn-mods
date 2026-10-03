// obj_gacha_drop - Draw Event
draw_self();

if (state == 0) {
    // 等待点击提示
    draw_set_font(font_yuan);
    draw_set_color(c_yellow);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(x, y + sprite_get_height(spr_lihe) / 2 + 30, "点击礼盒开启奖励");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
