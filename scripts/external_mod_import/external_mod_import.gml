/// Mod jobs keep filesystem work off the game thread. Asset lookups and validation
/// stay on the game thread, with a soft four-millisecond budget per Step.
global.external_mod_import_job = undefined;

function external_mod_import_bind() {
    if (variable_global_exists("external_mod_import_functions")) return;
    var library = os_type == os_macosx ? "libFvmNativeSupport.dylib" : "FvmNativeSupport.dll";
    var candidate = global.native_util.join_path(working_directory, "native/" + library);
    if (file_exists(candidate)) library = candidate;
    else {
        candidate = global.native_util.join_path(working_directory, library);
        if (file_exists(candidate)) library = candidate;
    }
    var functions = [
        external_define(library, "ArchiveJobStart", dll_cdecl, ty_real, 2, ty_string, ty_string),
        external_define(library, "ArchiveJobPoll", dll_cdecl, ty_string, 1, ty_real),
        external_define(library, "ArchiveJobCheckPng", dll_cdecl, ty_string, 2, ty_real, ty_string),
        external_define(library, "ArchiveJobPublish", dll_cdecl, ty_real, 2, ty_real, ty_string),
        external_define(library, "ArchiveJobCancel", dll_cdecl, ty_real, 1, ty_real),
        external_define(library, "ArchiveJobRelease", dll_cdecl, ty_real, 1, ty_real),
        external_define(library, "ArchiveJobShutdown", dll_cdecl, ty_real, 0)
    ];
    for (var i = 0; i < array_length(functions); i++) {
        if (functions[i] < 0) throw "原生扩展不支持后台导入，请更新完整游戏客户端";
    }
    global.external_mod_import_functions = functions;
}

function external_mod_import_png_batch(handle, width, height, paths) {
    var payload = json_stringify({width: width, height: height, paths: paths});
    return json_parse(external_call(global.external_mod_import_functions[2], handle, payload));
}

function external_mod_import_start(archive, owner) {
    if (is_struct(global.external_mod_import_job) && !global.external_mod_import_job.done) throw "已有 Mod 正在导入";
    external_mod_import_bind();
    var ext = string_lower(filename_ext(archive));
    if (ext != ".zip" && ext != ".fvmmod") throw "请选择 ZIP 或 .fvmmod 压缩包";
    var base_name = filename_name(archive);
    base_name = string_copy(base_name, 1, string_length(base_name) - string_length(ext));
    if (base_name == "" || base_name == "." || base_name == "..") throw "压缩包名称无效";
    var folder_name = base_name;
    var target = global.native_util.join_path(owner.mod_root, folder_name);
    var suffix = 0;
    while (native_folder_exists(target) || file_exists(target)) {
        suffix++;
        folder_name = base_name + "_" + string(current_time) + "_" + string(suffix);
        target = global.native_util.join_path(owner.mod_root, folder_name);
    }
    // This sibling directory is outside installed-Mod enumeration, including
    // when the archive contains a single wrapper directory.
    var staging = global.native_util.join_path(owner.mod_root, "../.mod-import/job_" + string(get_timer()));
    var handle = external_call(global.external_mod_import_functions[0], archive, staging);
    if (handle < 1) throw "无法开始导入，错误码：" + string(handle);
    global.external_mod_import_job = {operation: "import", title: "正在导入：", handle: handle, owner: owner.id, phase: "extracting", done: false,
        started: get_timer(), next_poll: 0, native: {}, label: "正在解压", progress: -1,
        base_name: base_name, folder_name: folder_name, target: target, mod_root: owner.mod_root,
        state_path: owner.state_path, previous: owner.mods, next_entries: [], state_seeded: false,
        enabled: true, conflict_message: "", conflict: undefined, pack: undefined, validation: undefined,
        cancel_requested: false, error: "", message: "", extract_ms: 0, validate_ms: 0,
        conflict_ms: 0, publish_ms: 0, phase_started: get_timer()};
}

function external_mod_import_cancel() {
    var job = global.external_mod_import_job;
    if (!is_struct(job) || job.done || job.phase == "publishing") return;
    job.cancel_requested = true;
    job.phase = "cleaning";
    job.label = "正在清理";
    job.progress = -1;
    if (job.handle > 0) external_call(global.external_mod_import_functions[4], job.handle);
    else external_mod_manage_finish(job, {state: "cancelled"});
}

