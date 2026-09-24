// 半透明遮罩
draw_set_alpha(0.5)
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false)
draw_set_alpha(1)

// 背景
draw_sprite_ext(bg, 0, x, y, 1.5, 1.5, 0, c_white, 1)

// ===== 标题 =====
draw_set_font(font_yuan)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_color(c_white)
draw_text(x, y + layout_title_y, "出售材料")

// ===== 材料图标 =====
var _mat_spr = sell_material_spr
var _mat_idx = sell_material_icon
draw_sprite_ext(_mat_spr, _mat_idx, x + layout_icon_x, y + layout_icon_y, layout_icon_scale, layout_icon_scale, 0, c_white, 1)

// ===== 材料信息 =====
draw_set_halign(fa_left)
draw_set_valign(fa_middle)

// 材料名称
draw_set_color(c_white)
draw_text(x + layout_text_x, y + layout_name_y, sell_material_name)

// 持有数量
draw_set_color(c_yellow)
draw_text(x + layout_text_x, y + layout_amount_y, "持有：" + string(max_amount))

// 单价
draw_set_color(c_yellow)
draw_text(x + layout_text_x, y + layout_price_y, "单价：" + string(unit_price) + "G")

// ===== 出售数量输入区 =====
// 标签在输入框左侧
draw_set_halign(fa_right)
draw_set_valign(fa_middle)
draw_set_color(c_white)
draw_set_font(font_yuan)
draw_text(x - layout_input_w / 2 - 8, y + layout_input_y, "出售数量")

// 输入框背景
var _input_x = x - layout_input_w / 2
var _input_y = y + layout_input_y - layout_input_h / 2

draw_set_color(c_dkgray)
draw_rectangle(_input_x, _input_y, _input_x + layout_input_w, _input_y + layout_input_h, false)
draw_set_color(c_white)
draw_rectangle(_input_x, _input_y, _input_x + layout_input_w, _input_y + layout_input_h, true)

// 输入框文字
var _display_text = string(input_quantity)
if (keyboard_string == "" || input_quantity == 0) {
    _display_text = ""
}
var _cursor = (cursor_blink < 30) ? "|" : " "
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_font(font_number)
draw_text(x, y + layout_input_y, _display_text + _cursor)

// ===== 总计金额 =====
draw_set_font(font_yuan)
draw_set_color(c_yellow)
var _total = input_quantity * unit_price
draw_text(x, y + layout_total_y, "总计：" + string(_total) + "G")

// ===== 按钮 =====
for (var i = 0; i < array_length(buttons); i++) {
    var btn = buttons[i]
    var btn_x = x + btn[0]
    var btn_y = y + layout_btn_y

    var frame = 0
    if (selected_button == i) {
        frame = (mouse_check_button_pressed(mb_left)) ? 2 : 1
    }

    // 确定按钮是否可用
    var _can_click = true
    if (i == 1 && (input_quantity <= 0 || input_quantity > max_amount || max_amount <= 0)) {
        _can_click = false
    }

    // 按钮背景
    draw_sprite_ext(spr_common_button, frame, btn_x, btn_y, 0.65, 0.65, 0, c_white, 1)

    // 按钮文字
    draw_set_font(font_yuan)
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    if (_can_click) {
        draw_set_color(c_white)
    } else {
        draw_set_color(c_gray)
    }
    draw_text(btn_x, btn_y, btn[1])
}

// 重置绘制状态
draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_white)
draw_set_alpha(1)
