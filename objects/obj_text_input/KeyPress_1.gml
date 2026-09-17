// obj_text_input 键盘按下事件
if (active) {
    // 获取按下的键
    var key = keyboard_key;
    var char = keyboard_lastchar;
	//show_debug_message(keyboard_lastchar)
    
    // 只处理可打印字符；v7.3 去掉 <=126 上限，以接收 IME 提交的中文
    // （控制字符仍被 ord(char) >= 32 挡掉）
    if (char != "" && ord(char) >= 32 && string_length(text) < max_length) {
        text += char;
    }
}