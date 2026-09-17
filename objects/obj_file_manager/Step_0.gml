if global.lose_focus_pause{
	if !window_has_focus(){
		audio_pause_all()
		audio_pause = true
	}
	else{
		if audio_pause{
			audio_resume_all()
			audio_pause = false
		}
	}
}

// 输入法屏蔽心跳（obj_file_manager 是持久对象，跨房间存活）
// v5 的心跳挂在 obj_game_init 上，而它只在 room_init 存在且非持久 → 进游戏后循环就死了
if (!variable_instance_exists(id, "ime_tick")) {
    ime_tick = 0;
}
if (!variable_instance_exists(id, "ime_was_typing")) {
    ime_was_typing = false;
}

// v7.3：屏蔽按「游戏内输入框是否获得焦点」动态开关——获焦则放开（能打中文），否则屏蔽。
// 判定集中在这里：Mouse_53 是全局鼠标事件，多输入框时各实例执行顺序不确定，
// 若把 native_enable/disable 散在各实例里会互相覆盖（点 B 框被离开 A 框的分支关掉）。
var _ime_typing_count = 0;
with (obj_text_input) {
    if (active) _ime_typing_count += 1;
}
var _ime_typing = (_ime_typing_count > 0);

if (_ime_typing != ime_was_typing) {
    ime_was_typing = _ime_typing;
    if (_ime_typing) {
        // 获得焦点：放开输入法（摘子类化 + 杀定时器 + 挂回 HIMC）
        // 只在功能开启时才碰 IME：ime_block 关闭时从未屏蔽过，无需也不应改动窗口状态
        if (global.ime_block && native_enable_ime != undefined) {
            native_enable_ime(window_handle());
        }
    } else {
        // 失焦：立刻恢复屏蔽
        if (global.ime_block && native_disable_ime != undefined) {
            native_disable_ime(window_handle());
        }
    }
}

// 非输入状态每 60 帧重压一次，防止焦点事件把 IME 上下文挂回来
ime_tick++;
if (!_ime_typing && ime_tick >= 60) {
    ime_tick = 0;
    if (global.ime_block && native_disable_ime != undefined) {
        native_disable_ime(window_handle());
    }
}
