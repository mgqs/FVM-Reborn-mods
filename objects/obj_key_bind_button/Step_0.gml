// 如果正在等待输入，则检查按键
if (is_waiting) {
    var key = keyboard_key;
    if (key != 0) {
        // 保存新键值
        current_key = key;
        is_waiting = false;
        update_text();
        
        // 保存到配置文件
        ini_open("config.ini");
        ini_write_real("keybinds", key_name, current_key);
        ini_close();
        
        // 更新全局键位映射
        global.keybind_map[? key_name] = current_key;
    }
}