// obj_text_input 步事件
// 处理光标闪烁
cursor_timer++;
if (cursor_timer >= cursor_blink_rate) {
    cursor_visible = !cursor_visible;
    cursor_timer = 0;
}

// 如果输入框处于活动状态，检查键盘输入
if (active) {
    // 检查退格键
    if (keyboard_check_pressed(vk_backspace)) {
        if (string_length(text) > 0) {
            text = string_copy(text, 1, string_length(text) - 1);
        }
    }
    
    // 检查回车键（确认输入）
    if (keyboard_check_pressed(vk_enter)) {
        active = false;   // 失焦后的输入法恢复由 obj_file_manager 统一处理
    }
	
}

