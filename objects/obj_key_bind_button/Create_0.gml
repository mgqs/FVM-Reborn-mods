// 按钮属性
image_speed = 0
image_xscale = 0.7
image_yscale = 0.7
key_name = ""; // 快捷键名称（由创建者设置）
default_key = -1; // 默认键值
current_key = -1; // 当前键值
is_waiting = false; // 是否等待输入
display_text = ""; // 显示的文本
tooltip_text = ""; // 悬停提示文本

// 初始化文本
update_text();

/// @function update_text()
// 更新显示文本
function update_text(){
	if (current_key != -1) {
	    display_text = keyboard_get_string(current_key);
	} else {
	    display_text = "未绑定";
	}
}