function external_mod_import_validation_begin(job, root, check_images = true) {
    var manifest_path = global.native_util.join_path(root, "manifest.json");
    var manifest = file_exists(manifest_path) ? json_parse(external_mod_read(manifest_path)) : {};
    if (external_mod_field(manifest, "api_version", 1) != 1) throw "不支持的 Mod API 版本";
    var kind = external_mod_field(manifest, "type", "cards");
    if (kind == "animation_override") {
        job.validation = external_animation_validation_begin(root, manifest, job.handle, check_images);
        if (!variable_struct_exists(manifest, "name") && root == job.native.root) job.validation.name = job.folder_name;
    } else if (kind == "cards") {
        var paths = external_mod_field(manifest, "cards", ["card.json"]);
        if (!is_array(paths) || array_length(paths) < 1 || array_length(paths) > 64) throw "cards 必须为 1–64 个 card.json 路径";
        job.validation = {root: root, paths: paths, cards: [], ids: {}, config_index: 0,
            done: false, check_images: check_images, name: external_mod_field(manifest, "name", job.folder_name), result: undefined};
    } else throw "不支持的 Mod 类型：" + string(kind);
    job.kind = kind;
    job.phase = "validating";
    job.phase_started = get_timer();
}

function external_mod_import_validation_step(job) {
    var validation = job.validation;
    if (job.kind == "animation_override") {
        external_animation_validation_step(validation);
        if (validation.phase == "configs") {
            job.label = "正在检查动画配置 " + string(validation.config_index) + "/" + string(array_length(validation.paths));
            job.progress = validation.config_index / array_length(validation.paths) * (validation.check_images ? 0.1 : 1);
        } else {
            job.label = "正在检查动画图片 " + string(validation.checked) + "/" + string(validation.total_frames);
            job.progress = 0.1 + validation.checked / max(1, validation.total_frames) * 0.9;
        }
    } else {
        var started = get_timer();
        while (validation.config_index < array_length(validation.paths)) {
            var d = external_mod_validate_card(validation.root, validation.paths[validation.config_index], validation.ids, validation.check_images);
            array_push(validation.cards, d);
            validation.config_index++;
            if (get_timer() - started >= 4000) break;
        }
        validation.done = validation.config_index >= array_length(validation.paths);
        if (validation.done) validation.result = {type: "cards", root: validation.root,
            name: validation.name, cards: validation.cards, overrides: []};
        job.label = "正在检查卡片配置 " + string(validation.config_index) + "/" + string(array_length(validation.paths));
        job.progress = validation.config_index / array_length(validation.paths);
    }
    if (!validation.done) return;
    job.pack = validation.result;
    job.validation = undefined;
    job.validate_ms = (get_timer() - job.phase_started) / 1000;
    job.phase = "conflicts";
    job.phase_started = get_timer();
    job.label = "正在检查已安装 Mod 的兼容性";
    job.progress = -1;
    job.conflict = {folder_index: 0, current: undefined, path_index: 0, compare_index: 0, indexed: false};
}

