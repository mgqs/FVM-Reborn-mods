/// 交互：确认绑定 / 关闭 / Esc
t++;

if (msg_timer > 0) {
    msg_timer--;
    if (msg_timer == 0) {
        msg = "";
        copied = false;
    }
}

// 成功后的收尾：先让玩家看见"授权成功"，再自己关掉
if (closing > 0) {
    closing--;
    if (closing == 0) {
        instance_destroy();
    }
    exit;
}

// Esc 关闭：强制模式没有这条路（未授权不给走）
if (!mandatory && keyboard_check_pressed(vk_escape)) {
    instance_destroy();
    exit;
}

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
hover_ok   = point_in_rectangle(_mx, _my, btn_ok_x,  btn_y, btn_ok_x  + btn_w, btn_y + btn_h);
hover_no   = point_in_rectangle(_mx, _my, btn_no_x,  btn_y, btn_no_x  + btn_w, btn_y + btn_h);
hover_hwid = point_in_rectangle(_mx, _my, hwid_x,   hwid_y, hwid_x + hwid_w, hwid_y + hwid_h);

var _clicked = mouse_check_button_pressed(mb_left);

// 点识别码 → 复制到剪贴板，玩家直接去 QQ 粘贴
if (_clicked && hover_hwid) {
    clipboard_set_text(local_hwid);
    copied = true;
    msg = "识别码已复制，粘贴到 QQ 发给机器人";
    msg_ok = true;
    msg_timer = 180;
    exit;
}

// 「稍后再说」：强制模式下按钮已被移到屏幕外，这里再挡一道，防止有人靠改坐标绕过
if (!mandatory && _clicked && hover_no) {
    instance_destroy();
    exit;
}

// 回车等同点「确认绑定」
var _confirm = (_clicked && hover_ok) || keyboard_check_pressed(vk_enter);
if (!_confirm) {
    exit;
}

var _code = string_upper(string_trim(input_box.get_text()));
if (_code == "") {
    msg = "请先粘贴机器人发给你的授权码";
    msg_ok = false;
    msg_timer = 180;
    exit;
}

// auth_bind：0 成功 / 1 码无效 / 2 这个码属于别的机器 / 3 已授权但写盘失败
var _r = auth_bind(_code);
if (_r == 0) {
    msg = "授权成功，已绑定本机";
    msg_ok = true;
    closing = 75;
    input_box.blur();
} else if (_r == 3) {
    // 会话里已经授权了，能继续玩；只是记录没落盘，下次启动会再问一次。
    // 必须说出来，否则玩家会以为「每次开机都要重新授权」是 bug。
    msg = "已授权，但本地记录写入失败（下次启动可能要重新输入）";
    msg_ok = false;
    closing = 90;
    input_box.blur();
} else if (_r == 2) {
    msg = "这个码是给另一台机器的，请用本机识别码重新领取";
    msg_ok = false;
    msg_timer = 240;
} else {
    msg = "授权码无效：检查是否完整复制（中间的连字符也要）";
    msg_ok = false;
    msg_timer = 210;
}
