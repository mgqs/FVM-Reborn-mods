if (is_disabled)
    image_blend = c_gray;

draw_self();
draw_set_font(font_yuan);
draw_set_color(c_black);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

if (btn_type == "card")
    draw_text(x, y - 106, goods_name);
else if (btn_type == "shape")
    draw_text_ext_transformed(x, y - 106, goods_name, 25, 1920, 0.9, 0.9, 0);

if (!is_disabled)
{
    draw_set_color(c_white);
    draw_text(x - 8, y - 58, "消耗" + string(cost) + "个");
    draw_sprite_ext(spr_gods_hall_reward, 1, x + 90, y - 59, 0.8, 0.8, 0, c_white, 1);
    
    if (point_in_rectangle(mouse_x, mouse_y, x - 280, y - 120, x - 120, y - 20))
        tooltip = true;
    else
        tooltip = false;
}
