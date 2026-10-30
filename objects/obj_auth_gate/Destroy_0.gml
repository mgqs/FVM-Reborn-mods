/// 关闭时收尾：解除点击拦截、恢复暂停
/// 注意：is_paused 只在本对象真的暂停过时才恢复，
///       别无条件置 false —— 海克斯面板等其它系统也在用同一个标志。

// 输入框是本对象创建的，不会跟着一起销毁
if (!is_undefined(input_box)) {
    if (instance_exists(input_box)) {
        instance_destroy(input_box);
    }
}

global.auth_gate_open = false;

if (did_pause && instance_exists(obj_battle)) {
    if (!instance_exists(obj_hex_panel)) {
        global.is_paused = false;
    }
}
