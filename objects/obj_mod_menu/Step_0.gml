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
        var extension = string_lower(filename_ext(selected));
        if (extension != ".zip" && extension != ".fvmmod") {
            notify_result("请选择 ZIP 或 .fvmmod 压缩包");
            exit;
        }
        var base_name = filename_name(selected);
        base_name = string_copy(base_name, 1, string_length(base_name) - string_length(extension));
        if (base_name == "" || base_name == "." || base_name == "..") {
            notify_result("压缩包名称无效");
            exit;
        }
        var target = mod_root + "\\" + base_name;
        if (native_folder_exists(target)) target += "_" + string(current_time);
        directory_create(target);
        var code = native_unzip_map_file(selected, target);
        if (code == 0) {
            try {
                var pack = external_mod_validate(target);
                var imported_ids = {};
                for (var c = 0; c < array_length(pack.cards); c++) imported_ids[$ pack.cards[c].id] = true;
                // Compare with installed packages, including disabled ones.
                for (var m = 0; m < array_length(mods); m++) {
                    var existing_pack;
                    try { existing_pack = external_mod_validate(mod_root + "/" + mods[m].folder); }
                    catch (_invalid_existing) { continue; }
                    for (var c = 0; c < array_length(existing_pack.cards); c++) {
                        if (variable_struct_exists(imported_ids, existing_pack.cards[c].id)) throw "已安装同 ID 卡片：" + existing_pack.cards[c].id;
                    }
                }
                refresh_mods();
                for (var imported_index = 0; imported_index < array_length(mods); imported_index++) {
                    if (mods[imported_index].folder == filename_name(target)) mods[imported_index].enabled = true;
                }
                if (save_state()) notify_result("已导入并开启：" + pack.name + "\n请完全退出并重新启动游戏，卡片才会加入背包、情报岛和选卡界面。");
                else notify_result("压缩包已解压，但开启状态保存失败，请检查目录权限。");
            } catch (_validation_error) {
                native_delete_folder(target);
                notify_result("Mod 校验失败：" + external_mod_error_text(_validation_error));
            }
        } else {
            native_delete_folder(target);
            notify_result("解压失败，错误码：" + string(code));
        }
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
            notify_result("上次启动时加载失败：" + mods[i].name + "\n" + global.external_mod_errors[$ mods[i].folder] + "\n修正文件后请重新启动游戏。");
        }
        exit;
    }
    if (point_in_rectangle(mouse_x, mouse_y, x + 245, row_y - 17, x + 325, row_y + 17) && mouse_check_button_pressed(mb_left)) {
        if (!mods[i].enabled) {
            try { external_mod_validate(mod_root + "/" + mods[i].folder); }
            catch (_enable_error) {
                notify_result("无法开启：" + external_mod_error_text(_enable_error));
                exit;
            }
        }
        mods[i].enabled = !mods[i].enabled;
        if (!save_state()) mods[i].enabled = !mods[i].enabled;
        else status_text = (mods[i].enabled ? "已开启：" : "已关闭：") + mods[i].name + "，重启游戏后生效";
        audio_play_sound(snd_button, 0, 0);
    }
    if (point_in_rectangle(mouse_x, mouse_y, x + 335, row_y - 17, x + 415, row_y + 17) && mouse_check_button_pressed(mb_left)) {
        var delete_code = native_delete_folder(mod_root + "\\" + mods[i].folder);
        if (delete_code == 0) {
            status_text = "已删除：" + mods[i].name + "，重启后生效；保留卡片进度";
            refresh_mods();
        } else {
            status_text = "删除失败，错误码：" + string(delete_code);
        }
        audio_play_sound(snd_button, 0, 0);
        break;
    }
}
