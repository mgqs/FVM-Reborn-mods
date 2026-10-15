mod_root = global.native_util.get_path_in_local_appdata("\\FVM_Reborn_makk\\mod");
if (!native_folder_exists(mod_root)) directory_create(mod_root);
state_path = mod_root + "\\mod_state.json";
scroll_offset = 0;
row_height = 58;
list_top = y - 205;
list_bottom = y + 205;
mods = [];
status_text = "";
notify_result = function(message) {
    status_text = message;
    show_message(message);
};
return_depth = depth + 10;
close_panel = function() {
    if (instance_exists(obj_player_info_ui)) obj_player_info_ui.menu_type = 2;
    var settings = instance_create_depth(x, y, return_depth, obj_config_menu);
    settings.button_select = 3;
    instance_destroy();
};
dragging_scroll = false;
drag_scroll_offset = 0;

load_state = function() {
    var result = [];
    if (!file_exists(state_path)) return result;
    var b = buffer_load(state_path);
    if (!buffer_exists(b)) return result;
    var raw = buffer_read(b, buffer_string);
    buffer_delete(b);
    try {
        var parsed = json_parse(raw);
        if (is_array(parsed)) {
            for (var i = 0; i < array_length(parsed); i++) {
                var entry = parsed[i];
                if (is_struct(entry) && variable_struct_exists(entry, "folder") && variable_struct_exists(entry, "enabled") && is_string(entry.folder) && is_bool(entry.enabled)) {
                    array_push(result, entry);
                }
            }
        }
    } catch (_error) {}
    return result;
};

save_state = function() {
    var f = file_text_open_write(state_path);
    if (f != -1) {
        file_text_write_string(f, json_stringify(mods));
        file_text_close(f);
        global.external_mods = mods;
        return true;
    }
    status_text = "无法保存 Mod 状态，请检查目录权限";
    return false;
};

manifest_name = function(folder_path, fallback) {
    var root;
    try { root = external_mod_root(folder_path); } catch (_missing_manifest) { return fallback; }
    var p = root + "\\manifest.json";
    if (!file_exists(p)) p = root + "\\card.json";
    if (!file_exists(p)) return fallback;
    var b = buffer_load(p);
    if (!buffer_exists(b)) return fallback;
    var raw = buffer_read(b, buffer_string);
    buffer_delete(b);
    try {
        var parsed = json_parse(raw);
        if (is_struct(parsed)) {
            if (variable_struct_exists(parsed, "name")) return string(parsed.name);
            if (variable_struct_exists(parsed, "id")) return string(parsed.id);
        }
    } catch (_error) {}
    return fallback;
};

refresh_mods = function() {
    var previous = mods;
    mods = [];
    // Collect names first: resolving an outer package directory also uses file_find.
    var folders = [];
    var folder = file_find_first(mod_root + "\\*", fa_directory);
    while (folder != "") {
        if (folder != "." && folder != ".." && directory_exists(mod_root + "\\" + folder)) {
            array_push(folders, folder);
        }
        folder = file_find_next();
    }
    file_find_close();
    for (var f = 0; f < array_length(folders); f++) {
            folder = folders[f];
            // 新导入的 Mod 默认开启；已有 Mod 保留上次状态。
            var enabled = true;
            for (var j = 0; j < array_length(previous); j++) {
                if (previous[j].folder == folder) {
                    enabled = previous[j].enabled;
                    break;
                }
            }
            array_push(mods, { folder: folder, name: manifest_name(mod_root + "\\" + folder, folder), enabled: enabled });
    }
    array_sort(mods, function(a, b) {
        return a.folder == b.folder ? 0 : (a.folder < b.folder ? -1 : 1);
    });
    save_state();
    scroll_offset = clamp(scroll_offset, 0, max(0, array_length(mods) * row_height - (list_bottom - list_top)));
};

mods = load_state();
refresh_mods();
if (variable_global_exists("external_mod_errors")) {
    var failed_folders = variable_struct_get_names(global.external_mod_errors);
    if (array_length(failed_folders) > 0) {
        status_text = "有 Mod 加载失败，点击对应条目查看原因";
    }
}
