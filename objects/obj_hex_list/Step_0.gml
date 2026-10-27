if (!hex_active()) {
    instance_destroy();
    exit;
}

var _list_h    = array_length(rows) * item_h;
var _max_scroll = max(0, _list_h - view_h);

// ── 滚轮：只在列表区域内生效，一格 = 3 项 ──
var _in_view = point_in_rectangle(mouse_x, mouse_y, view_x, view_y, view_x + view_w, view_y + view_h);
if (_in_view) {
    if (mouse_wheel_up())   scroll_target -= item_h * 3;
    if (mouse_wheel_down()) scroll_target += item_h * 3;
}
scroll_target = clamp(scroll_target, 0, _max_scroll);

// ── 缓动：事件只改目标值，Step 里追，避免某些鼠标一次点击触发两帧事件导致"滚一格跳两格" ──
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

// ── 页签（点击区与 Draw 共用 Create 里的 tab_* 几何）──
tab_hover_0 = point_in_rectangle(mouse_x, mouse_y, tab_x0, tab_y0, tab_x0 + tab_w, tab_y1);
tab_hover_1 = point_in_rectangle(mouse_x, mouse_y, tab_x1, tab_y0, tab_x1 + tab_w, tab_y1);
if (mouse_check_button_pressed(mb_left) && (tab_hover_0 || tab_hover_1)) {
    var _new = tab_hover_0 ? 0 : 1;
    if (_new != tab) {
        tab = _new;
        hex_list_build();
        audio_play_sound(snd_button, 0, 0);
    }
}

// ── 滚动条拖拽 ──
var _bar_x = view_x + view_w + 6;
if (mouse_check_button_pressed(mb_left)
    && point_in_rectangle(mouse_x, mouse_y, _bar_x - 4, view_y, _bar_x + 8, view_y + view_h)) {
    bar_drag = true;
    bar_drag_off = mouse_y - view_y;
}
if (bar_drag) {
    if (mouse_check_button(mb_left)) {
        if (_max_scroll > 0) {
            var _ratio = (mouse_y - view_y) / view_h;
            scroll_target = clamp(_ratio * _list_h - view_h * 0.5, 0, _max_scroll);
            scroll_y = scroll_target;   // 拖动全程跟手，不缓动
        }
    } else {
        bar_drag = false;
    }
}
