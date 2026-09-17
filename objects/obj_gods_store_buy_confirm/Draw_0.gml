if (!instance_exists(obj_pause_menu))
{
    draw_set_alpha(0.5);
    draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
    draw_set_alpha(1);
}

draw_sprite_ext(bg, 0, x, y, 1.5, 1.5, 0, c_white, 1);
draw_set_font(font_yuan);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_text(x, y - 112, "兑换确认");
draw_text(x, y - 25, "确定消耗      个       ");
draw_set_color(c_yellow);
draw_text(x + 12, y - 27, string(banding_buy_btn.cost));
draw_sprite_ext(spr_gods_hall_reward, 1, x + 76, y - 25, 0.8, 0.8, 0, c_white, 1);
draw_set_color(c_white);
draw_text(x, y + 5, "兑换" + banding_buy_btn.goods_name + "吗？");

for (var i = 0; i < array_length(buttons); i++)
{
    var btn = buttons[i];
    var btn_x = x + btn[0];
    var btn_y = y + 70;
    var frame = 0;
    
    if (selected_button == i)
        frame = mouse_check_button_pressed(mb_left) ? 2 : 1;
    
    draw_sprite_ext(spr_common_button, frame, btn_x, btn_y, 0.75, 0.75, 0, c_white, 1);
    draw_set_font(font_yuan);
    draw_text(btn_x, btn_y, btn[1]);
}