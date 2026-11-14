var import_job = global.external_mod_import_job;
if (is_struct(import_job) && !import_job.done && import_job.owner != id) {
    if (point_in_rectangle(mouse_x, mouse_y, x + 405, y - 305, x + 465, y - 270) && mouse_check_button_pressed(mb_left)) close_panel();
    exit;
}
if (is_struct(import_job) && import_job.owner == id) {
    if (import_job.done) {
        if (import_job.phase == "complete") {
            mods = import_job.next_entries;
            state_read_failed = false;
            state_default_enabled = true;
            if (external_mod_field(import_job, "operation", "import") == "import") refresh_mods(false);
            else scroll_offset = clamp(scroll_offset, 0, max(0, array_length(mods) * row_height - (list_bottom - list_top)));
        }
        global.external_mod_import_job = undefined;
        if (import_close_when_done) { close_panel(); exit; }
        if (import_job.phase == "cancelled") status_text = import_job.message;
        else if (import_job.phase == "complete" && external_mod_field(import_job, "operation", "import") != "import" && !external_mod_field(import_job, "warning", false)) status_text = import_job.message;
        else notify_result(import_job.message);
    } else {
        if (mouse_check_button_pressed(mb_left)) {
            if (point_in_rectangle(mouse_x, mouse_y, x + 405, y - 305, x + 465, y - 270)) {
                import_close_when_done = true;
                external_mod_import_cancel();
            } else if (point_in_rectangle(mouse_x, mouse_y, x - 78, y + 83, x + 78, y + 123)) {
                external_mod_import_cancel();
            }
        }
        exit;
    }
}

if (mouse_wheel_up()) scroll_offset = max(0, scroll_offset - row_height);
if (mouse_wheel_down()) scroll_offset = min(max(0, array_length(mods) * row_height - (list_bottom - list_top)), scroll_offset + row_height);

var content_height = list_bottom - list_top;
var total_height = max(content_height, array_length(mods) * row_height);
var thumb_height = max(35, content_height * content_height / total_height);
var thumb_max_y = list_bottom - thumb_height;
if (mouse_check_button_pressed(mb_left) && point_in_rectangle(mouse_x, mouse_y, x + 430, list_top, x + 440, list_bottom)) {
    dragging_scroll = true;
    drag_scroll_offset = mouse_y - (list_top + (content_height - thumb_height) * (scroll_offset / max(1, total_height - content_height)));
}
if (!mouse_check_button(mb_left)) dragging_scroll = false;
if (dragging_scroll) {
    var thumb_y = clamp(mouse_y - drag_scroll_offset, list_top, thumb_max_y);
    scroll_offset = ((thumb_y - list_top) / max(1, thumb_max_y - list_top)) * max(0, total_height - content_height);
}

if (point_in_rectangle(mouse_x, mouse_y, x + 405, y - 305, x + 465, y - 270) && mouse_check_button_pressed(mb_left)) {
    close_panel();
    exit;
}

if (point_in_rectangle(mouse_x, mouse_y, x - 420, y - 305, x - 245, y - 270) && mouse_check_button_pressed(mb_left)) {
    var selected = get_open_filename("Mod package|*.fvmmod;*.zip|All files|*.*", "");
    if (selected != "") {
        try { external_mod_import_start(selected, self); }
        catch (import_error) { notify_result(external_mod_error_text(import_error)); }
    }
    exit;
}

if (point_in_rectangle(mouse_x, mouse_y, x - 230, y - 305, x - 35, y - 270) && mouse_check_button_pressed(mb_left)) {
    var open_code = native_open_folder(mod_root);
    if (open_code != 0) status_text = "打开目录失败，错误码：" + string(open_code);
}

for (var i = 0; i < array_length(mods); i++) {
    var row_y = list_top + i * row_height - scroll_offset + 26;
    if (row_y - 25 < list_top || row_y + 25 > list_bottom) continue;
    if (point_in_rectangle(mouse_x, mouse_y, x - 430, row_y - 25, x + 235, row_y + 25) && mouse_check_button_pressed(mb_left)) {
        if (variable_global_exists("external_mod_errors") && variable_struct_exists(global.external_mod_errors, mods[i].folder)) {
            notify_result("Mod 运行或加载时发现问题：" + mods[i].name + "\n" + global.external_mod_errors[$ mods[i].folder] + "\n修正文件后请重新启动游戏。");
        }
        exit;
    }
    if (point_in_rectangle(mouse_x, mouse_y, x + 245, row_y - 17, x + 325, row_y + 17) && mouse_check_button_pressed(mb_left)) {
        try { external_mod_manage_start(mods[i].enabled ? "disable" : "enable", self, i); }
        catch (manage_error) { notify_result(external_mod_error_text(manage_error)); }
        audio_play_sound(snd_button, 0, 0);
    }
    if (point_in_rectangle(mouse_x, mouse_y, x + 335, row_y - 17, x + 415, row_y + 17) && mouse_check_button_pressed(mb_left)) {
        try { external_mod_manage_start("delete", self, i); }
        catch (manage_error) { notify_result(external_mod_error_text(manage_error)); }
        audio_play_sound(snd_button, 0, 0);
        break;
    }
}
