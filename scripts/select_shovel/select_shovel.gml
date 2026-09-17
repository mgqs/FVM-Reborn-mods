// 函数: 选择铲子
function select_shovel() {
    is_selected = true;
    
    // 取消任何选中的植物卡槽
    if (global.selected_slot != noone) {
        global.selected_slot.is_selected = false;
        if (instance_exists(global.selected_slot.selected_preview)) {
            instance_destroy(global.selected_slot.selected_preview);
        }
        global.selected_slot.selected_preview = noone;
    }
    
    // 设置全局选中为铲子
    global.selected_slot = noone;
    
    // 改变鼠标光标为铲子
    //cursor_sprite = spr_shovel_cursor;
}