/// Index one installed configuration at a time; never rescan its PNGs.
function external_mod_import_conflict_step(job) {
    var state = job.conflict;
    var started = get_timer();
    var units = 0;
    while (state.folder_index < array_length(job.previous)) {
        var entry = job.previous[state.folder_index];
        if (!entry.enabled || (external_mod_field(job, "operation", "import") == "enable" && entry.folder == job.folder_name)) {
            state.folder_index++;
            continue;
        }
        if (is_undefined(state.current)) {
            try {
                var root = external_mod_root(global.native_util.join_path(job.mod_root, entry.folder));
                var manifest_path = global.native_util.join_path(root, "manifest.json");
                var manifest = file_exists(manifest_path) ? json_parse(external_mod_read(manifest_path)) : {};
                var animation = external_mod_field(manifest, "type", "cards") == "animation_override";
                var fallback = ["card.json"];
                if (animation) fallback = [];
                var field = animation ? "overrides" : "cards";
                var paths = external_mod_field(manifest, field, fallback);
                if (!is_array(paths)) throw "Mod 索引格式无效";
                state.current = {root: root, paths: paths, animation: animation, entries: []};
                state.path_index = 0;
                state.compare_index = 0;
                state.indexed = false;
            } catch (invalid_index) { state.folder_index++; continue; }
        }
        var current = state.current;
        if (!state.indexed) {
            try {
                if (state.path_index < array_length(current.paths)) {
                    var d = json_parse(external_mod_read(external_mod_path(current.root, current.paths[state.path_index])));
                    var item;
                    if (current.animation) {
                        var actor = asset_get_index(external_mod_field(d, "object", ""));
                        if (actor == -1 || asset_get_type(actor) != asset_object) throw "覆盖对象不存在";
                        item = {sprite: external_mod_field(d, "sprite", ""), object_asset: actor};
                    } else item = {id: external_mod_field(d, "id", "")};
                    array_push(current.entries, item);
                    state.path_index++;
                }
                state.indexed = state.path_index >= array_length(current.paths);
            } catch (invalid_existing) { state.current = undefined; state.folder_index++; }
        } else if (state.compare_index < array_length(current.entries)) {
            var installed = {cards: [], overrides: []};
            if (current.animation) array_push(installed.overrides, current.entries[state.compare_index]);
            else array_push(installed.cards, current.entries[state.compare_index]);
            try { external_mod_check_conflicts(job.pack, installed); }
            catch (conflict) {
                job.enabled = false;
                job.conflict_message = external_mod_error_text(conflict);
                return true;
            }
            state.compare_index++;
        } else { state.current = undefined; state.folder_index++; }
        units++;
        if (units >= 16 || get_timer() - started >= 4000) return false;
    }
    return true;
}

function external_mod_import_finish(job, native_state) {
    if (external_mod_field(job, "operation", "import") != "import") { external_mod_manage_finish(job, native_state); return; }
    var success = native_state.state == "done";
    if (!success && job.state_seeded) {
        if (!external_mod_state_save(job.state_path, job.previous)) job.error += "\n无法恢复 Mod 开关状态，请检查目录权限";
    }
    if (success) {
        global.external_mods = job.next_entries;
        job.publish_ms = (get_timer() - job.phase_started) / 1000;
        var prefix = job.enabled ? "已导入并开启：" : "已导入，保持关闭：";
        job.message = prefix + string(job.pack.name);
        if (job.conflict_message != "") job.message += "\n" + job.conflict_message;
        job.message += "\n请完全退出并重新启动游戏，Mod 才会生效。";
        job.phase = "complete";
    } else if (job.error != "") { job.message = job.error; job.phase = "failed"; }
    else if (native_state.state == "cancelled") { job.message = "已取消导入"; job.phase = "cancelled"; }
    else {
        job.message = "解压或安装失败，错误码：" + string(external_mod_field(native_state, "error", -5));
        job.phase = "failed";
    }
    job.done = true;
    external_call(global.external_mod_import_functions[5], job.handle);
    job.handle = -1;
    show_debug_message("[Mod import] " + json_stringify({name: job.base_name, result: job.phase,
        extract_ms: job.extract_ms, validate_ms: job.validate_ms, conflict_ms: job.conflict_ms,
        publish_ms: job.publish_ms, total_ms: (get_timer() - job.started) / 1000,
        files: external_mod_field(native_state, "files", 0), png_cache_hits: external_mod_field(native_state, "cache_hits", 0),
        png_disk_reads: external_mod_field(native_state, "disk_reads", 0)}));
}

