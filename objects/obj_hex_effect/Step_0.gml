/// obj_hex_effect Step —— 两栏共用一条滚动量 + 关闭

if (!hex_active()) {
    instance_destroy();
    exit;
}

var _list_h     = hex_effect_list_h();
var _max_scroll = max(0, _list_h - list_h);

// ── 滚轮：两栏都在面板内，任一栏上滚都生效 ──
if (point_in_rectangle(mouse_x, mouse_y, col_x0, list_y, col_x1 + col_w, list_y + list_h)) {
    if (mouse_wheel_up())   scroll_target -= item_h * 3;
    if (mouse_wheel_down()) scroll_target += item_h * 3;
}
scroll_target = clamp(scroll_target, 0, _max_scroll);

// ── 缓动：事件只改目标值，Step 里追 ──
scroll_y += (scroll_target - scroll_y) * 0.35;
if (abs(scroll_target - scroll_y) < 0.5) scroll_y = scroll_target;

// ── 键盘 ──
if (keyboard_check_pressed(vk_up))       scroll_target = max(0, scroll_target - item_h);
if (keyboard_check_pressed(vk_down))     scroll_target = min(_max_scroll, scroll_target + item_h);
if (keyboard_check_pressed(vk_pageup))   scroll_target = max(0, scroll_target - item_h * 5);
if (keyboard_check_pressed(vk_pagedown)) scroll_target = min(_max_scroll, scroll_target + item_h * 5);
if (keyboard_check_pressed(vk_escape)) {
    instance_destroy();
    exit;
}

// ── 关闭按钮 ──
close_hover = point_in_rectangle(mouse_x, mouse_y, px + w - 56, py + 16, px + w - 20, py + 52);
if (close_hover && mouse_check_button_pressed(mb_left)) {
    audio_play_sound(snd_button, 0, 0);
    instance_destroy();
    exit;
}

// ── 滚动条拖拽（只有一列滚动条，画在右栏外侧）──
var _bar_x = px + w - 14;
if (mouse_check_button_pressed(mb_left)
    && point_in_rectangle(mouse_x, mouse_y, _bar_x - 4, list_y, _bar_x + 10, list_y + list_h)) {
    drag = true;
    drag_off = mouse_y - list_y;
}
if (drag) {
    if (mouse_check_button(mb_left)) {
        if (_max_scroll > 0) {
            var _ratio = (mouse_y - list_y) / list_h;
            scroll_target = clamp(_ratio * _list_h - list_h * 0.5, 0, _max_scroll);
            scroll_y = scroll_target;
        }
    } else {
        drag = false;
    }
}
