/// 悬停 + 点击开窗
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

hover = point_in_rectangle(_mx, _my, x, y, x + btn_w, y + btn_h);

if (!hover) {
    exit;
}
if (!mouse_check_button_pressed(mb_left)) {
    exit;
}
if (instance_exists(obj_auth_gate)) {
    exit;
}

global.audio.play(snd_button, 0, 0);
instance_create_depth(0, 0, -9500, obj_auth_gate);