function external_mod_import_step() {
    var job = global.external_mod_import_job;
    if (!is_struct(job) || job.done) return;
    if (external_mod_field(job, "operation", "import") != "import") { external_mod_manage_step(job); return; }
    if (!instance_exists(job.owner) && job.phase != "publishing") external_mod_import_cancel();
    var now = get_timer();
    if (now >= job.next_poll) {
        job.native = json_parse(external_call(global.external_mod_import_functions[1], job.handle));
        job.next_poll = now + 25000;
    }
    var status = external_mod_field(job.native, "state", "extracting");
    if (status == "done" || status == "cancelled" || status == "failed") {
        external_mod_import_finish(job, job.native);
        return;
    }
    if (status == "missing") { job.error = "导入任务已失效"; external_mod_import_finish(job, job.native); return; }
    if (job.cancel_requested || status == "cleaning") { job.label = "正在清理"; job.progress = -1; return; }
    try {
        if (job.phase == "extracting") {
            job.label = "正在解压，已处理 " + string(external_mod_field(job.native, "files", 0)) + " 个文件";
            var total = external_mod_field(job.native, "total_bytes", 0);
            job.progress = total > 0 ? external_mod_field(job.native, "bytes", 0) / total : -1;
            if (status == "ready") {
                job.extract_ms = (now - job.started) / 1000;
                external_mod_import_validation_begin(job, external_mod_root(job.native.root));
            }
        } else if (job.phase == "validating") external_mod_import_validation_step(job);
        else if (job.phase == "conflicts" && external_mod_import_conflict_step(job)) {
            job.conflict_ms = (get_timer() - job.phase_started) / 1000;
            job.next_entries = [];
            for (var i = 0; i < array_length(job.previous); i++) array_push(job.next_entries, job.previous[i]);
            array_push(job.next_entries, {folder: job.folder_name, name: string(job.pack.name), enabled: job.enabled});
            // Persist before publication: an interrupted import can leave a
            // harmless missing-folder record, never an unvalidated live Mod.
            if (!external_mod_state_save(job.state_path, job.next_entries)) throw "无法保存 Mod 状态，请检查目录权限";
            job.state_seeded = true;
            var code = external_call(global.external_mod_import_functions[3], job.handle, job.target);
            if (code != 0) throw "无法完成安装，错误码：" + string(code);
            job.phase = "publishing";
            job.phase_started = get_timer();
            job.label = "正在完成安装";
            job.progress = -1;
        }
    } catch (error_data) {
        job.error = "Mod 校验或安装失败：" + external_mod_error_text(error_data);
        external_mod_import_cancel();
    }
}

function external_mod_import_shutdown() {
    if (!variable_global_exists("external_mod_import_functions")) return;
    external_call(global.external_mod_import_functions[6]);
    var job = global.external_mod_import_job;
    if (is_struct(job) && job.handle > 0) {
        var status = json_parse(external_call(global.external_mod_import_functions[1], job.handle));
        if (job.state_seeded && status.state != "done") external_mod_state_save(job.state_path, job.previous);
        external_call(global.external_mod_import_functions[5], job.handle);
        job.handle = -1;
    }
    global.external_mod_import_job = undefined;
}


/// Manage jobs share the import queue: only one writer can update Mod state.
function external_mod_manage_bind() {
    external_mod_import_bind();
    if (array_length(global.external_mod_import_functions) > 7) return;
    var library = os_type == os_macosx ? "libFvmNativeSupport.dylib" : "FvmNativeSupport.dll";
    var path = global.native_util.join_path(working_directory, "native/" + library);
    if (file_exists(path)) library = path;
    else {
        path = global.native_util.join_path(working_directory, library);
        if (file_exists(path)) library = path;
    }
    var start = external_define(library, "ModJobStart", dll_cdecl, ty_real, 1, ty_string);
    if (start < 0) throw "原生扩展不支持后台管理 Mod，请更新完整游戏客户端";
    array_push(global.external_mod_import_functions, start);
}

function external_mod_manage_entries(entries) {
    var result = [];
    for (var i = 0; i < array_length(entries); i++) {
        var entry = entries[i];
        array_push(result, {folder: entry.folder, name: string(entry.name), enabled: entry.enabled});
    }
    return result;
}

