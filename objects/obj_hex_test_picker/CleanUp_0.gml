/// CleanUp —— 展开状态下被销毁（换关 / 战斗结束 / 面板被外部清掉）
/// 必须把暂停还回去，否则下一关就是「一开始就暂停、屏幕上还没有任何 UI」的死局
if (paused_by_me) {
    global.is_paused = prev_paused;
    paused_by_me     = false;
}
global.hex_picker_open = false;

// 搜索框是独立实例，跟着一起销毁，别留在下一关继续吃键盘
if (variable_instance_exists(id, "search_box") && instance_exists(search_box)) {
    instance_destroy(search_box);
}
