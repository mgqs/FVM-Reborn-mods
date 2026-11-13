// 角色信息栏「变装特效」按钮（2026-11-13）
// 只在「角色信息」页（info_button_select == 1）显示，其它页签自动隐藏并关掉弹窗

var _panel = instance_find(obj_package_bg, 0);
visible = instance_exists(_panel) && _panel.info_button_select == 1;
if (!visible) {
    open = false;
    global.attire_fx_help_open = false;
    exit;
}

hover = point_in_rectangle(mouse_x, mouse_y,
    x - btn_half_w, y - btn_half_h, x + btn_half_w, y + btn_half_h);

if (open) {
    // 弹窗开着时每帧刷新「刚关掉」的余量，让底下面板的同帧点击也被吃掉
    global.attire_fx_help_latch = 2;
    if (mouse_check_button_pressed(mb_left)) {
        var _pr = attire_fx_panel_rect();
        var _cr = attire_fx_confirm_rect();
        var _on_confirm = point_in_rectangle(mouse_x, mouse_y, _cr[0], _cr[1], _cr[2], _cr[3]);
        var _in_panel = point_in_rectangle(mouse_x, mouse_y, _pr[0], _pr[1], _pr[2], _pr[3]);
        // 点「确定」或点面板外侧都关闭（同转职说明弹窗的手感）
        if (_on_confirm || !_in_panel) {
            global.audio.play(snd_button, 0, 0);
            open = false;
            global.attire_fx_help_open = false;
        }
    }
    exit;
}

if (mouse_check_button_pressed(mb_left) && hover) {
    global.audio.play(snd_button, 0, 0);
    open = true;
    global.attire_fx_help_open = true;
}