function external_mod_manage_start(operation, owner, index) {
    if (is_struct(global.external_mod_import_job) && !global.external_mod_import_job.done) throw "已有 Mod 正在处理";
    if (array_get_index(["enable", "disable", "delete"], operation) < 0 || index < 0 || index >= array_length(owner.mods)) throw "Mod 操作无效";
    external_mod_manage_bind();
    var previous = external_mod_manage_entries(owner.mods);
    var next_entries = external_mod_manage_entries(owner.mods);
    var selected = previous[index];
    next_entries[index].enabled = operation == "enable";
    var state_entries = external_mod_manage_entries(next_entries);
    if (operation == "delete") array_delete(next_entries, index, 1);
    external_mod_state_decode(json_stringify(state_entries));
    var root = global.native_util.join_path(owner.mod_root, selected.folder);
    var native_operation = "state";
    if (operation == "delete") native_operation = "delete";
    var handle = -1;
    if (operation != "enable") {
        handle = external_call(global.external_mod_import_functions[7], json_stringify({operation: native_operation,
            root: root, state_path: owner.state_path, entries: state_entries}));
        if (handle < 1) throw "无法开始操作，错误码：" + string(handle);
    }
    var title = "正在关闭：";
    if (operation == "enable") title = "正在开启：";
    else if (operation == "delete") title = "正在删除：";
    var job = {operation: operation, title: title, handle: handle, owner: owner.id,
        phase: operation == "enable" ? "extracting" : "publishing", done: false,
        started: get_timer(), next_poll: 0, native: {}, label: "正在处理", progress: -1,
        base_name: selected.name, folder_name: selected.folder, target: root, mod_root: owner.mod_root,
        state_path: owner.state_path, previous: previous, next_entries: next_entries, state_seeded: false,
        enabled: true, conflict_message: "", conflict: undefined, pack: undefined, validation: undefined,
        cancel_requested: false, error: "", message: "", extract_ms: 0, validate_ms: 0,
        conflict_ms: 0, publish_ms: 0, phase_started: get_timer()};
    if (operation == "enable") external_mod_import_validation_begin(job, external_mod_root(root), false);
    global.external_mod_import_job = job;
}

function external_mod_manage_finish(job, native_state) {
    var removed = job.operation == "delete" && external_mod_field(native_state, "committed", false);
    var success = native_state.state == "done" || removed;
    if (success) {
        global.external_mods = job.next_entries;
        var prefix = "已关闭：";
        if (job.operation == "enable") prefix = "已开启：";
        else if (job.operation == "delete") prefix = "已删除：";
        job.message = prefix + job.base_name + "，重启游戏后生效";
        if (job.operation == "delete") {
            job.message += "；保留卡片进度";
            if (native_state.state != "done") {
                job.warning = true;
                job.message += "\n部分残留文件无法清理：" + string(external_mod_field(native_state, "message", "请检查目录权限"));
            }
        }
        job.phase = "complete";
    } else if (job.cancel_requested && job.error == "") { job.message = "已取消操作"; job.phase = "cancelled"; }
    else {
        job.message = job.error;
        if (job.message == "") job.message = "Mod 操作失败：" + string(external_mod_field(native_state, "message", "请检查目录权限"));
        job.phase = "failed";
    }
    job.done = true;
    if (job.handle > 0) external_call(global.external_mod_import_functions[5], job.handle);
    job.handle = -1;
    show_debug_message("[Mod manage] " + json_stringify({operation: job.operation, result: job.phase,
        total_ms: (get_timer() - job.started) / 1000, files: external_mod_field(native_state, "files", 0),
        png_headers: external_mod_field(native_state, "disk_reads", 0), png_cache_hits: external_mod_field(native_state, "cache_hits", 0)}));
}

function external_mod_manage_step(job) {
    if (!instance_exists(job.owner) && job.phase != "publishing") external_mod_import_cancel();
    var now = get_timer();
    if (job.handle > 0 && now >= job.next_poll) {
        job.native = json_parse(external_call(global.external_mod_import_functions[1], job.handle));
        job.next_poll = now + 25000;
    }
    var status = external_mod_field(job.native, "state", "extracting");
    if (array_get_index(["done", "cancelled", "failed", "missing"], status) >= 0) {
        external_mod_manage_finish(job, job.native);
        return;
    }
    if (job.cancel_requested) { job.label = "正在取消检查"; job.progress = -1; return; }
    try {
        if (job.operation != "enable") {
            job.label = job.operation == "delete" ? "正在清理文件，已处理 " + string(external_mod_field(job.native, "files", 0)) + " 项" : "正在保存开关状态";
            return;
        }
        if (job.phase == "validating") external_mod_import_validation_step(job);
        else if (job.phase == "conflicts" && external_mod_import_conflict_step(job)) {
            if (!job.enabled) throw job.conflict_message;
            job.handle = external_call(global.external_mod_import_functions[7],
                json_stringify({operation: "state", state_path: job.state_path, entries: job.next_entries}));
            if (job.handle < 1) throw "无法保存开关状态，错误码：" + string(job.handle);
            job.native = {};
            job.next_poll = 0;
            job.phase = "publishing";
            job.label = "正在保存开关状态";
            job.progress = -1;
        }
    } catch (error_data) {
        job.error = "无法开启：" + external_mod_error_text(error_data);
        external_mod_import_cancel();
    }
}
