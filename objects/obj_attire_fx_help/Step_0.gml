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
        var _tbl = attire_fx_table();

        // ① 行尾「穿戴」按钮优先（2026-11-14）：三件齐了才动存档，缺件只提示
        var _row_hit = -1;
        for (var _ri = 0; _ri < array_length(_tbl); _ri++) {
            var _br = attire_fx_row_rect(_ri);
            if (point_in_rectangle(mouse_x, mouse_y, _br[0], _br[1], _br[2], _br[3])) {
                _row_hit = _ri;
                break;
            }
        }
        if (_row_hit != -1) {
            var _cfg = _tbl[_row_hit];
            var _res = attire_fx_wear(_cfg);
            global.audio.play(snd_button, 0, 0);
            if (_res == -1) {
                show_notice("缺少所需的套装或神器", 60);
            } else if (_res == 2) {
                show_notice("已穿戴 " + _cfg.name + "（宝石位已满，替换了最后一颗）", 60);
            } else {
                show_notice("已穿戴 " + _cfg.name, 60);
            }
            exit;
        }

        // ② 点「确定」或点面板外侧都关闭（同转职说明弹窗的手感）
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
