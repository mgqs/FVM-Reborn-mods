// obj_text_input 全局鼠标按下事件
// 检查是否点击了输入框
if (point_in_rectangle(mouse_x, mouse_y, x, y, x + width, y + height)) {
    active = true;
} else {
    active = false;
}
// 输入法的放开/恢复不在这里做：本事件是全局鼠标事件，多输入框时各实例执行顺序不确定，
// 统一由 obj_file_manager 的 Step 依据所有输入框的 active 状态处理（见那里的 v7.3 注释）。