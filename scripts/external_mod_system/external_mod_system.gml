/// External Mod API v1. Numeric cooldown/cycle values are game ticks (60 = 1 second).
function external_mod_field(payload, key, fallback) {
    return is_struct(payload) && variable_struct_exists(payload, key) ? payload[$ key] : fallback;
}

function external_mod_error_text(error_data) {
    return string(external_mod_field(error_data, "message", error_data));
}

// Resolve lazily: older DLLs can still run the base game when no external Mod is enabled.
function external_mod_lua_bind() {
    if (variable_global_exists("external_mod_lua_functions")) return;
    var library = "FvmNativeSupport.dll";
    if (file_exists(working_directory + "native/FvmNativeSupport.dll")) library = working_directory + "native/FvmNativeSupport.dll";
    var create = external_define(library, "ModLuaCreate", dll_cdecl, ty_string, 1, ty_string);
    var call = external_define(library, "ModLuaCall", dll_cdecl, ty_string, 3, ty_real, ty_string, ty_string);
    var destroy = external_define(library, "ModLuaDestroy", dll_cdecl, ty_real, 1, ty_real);
    if (create < 0 || call < 0 || destroy < 0) throw "原生扩展尚未包含 Lua；需要更新 FvmNativeSupport.dll";
    global.external_mod_lua_functions = [create, call, destroy];
}

function native_mod_lua_create(source) {
    external_mod_lua_bind();
    return external_call(global.external_mod_lua_functions[0], source);
}
function native_mod_lua_call(handle, event_name, context) {
    return external_call(global.external_mod_lua_functions[1], handle, event_name, context);
}
function native_mod_lua_destroy(handle) {
    return external_call(global.external_mod_lua_functions[2], handle);
}

function external_mod_card_max_level(cid) {
    var definition = external_mod_get(cid);
    return is_undefined(definition) ? 16 : definition.max_level;
}

function external_mod_read(path) {
    if (!file_exists(path)) throw "文件不存在：" + path;
    var b = buffer_load(path);
    if (!buffer_exists(b)) throw "无法读取文件：" + path;
    var raw = buffer_read(b, buffer_string);
    buffer_delete(b);
    return raw;
}

function external_mod_path(root, relative) {
    if (!is_string(relative) || relative == "") throw "资源路径不能为空";
    var p = string_replace_all(relative, "\\", "/");
    if (string_pos(":", p) > 0 || string_copy(p, 1, 1) == "/") throw "资源路径必须是包内相对路径";
    var parts = string_split(p, "/");
    for (var i = 0; i < array_length(parts); i++) {
        if (parts[i] == ".." || parts[i] == "" || parts[i] == ".") throw "资源路径包含无效目录";
    }
    return root + "/" + p;
}

function external_mod_id_valid(cid) {
    if (!is_string(cid) || string_length(cid) < 3 || string_length(cid) > 100 || string_pos(".", cid) < 2) return false;
    var allowed = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-";
    for (var i = 1; i <= string_length(cid); i++) {
        if (string_pos(string_char_at(cid, i), allowed) == 0) return false;
    }
    return true;
}

function external_mod_root(folder) {
    if (file_exists(folder + "/manifest.json") || file_exists(folder + "/card.json")) return folder;
    var roots = [];
    var names = [];
    var n = file_find_first(folder + "/*", fa_directory);
    while (n != "") {
        if (n != "." && n != ".." && directory_exists(folder + "/" + n)) array_push(names, n);
        n = file_find_next();
    }
    file_find_close();
    for (var i = 0; i < array_length(names); i++) {
        var p = folder + "/" + names[i];
        if (file_exists(p + "/manifest.json") || file_exists(p + "/card.json")) array_push(roots, p);
    }
    if (array_length(roots) != 1) throw "包内需要 manifest.json 或 card.json（允许一层外目录）";
    return roots[0];
}

function external_mod_numbers(payload, count, label) {
    if (!is_array(payload)) payload = array_create(count, payload);
    if (array_length(payload) != count) throw label + " 必须包含 " + string(count) + " 个星级数值";
    for (var i = 0; i < count; i++) {
        if (!is_numeric(payload[i]) || is_nan(payload[i]) || is_infinity(payload[i]) || payload[i] < 0) throw label + " 必须为非负有限数值";
    }
    return payload;
}

function external_mod_animation_frames(payload) {
    var frames = external_mod_field(payload, "frames", undefined);
    if (!is_undefined(frames)) return frames;
    var pattern = external_mod_field(payload, "pattern", "");
    var start = external_mod_field(payload, "start", 1);
    var finish = external_mod_field(payload, "end", 0);
    if (!is_string(pattern) || pattern == "" || !is_numeric(start) || !is_numeric(finish) || finish < start) return [];
    var percent = string_pos("%", pattern);
    var dpos = percent > 0 ? string_pos("d", string_copy(pattern, percent, string_length(pattern) - percent + 1)) : 0;
    if (percent <= 0 || dpos <= 0) return [];
    dpos += percent - 1;
    var token = string_copy(pattern, percent, dpos - percent + 1);
    var width_text = string_replace_all(string_replace_all(token, "%", ""), "d", "");
    var width = string_length(width_text);
    frames = [];
    for (var n = floor(start); n <= floor(finish) && array_length(frames) < 256; n++) {
        var number = string(n);
        while (string_length(number) < width) number = "0" + number;
        array_push(frames, string_replace(pattern, token, number));
    }
    return frames;
}

function external_mod_animation_validate(root, payload) {
    var frames = external_mod_animation_frames(payload);
    if (!is_array(frames) || array_length(frames) == 0 || array_length(frames) > 256) throw "动画需要 1–256 张 PNG";
    var animation_fps = external_mod_field(payload, "fps", 12);
    if (!is_numeric(animation_fps) || animation_fps <= 0 || animation_fps > 60) throw "动画 fps 范围为 1–60";
    var declared_origin = external_mod_field(payload, "origin", undefined);
    if (!is_undefined(declared_origin) && array_get_index(["bottom_center", "center", "custom"], declared_origin) == -1) throw "origin 只能是 bottom_center、center 或 custom";
    var declared_x = external_mod_field(payload, "origin_x", undefined);
    var declared_y = external_mod_field(payload, "origin_y", undefined);
    if (declared_origin == "custom" || (is_undefined(declared_origin) && (!is_undefined(declared_x) || !is_undefined(declared_y)))) {
        if (!is_numeric(declared_x) || !is_numeric(declared_y) || is_nan(declared_x) || is_nan(declared_y) || is_infinity(declared_x) || is_infinity(declared_y)) throw "自定义原点需要有限的 origin_x 和 origin_y 数值";
    }
    for (var i = 0; i < array_length(frames); i++) {
        var p = external_mod_path(root, frames[i]);
        if (string_lower(filename_ext(p)) != ".png" || !file_exists(p)) throw "PNG 不存在：" + p;
    }
    var events = external_mod_field(payload, "events", []);
    if (!is_array(events) || array_length(events) > 128) throw "动画事件格式无效";
    for (var i = 0; i < array_length(events); i++) {
        var f = external_mod_field(events[i], "frame", -1);
        var ename = external_mod_field(events[i], "name", "");
        if (!is_numeric(f) || f != floor(f) || f < 1 || f > array_length(frames) || !is_string(ename) || ename == "") throw "动画事件 frame 从 1 开始且不能超过帧数";
    }
    return {frames: frames, fps: animation_fps, loop: external_mod_field(payload, "loop", true), events: events,
        origin: external_mod_field(payload, "origin", undefined),
        origin_x: external_mod_field(payload, "origin_x", undefined), origin_y: external_mod_field(payload, "origin_y", undefined)};
}

/// Validate without registering resources, running Lua or writing saves.
function external_mod_validate(folder) {
    var root = external_mod_root(folder);
    var manifest = file_exists(root + "/manifest.json") ? json_parse(external_mod_read(root + "/manifest.json")) : {};
    if (external_mod_field(manifest, "api_version", 1) != 1) throw "不支持的 Mod API 版本";
    var files = external_mod_field(manifest, "cards", ["card.json"]);
    if (!is_array(files) || array_length(files) < 1 || array_length(files) > 64) throw "cards 必须为 1–64 个 card.json 路径";
    var cards = [];
    var ids = {};
    for (var c = 0; c < array_length(files); c++) {
        var file = external_mod_path(root, files[c]);
        var d = json_parse(external_mod_read(file));
        var cid = external_mod_field(d, "id", "");
        if (!external_mod_id_valid(cid) || variable_struct_exists(ids, cid)) throw "卡片 ID 无效或重复：" + string(cid);
        ids[$ cid] = true;
        if (external_mod_field(d, "api_version", 1) != 1) throw "不支持的卡片 API 版本";
        if (!is_string(external_mod_field(d, "name", undefined)) || d.name == "") throw "卡片缺少名称";
        if (!is_string(external_mod_field(d, "description", undefined)) || d.description == "") throw "卡片缺少描述";
        d.root = filename_dir(file);
        // Accept both names used by the design document and the current template.
        // Only gold cards have temporary 17/18-star data for Clotho.
        d.is_god = external_mod_field(d, "is_gold", external_mod_field(d, "is_god", false)) == true;
        d.is_gold = d.is_god;
        d.max_level = d.is_god ? 18 : 16;
        var declared_max = external_mod_field(d, "max_star", d.max_level);
        if (!is_numeric(declared_max) || floor(declared_max) != declared_max || (declared_max != 16 && declared_max != 18)) throw "max_star 只能是 16 或 18";
        if (declared_max == 18 && !d.is_gold) throw "18 星卡片必须是金卡";
        d.max_level = declared_max;
        d.script_path = external_mod_path(d.root, external_mod_field(d, "script", "logic.lua"));
        if (string_lower(filename_ext(d.script_path)) != ".lua") throw "行为脚本必须是 .lua";
        d.source = external_mod_read(d.script_path);
        if (string_byte_length(d.source) > 262144) throw "Lua 脚本不能超过 256 KB";
        // Legacy single-card form becomes a separate shape struct, avoiding a self reference.
        d.shapes = external_mod_field(d, "shapes", [json_parse(external_mod_read(file))]);
        if (!is_array(d.shapes) || array_length(d.shapes) < 1 || array_length(d.shapes) > 6) throw "需要 1–6 个连续形态";
        for (var s = 0; s < array_length(d.shapes); s++) {
            var sh = d.shapes[s];
            if (!is_struct(sh) || external_mod_field(sh, "shape", s) != s) throw "shape 必须从 0 连续编号";
            sh.shape = s;
            sh.is_gold = d.is_gold;
            sh.name = external_mod_field(sh, "name", d.name);
            sh.description = external_mod_field(sh, "description", d.description);
            var fields = ["hp", "cost", "atk", "range", "cooldown", "cycle"];
            var defaults = [50, 100, 20, 10, 420, 120];
            for (var k = 0; k < array_length(fields); k++) sh[$ fields[k]] = external_mod_numbers(external_mod_field(sh, fields[k], defaults[k]), d.max_level + 1, fields[k]);
            sh.plant_type = external_mod_field(sh, "plant_type", "normal");
            sh.feature_type = external_mod_field(sh, "feature_type", "normal");
            sh.target_card = external_mod_field(sh, "target_card", "none");
            sh.target_type = external_mod_field(sh, "target_type", "normal");
            if (array_get_index(["normal", "air", "air_only", "throw", "track", "pierce", "rotate", "d_fruit", "all"], sh.target_type) < 0) throw "卡片 target_type 无效：" + string(sh.target_type);
            sh.behavior_params = external_mod_field(sh, "behavior_params", external_mod_field(d, "behavior_params", {}));
            sh.icon = external_mod_field(sh, "icon", external_mod_field(d, "icon", external_mod_field(d, "sprite", "card.png")));
            var icon_path = external_mod_path(d.root, sh.icon);
            if (!file_exists(icon_path) || string_lower(filename_ext(icon_path)) != ".png") throw "卡片图标不存在：" + icon_path;
            var anims = external_mod_field(sh, "animations", external_mod_field(d, "animations", {idle: {frames: [sh.icon], fps: 1}}));
            if (!is_struct(anims) || !variable_struct_exists(anims, "idle")) throw "缺少 idle 动画";
            sh.animations = {};
            var keys = variable_struct_get_names(anims);
            for (var k = 0; k < array_length(keys); k++) {
                sh.animations[$ keys[k]] = external_mod_animation_validate(d.root, anims[$ keys[k]]);
                if (keys[k] == "bullet") sh.animations[$ keys[k]].rules = external_mod_projectile_rules(anims[$ keys[k]]);
            }
            d.shapes[s] = sh;
        }
        d.skill = external_mod_field(d, "skill", undefined);
        if (!is_undefined(d.skill)) {
            var property = external_mod_field(d.skill, "property", "");
            if (array_get_index(["hp", "atk", "cost", "range", "cycle", "cooldown", "flame_produce"], property) == -1) throw "不支持的技能属性";
            d.skill.values = external_mod_numbers(external_mod_field(d.skill, "values", []), 9, "技能 values");
        }
        d.projectiles = external_mod_field(d, "projectiles", {});
        if (!is_struct(d.projectiles)) throw "projectiles 必须为对象";
        // The design document allows a bullet animation inside a shape. Promote it
        // to the projectile registry so api.shoot({sprite="bullet"}) works too.
        if (variable_struct_exists(d.shapes[0].animations, "bullet") && !variable_struct_exists(d.projectiles, "bullet")) {
            d.projectiles.bullet = d.shapes[0].animations.bullet;
        }
        var pkeys = variable_struct_get_names(d.projectiles);
        for (var k = 0; k < array_length(pkeys); k++) {
            var projectile_payload = d.projectiles[$ pkeys[k]];
            var projectile_animation = external_mod_animation_validate(d.root, projectile_payload);
            projectile_animation.rules = external_mod_field(projectile_payload, "rules", external_mod_projectile_rules(projectile_payload));
            d.projectiles[$ pkeys[k]] = projectile_animation;
        }
        d.behavior_params = external_mod_field(d, "behavior_params", {});
        d.initial_unlock = external_mod_field(d, "initial_unlock", {level: 0, shape: 0, skill: 0});
        array_push(cards, d);
    }
    return {root: root, name: external_mod_field(manifest, "name", filename_name(folder)), cards: cards};
}

function external_mod_sprite(root, anim, assets, default_origin = "bottom_center") {
    var spr = -1;
    var origin_mode = external_mod_field(anim, "origin", undefined);
    var custom_x = external_mod_field(anim, "origin_x", undefined);
    var custom_y = external_mod_field(anim, "origin_y", undefined);
    if (is_undefined(origin_mode)) {
        origin_mode = !is_undefined(custom_x) && !is_undefined(custom_y) ? "custom" : default_origin;
    }
    if (array_get_index(["bottom_center", "center", "custom"], origin_mode) == -1) throw "不支持的图片原点：" + string(origin_mode);
    if (origin_mode == "custom" && (!is_numeric(custom_x) || !is_numeric(custom_y))) throw "自定义原点需要 origin_x 和 origin_y 数值";
    var bounds_left = 0;
    var bounds_right = 0;
    var bounds_bottom = 0;
    for (var i = 0; i < array_length(anim.frames); i++) {
        var frame = sprite_add(external_mod_path(root, anim.frames[i]), 1, false, false, 0, 0);
        if (frame < 0) throw "PNG 加载失败：" + anim.frames[i];
        ds_list_add(assets, frame);
        sprite_set_bbox_mode(frame, 0);
        // Use the union of all frames' visible bounds for one stable animation origin.
        bounds_left = i == 0 ? sprite_get_bbox_left(frame) : min(bounds_left, sprite_get_bbox_left(frame));
        bounds_right = i == 0 ? sprite_get_bbox_right(frame) : max(bounds_right, sprite_get_bbox_right(frame));
        bounds_bottom = max(bounds_bottom, sprite_get_bbox_bottom(frame) + 1);
        if (i == 0) spr = frame;
        else {
            if (sprite_get_width(frame) != sprite_get_width(spr) || sprite_get_height(frame) != sprite_get_height(spr)) throw "同一动画的 PNG 尺寸必须一致";
            sprite_merge(spr, frame);
        }
    }
    switch (origin_mode) {
        case "bottom_center":
            sprite_set_offset(spr, floor((bounds_left + bounds_right + 1) / 2), bounds_bottom);
            break;
        case "center":
            sprite_set_offset(spr, floor(sprite_get_width(spr) / 2), floor(sprite_get_height(spr) / 2));
            break;
        case "custom": sprite_set_offset(spr, custom_x, custom_y); break;
    }
    return spr;
}

function external_mod_assets_delete(assets) {
    for (var i = 0; i < ds_list_size(assets); i++) {
        var spr = assets[| i];
        if (sprite_exists(spr)) sprite_delete(spr);
    }
    ds_list_destroy(assets);
}

function external_mod_map_tree_delete(map, tree_depth = 0) {
    var key = ds_map_find_first(map);
    while (!is_undefined(key)) {
        var map_value = map[? key];
        // Only registry container values are maps; numeric stats can equal a live DS handle.
        if ((tree_depth == 0 && key == "shapes") || tree_depth == 1 || (tree_depth == 2 && key == "upgrades") || tree_depth == 3) {
            if (is_real(map_value) && ds_exists(map_value, ds_type_map)) external_mod_map_tree_delete(map_value, tree_depth + 1);
        }
        key = ds_map_find_next(map, key);
    }
    ds_map_destroy(map);
}

function external_mod_unregister(cid) {
    if (ds_map_exists(global.plant_registry, cid)) {
        external_mod_map_tree_delete(global.plant_registry[? cid]);
        ds_map_delete(global.plant_registry, cid);
    }
    for (var i = ds_list_size(global.player_deck) - 2; i >= 0; i -= 2) {
        if (global.player_deck[| i] != cid) continue;
        var card = global.player_deck[| i + 1];
        var shapes = card[? "shapes"];
        for (var j = 0; j < ds_list_size(shapes); j++) ds_map_destroy(shapes[| j]);
        ds_list_destroy(shapes); ds_map_destroy(card);
        ds_list_delete(global.player_deck, i + 1); ds_list_delete(global.player_deck, i);
    }
    ds_map_delete(global.info_island, cid);
    ds_map_delete(global.skill_registry, cid);
    ds_map_delete(global.plus_card_map, cid);
    variable_struct_remove(global.external_card_registry, cid);
}

function external_mod_known(cid) {
    if (!variable_global_exists("save_data")) return false;
    var known = external_mod_field(global.save_data, "external_card_ids", []);
    return array_get_index(known, cid) != -1;
}

function external_mod_get(cid) {
    return variable_global_exists("external_card_registry") ? external_mod_field(global.external_card_registry, cid, undefined) : undefined;
}

function external_mod_load_all() {
    global.external_card_registry = {};
    global.external_mod_errors = {};
    global.external_mod_loaded = {};
    global.external_mod_assets = [];
    var root = global.native_util.get_path_in_local_appdata("\\FVM_Reborn_makk\\mod");
    var state = [];
    try { if (file_exists(root + "/mod_state.json")) state = json_parse(external_mod_read(root + "/mod_state.json")); } catch (e) { state = []; }
    if (!is_array(state)) state = [];
    var folders = [];
    var f = file_find_first(root + "/*", fa_directory);
    while (f != "") {
        if (f != "." && f != ".." && directory_exists(root + "/" + f)) array_push(folders, f);
        f = file_find_next();
    }
    file_find_close();
    array_sort(folders, function(a, b) { return a == b ? 0 : (a < b ? -1 : 1); });
    if (!variable_struct_exists(global.save_data, "external_card_ids")) global.save_data.external_card_ids = [];
    for (var i = 0; i < array_length(folders); i++) {
        var folder = folders[i];
        var enabled = true;
        for (var j = 0; j < array_length(state); j++) if (external_mod_field(state[j], "folder", "") == folder) enabled = external_mod_field(state[j], "enabled", true) == true;
        if (!enabled) continue;
        var registered = [];
        var assets = ds_list_create();
        try {
            var pack = external_mod_validate(root + "/" + folder);
            // Check every ID before publishing any card from this package.
            for (var c = 0; c < array_length(pack.cards); c++) {
                var d = pack.cards[c];
                if (ds_map_exists(global.plant_registry, d.id) || deck_get_card_data(d.id, 0) != noone) throw "卡片 ID 已存在：" + d.id;
                var probe = json_parse(native_mod_lua_create(d.source));
                if (!probe.ok) throw "Lua 无法加载：" + probe.error;
                native_mod_lua_destroy(probe.handle);
                for (var s = 0; s < array_length(d.shapes); s++) {
                    var sh = d.shapes[s];
                    sh.sprite = external_mod_sprite(d.root, {frames: [sh.icon], origin: "bottom_center"}, assets);
                    var keys = variable_struct_get_names(sh.animations);
                    for (var k = 0; k < array_length(keys); k++) sh.animations[$ keys[k]].sprite = external_mod_sprite(d.root, sh.animations[$ keys[k]], assets);
                    d.shapes[s] = sh;
                }
                var keys = variable_struct_get_names(d.projectiles);
                for (var k = 0; k < array_length(keys); k++) d.projectiles[$ keys[k]].sprite = external_mod_sprite(d.root, d.projectiles[$ keys[k]], assets, "center");
            }
            for (var c = 0; c < array_length(pack.cards); c++) {
                var d = pack.cards[c];
                // Mark before mutating so partial registration can also roll back.
                array_push(registered, d.id);
                mod_register_plant_lite(d.id, d.shapes, d.is_god);
                var slots = [];
                var info = d.name + "\n" + d.description;
                for (var s = 0; s < array_length(d.shapes); s++) {
                    var sh = d.shapes[s];
                    array_push(slots, {shape: s, sprite: sh.sprite, cost: sh.cost[0], cooldown: sh.cooldown[0], description: sh.description,
                        plant_type: sh.plant_type, feature_type: sh.feature_type, target_card: sh.target_card,
                        is_gold: external_mod_field(sh, "is_gold", external_mod_field(d, "is_gold", false)),
                        is_fusion: external_mod_field(sh, "is_fusion", false), place_preview: sh.animations.idle.sprite});
                    info += "\n\n形态 " + string(s) + " · " + sh.name + "\n" + sh.description;
                }
                register_card(d.id, obj_external_mod_card, slots);
                register_card_info_island(d.id, external_mod_field(d, "info_description", info));
                if (!is_undefined(d.skill)) register_card_skill(d.id, d.skill.property, d.skill.values);
                ds_map_set(global.plus_card_map, d.id, [obj_external_mod_card, array_length(d.shapes) - 1]);
                global.external_card_registry[$ d.id] = d;
            }
            // Publish unlocks only after the entire package has registered successfully.
            for (var c = 0; c < array_length(pack.cards); c++) {
                var d = pack.cards[c];
                if (!external_mod_known(d.id)) array_push(global.save_data.external_card_ids, d.id);
                if (get_card_info_simple(d.id) == false) {
                    var u = d.initial_unlock;
                    var unlock_level = external_mod_field(u, "level", external_mod_field(u, "star", 0));
                    unlock_card(d.id, clamp(floor(unlock_level), 0, 16),
                        clamp(floor(external_mod_field(u, "shape", 0)), 0, array_length(d.shapes) - 1),
                        clamp(floor(external_mod_field(u, "skill", 0)), 0, is_undefined(d.skill) ? 0 : 8));
                }
            }
            array_push(global.external_mod_assets, assets);
            global.external_mod_loaded[$ folder] = array_length(pack.cards);
        } catch (e) {
            for (var c = 0; c < array_length(registered); c++) external_mod_unregister(registered[c]);
            external_mod_assets_delete(assets);
            var message = external_mod_error_text(e);
            global.external_mod_errors[$ folder] = message;
            show_debug_message("[Mod " + folder + "] " + message);
        }
    }
    save_file(global.save_slot);
}

/// Card identity must be supplied BEFORE its Create event; never infer it from object_index.
function external_mod_spawn(px, py, z, cid, card_shape = -1, level = -1, card_skill = -1) {
    var data = deck_get_card_data(cid, max(0, card_shape));
    if (data == noone) return noone;
    var obj = data[? "obj"];
    if (obj != obj_external_mod_card) return instance_create_depth(px, py, z, obj);
    var saved = get_card_info_simple(cid);
    var d = external_mod_get(cid);
    if (is_undefined(d)) return noone;
    var s = clamp(card_shape < 0 ? (saved == false ? 0 : saved.shape) : card_shape, 0, array_length(d.shapes) - 1);
    var l = level < 0 ? clamp(saved == false ? 0 : saved.level, 0, 16) : clamp(level, 0, d.max_level);
    var sk = clamp(card_skill < 0 ? (saved == false ? 0 : saved.skill) : card_skill, 0, is_undefined(d.skill) ? 0 : 8);
    return instance_create_depth_define(px, py, z, obj, {external_spawn_id: cid, external_spawn_shape: s, external_spawn_level: l, external_spawn_skill: sk});
}

function external_mod_context(inst, extra = undefined) {
    var enemies = [];
    for (var i = 0; i < instance_number(obj_enemy_parent) && array_length(enemies) < 128; i++) {
        var e = instance_find(obj_enemy_parent, i);
        if (e.hp > 0 && can_target_on(inst.target_type, e.target_type)) array_push(enemies, {id: e.id, x: e.x, y: e.y, row: e.grid_row, col: e.grid_col, hp: e.hp});
    }
    return {id: inst.id, x: inst.x, y: inst.y, row: inst.grid_row, col: inst.grid_col,
        hp: inst.hp, max_hp: inst.max_hp, atk: inst.atk, cycle: inst.cycle, range: inst.range,
        level: inst.current_level, shape: inst.shape, skill: inst.skill, dt: 1/60,
        rows: global.grid_rows, row_height: global.grid_cell_size_y,
        slowed: inst.is_slowdown,
        params: external_mod_field(inst.mod_definition.shapes[inst.shape], "behavior_params", inst.mod_definition.behavior_params),
        enemies: enemies, event: extra};
}

function external_mod_animate(inst, anim_name) {
    var animations = inst.mod_definition.shapes[inst.shape].animations;
    if (!variable_struct_exists(animations, anim_name)) return;
    inst.mod_animation_name = anim_name;
    inst.mod_animation = animations[$ anim_name];
    inst.sprite_index = inst.mod_animation.sprite;
    inst.image_index = 0;
    inst.mod_animation_frame = 0;
}

function external_mod_callback(inst, event_name, extra = undefined) {
    if (inst.mod_lua_handle < 0 || inst.mod_script_failed) return;
    var response;
    try {
        response = json_parse(native_mod_lua_call(inst.mod_lua_handle, event_name, json_stringify(external_mod_context(inst, extra))));
        if (!response.ok) throw response.error;
        for (var i = 0; i < array_length(response.commands); i++) {
            if (!instance_exists(inst)) break;
            external_mod_command(inst, response.commands[i]);
        }
    } catch (e) {
        inst.mod_script_failed = true;
        show_debug_message("[Mod " + inst.plant_id + "] " + string(e));
    }
}

/// Projectile policy lives in JSON; Lua only supplies shot-specific values.
function external_mod_rule_bool(payload, key, fallback) {
    var _setting = external_mod_field(payload, key, fallback);
    if (!is_bool(_setting)) throw "子弹 " + key + " 必须为 true 或 false";
    return _setting;
}

function external_mod_rule_count(payload, key, fallback, limit) {
    var _setting = external_mod_field(payload, key, fallback);
    if (!is_numeric(_setting) || is_nan(_setting) || is_infinity(_setting)
        || _setting != floor(_setting) || _setting < 0 || _setting > limit) throw "子弹 " + key + " 整数范围为 0–" + string(limit);
    return _setting;
}

function external_mod_rule_names(payload, key, fallback, allowed) {
    var _names = external_mod_field(payload, key, fallback);
    if (!is_array(_names) || array_length(_names) > array_length(allowed)) throw "子弹 " + key + " 必须为有效名称数组";
    var _seen = [];
    for (var _n = 0; _n < array_length(_names); _n++) {
        if (!is_string(_names[_n]) || array_get_index(allowed, _names[_n]) < 0 || array_get_index(_seen, _names[_n]) >= 0) throw "子弹 " + key + " 名称无效或重复：" + string(_names[_n]);
        array_push(_seen, _names[_n]);
    }
    return _names;
}

function external_mod_projectile_rules(payload) {
    var _filter = external_mod_field(payload, "target_filter", {});
    var _hit = external_mod_field(payload, "hit", {});
    var _reflection = external_mod_field(payload, "reflection", {});
    var _enhancement = external_mod_field(payload, "enhancement", {});
    if (!is_struct(_filter) || !is_struct(_hit) || !is_struct(_reflection) || !is_struct(_enhancement)) throw "子弹 target_filter、hit、reflection、enhancement 必须为对象";
    var _team = external_mod_field(_filter, "team", undefined);
    var _enemy_flag = external_mod_field(_filter, "enemy", undefined);
    var _friendly_flag = external_mod_field(_filter, "friendly", undefined);
    if (!is_undefined(_enemy_flag) && !is_bool(_enemy_flag)) throw "target_filter.enemy 必须为 true 或 false";
    if (!is_undefined(_friendly_flag) && !is_bool(_friendly_flag)) throw "target_filter.friendly 必须为 true 或 false";
    if (is_undefined(_team)) {
        var _want_enemy = is_undefined(_enemy_flag) ? true : _enemy_flag;
        var _want_friend = is_undefined(_friendly_flag) ? false : _friendly_flag;
        _team = _want_enemy ? (_want_friend ? "all" : "enemy") : (_want_friend ? "friendly" : "none");
    }
    var _reflect_team = external_mod_field(_reflection, "team", "keep");
    if (array_get_index(["enemy", "friendly", "all", "none"], _team) < 0) throw "子弹 team 只能为 enemy、friendly、all、none";
    if (array_get_index(["keep", "enemy", "friendly", "all"], _reflect_team) < 0) throw "反弹 team 无效";
    var _damage_type = external_mod_field(payload, "damage_type", "normal");
    if (array_get_index(["normal", "pierce", "true"], _damage_type) < 0) throw "子弹 damage_type 只能为 normal、pierce、true";
    var _interval = external_mod_rule_count(_hit, "repeat_interval_ticks", 30, 36000);
    if (_interval < 1) throw "repeat_interval_ticks 至少为 1";
    var _types = external_mod_rule_names(_filter, "types", [], ["normal", "diver", "air", "dance", "obstacle", "underground", "invisible"]);
    var _ground = external_mod_field(_filter, "ground", undefined);
    var _air = external_mod_field(_filter, "air", undefined);
    var _mole = external_mod_field(_filter, "mole", undefined);
    var _flags = [_ground, _air, _mole];
    for (var _flag_i = 0; _flag_i < 3; _flag_i++) {
        var _flag = _flags[_flag_i];
        if (!is_undefined(_flag) && !is_bool(_flag)) throw "target_filter ground、air、mole 必须为 true 或 false";
    }
    if (!is_undefined(_ground) && _ground) { if (array_get_index(_types, "normal") < 0) array_push(_types, "normal"); if (array_get_index(_types, "obstacle") < 0) array_push(_types, "obstacle"); }
    if (!is_undefined(_air) && _air && array_get_index(_types, "air") < 0) array_push(_types, "air");
    if (!is_undefined(_mole) && _mole && array_get_index(_types, "underground") < 0) array_push(_types, "underground");
    var _invincible = external_mod_field(_filter, "invincible", external_mod_field(_filter, "hit_invincible", false));
    if (!is_bool(_invincible)) throw "target_filter.invincible 必须为 true 或 false";
    return {
        damage_type: _damage_type,
        target_filter: {team: _team,
            types: _types,
            ground: _ground, air: _air, mole: _mole,
            explicit_types: variable_struct_exists(_filter, "types") || !is_undefined(_ground) || !is_undefined(_air) || !is_undefined(_mole),
            hit_invincible: _invincible},
        hit: {max_hits: external_mod_rule_count(_hit, "max_hits", 1, 10000),
            repeat_hit: external_mod_rule_bool(_hit, "repeat_hit", false), repeat_interval_ticks: _interval,
            destroy_on_hit: external_mod_rule_bool(_hit, "destroy_on_hit", true)},
        reflection: {sources: external_mod_rule_names(_reflection, "sources", [], ["cherry_pudding", "water_god"]),
            max_count: external_mod_rule_count(_reflection, "max_count", 1, 16), team: _reflect_team,
            add_source_atk: external_mod_rule_bool(_reflection, "add_source_atk", true)},
        enhancement: {sources: external_mod_rule_names(_enhancement, "sources", [], ["brazier", "jinniu", "fire_god"]),
            max_count: external_mod_rule_count(_enhancement, "max_count", 1, 16),
            clear_slow: external_mod_rule_bool(_enhancement, "clear_slow", false)}
    };
}

function external_mod_projectile_source_object(source_name) {
    switch (source_name) {
        case "brazier": return obj_brazier;
        case "jinniu": return obj_jinniu;
        case "fire_god": return obj_fire_god;
        case "cherry_pudding": return obj_cherry_pudding;
        case "water_god": return obj_water_god;
    }
    return noone;
}

/// Swept AABB: expand target by the projectile's current mask extents.
/// Returns the earliest contact fraction, or -1 when there is no contact.
function external_mod_sweep_contact(bullet_inst, target_inst, x0, y0, x1, y1) {
    if (bullet_inst.sprite_index < 0 || target_inst.sprite_index < 0) return -1;
    var _lower = [target_inst.bbox_left - (bullet_inst.bbox_right - bullet_inst.x), target_inst.bbox_top - (bullet_inst.bbox_bottom - bullet_inst.y)];
    var _upper = [target_inst.bbox_right - (bullet_inst.bbox_left - bullet_inst.x), target_inst.bbox_bottom - (bullet_inst.bbox_top - bullet_inst.y)];
    var _start = [x0, y0];
    var _delta = [x1 - x0, y1 - y0];
    var _enter = 0;
    var _leave = 1;
    for (var _axis = 0; _axis < 2; _axis++) {
        if (abs(_delta[_axis]) < 0.000001) {
            if (_start[_axis] < _lower[_axis] || _start[_axis] > _upper[_axis]) return -1;
        } else {
            var _t1 = (_lower[_axis] - _start[_axis]) / _delta[_axis];
            var _t2 = (_upper[_axis] - _start[_axis]) / _delta[_axis];
            _enter = max(_enter, min(_t1, _t2));
            _leave = min(_leave, max(_t1, _t2));
            if (_enter > _leave) return -1;
        }
    }
    return _enter;
}

function external_mod_projectile_target_allowed(bullet_inst, target_inst, enemy_target) {
    if (!instance_exists(target_inst) || target_inst.hp <= 0 || target_inst.id == bullet_inst.combat_owner || target_inst.grid_row != bullet_inst.row) return false;
    var _filter = bullet_inst.rules.target_filter;
    if (bullet_inst.target_team == "none") return false;
    if (enemy_target && bullet_inst.target_team == "friendly") return false;
    if (!enemy_target && bullet_inst.target_team == "enemy") return false;
    if (!_filter.hit_invincible) {
        if (variable_instance_exists(target_inst, "invincible") && target_inst.invincible) return false;
        if (variable_instance_exists(target_inst, "is_invincible") && target_inst.is_invincible) return false;
    }
    if (!enemy_target) return true;
    // Projectile filters narrow the card's capabilities; they cannot expand them.
    if (!can_target_on(bullet_inst.target_type, target_inst.target_type)) return false;
    if (!is_undefined(_filter.air) && !_filter.air && target_inst.target_type == "air") return false;
    if (!is_undefined(_filter.mole) && !_filter.mole && target_inst.target_type == "underground") return false;
    if (!is_undefined(_filter.ground) && !_filter.ground && array_get_index(["normal", "obstacle", "dance", "invisible"], target_inst.target_type) >= 0) return false;
    if (_filter.explicit_types) return array_get_index(_filter.types, target_inst.target_type) >= 0;
    return can_target_on(bullet_inst.target_type, target_inst.target_type);
}

function external_mod_command(inst, cmd) {
    var amount = external_mod_field(cmd, "amount", 0);
    switch (external_mod_field(cmd, "op", "")) {
        case "shoot":
            var shot_row = inst.grid_row + clamp(floor(external_mod_field(cmd, "row_offset", 0)), -8, 8);
            if (shot_row < 0 || shot_row >= global.grid_rows) break;
            var bullet = instance_create_depth(inst.x + external_mod_field(cmd, "offset_x", 40), inst.y + external_mod_field(cmd, "offset_y", -75), inst.depth - 500, obj_external_mod_bullet);
            bullet.damage = max(0, external_mod_field(cmd, "damage", inst.atk));
            bullet.move_speed = clamp(external_mod_field(cmd, "speed", 8), -2000, 2000);
            bullet.move_x = bullet.move_speed;
            bullet.move_y = clamp(external_mod_field(cmd, "speed_y", 0), -2000, 2000);
            bullet.row = shot_row;
            var vertical_distance = external_mod_field(cmd, "vertical_distance", 0);
            if (is_numeric(vertical_distance) && !is_nan(vertical_distance) && !is_infinity(vertical_distance) && vertical_distance > 0 && bullet.move_y != 0) {
                bullet.vertical_remaining = clamp(vertical_distance, 0, global.grid_cell_size_y * 8);
                bullet.vertical_limited = true;
            }
            var burn_payload = external_mod_field(cmd, "burn", undefined);
            if (is_struct(burn_payload)) {
                bullet.burn = {
                    probability: clamp(external_mod_field(burn_payload, "probability", 0), 0, 100),
                    power: clamp(external_mod_field(burn_payload, "power", 0), 0, 1000000),
                    duration: clamp(floor(external_mod_field(burn_payload, "duration", 21)), 1, 3600),
                    roll: clamp(floor(external_mod_field(burn_payload, "roll", irandom(100))), 0, 100)
                };
            }
            bullet.target_type = inst.target_type;
            bullet.damage_type = external_mod_field(cmd, "damage_type", "normal");
            bullet.slow_ticks = clamp(external_mod_field(cmd, "slow_ticks", 0), 0, 3600);
            bullet.owner_card = inst.id;
            bullet.combat_owner = inst.id;
            bullet.mod_card_id = inst.plant_id;
            var key = external_mod_field(cmd, "sprite", "default");
            var anim = external_mod_field(inst.mod_definition.projectiles, key, undefined);
            if (!is_undefined(anim)) {
                bullet.sprite_index = anim.sprite;
                bullet.mod_fps = anim.fps;
                bullet.mod_loop = anim.loop;
                bullet.rules = anim.rules;
                bullet.target_team = anim.rules.target_filter.team;
                bullet.damage_type = external_mod_field(cmd, "damage_type", anim.rules.damage_type);
            }
            break;
        case "damage":
            var target = external_mod_field(cmd, "target", noone);
            // Only enemy handles emitted in context can be targeted; check lifetime and type.
            if (instance_exists(target) && object_is_ancestor(target.object_index, obj_enemy_parent) && can_target_on(inst.target_type, target.target_type)) {
                target.damage_amount = max(0, amount);
                target.damage_type = external_mod_field(cmd, "damage_type", "normal");
                with (target) event_user(0);
            }
            break;
        case "heal": inst.hp = min(inst.max_hp, inst.hp + max(0, amount)); break;
        case "produce": global.flame += max(0, amount); break;
        case "animate": external_mod_animate(inst, external_mod_field(cmd, "name", "idle")); break;
        case "timer":
            if (array_length(inst.mod_timers) < 128) array_push(inst.mod_timers, {ticks: max(1, ceil(external_mod_field(cmd, "seconds", 1) * 60)), name: external_mod_field(cmd, "name", "timer")});
            break;
        case "remove": instance_destroy(inst); break;
        case "log": show_debug_message("[Mod " + inst.plant_id + "] " + string(external_mod_field(cmd, "message", ""))); break;
    }
}

/// Target-owned layers survive the firing card and bullet. No Lua owner is required.
function external_mod_apply_burn(target_inst, burn_rule) {
    if (!instance_exists(target_inst) || target_inst.hp <= 0 || !target_inst.visible || target_inst.is_boss) return;
    if (burn_rule.power <= 0 || (burn_rule.probability < 100 && burn_rule.roll > burn_rule.probability)) return;
    if (!variable_instance_exists(target_inst, "external_mod_burn_layers") || array_length(target_inst.external_mod_burn_layers) == 0) {
        target_inst.external_mod_burn_layers = [];
        target_inst.external_mod_burn_tick = -1;
        target_inst.external_mod_burn_clock = 0;
    }
    array_push(target_inst.external_mod_burn_layers, {duration: burn_rule.duration, power: burn_rule.power});
}

function external_mod_burn_step() {
    if (!instance_exists(obj_battle) || global.is_paused) return;
    // EffectManager in the source ticks every 100 ms (six game frames).
    for (var burn_i = instance_number(obj_enemy_parent) - 1; burn_i >= 0; burn_i--) {
        var burn_target = instance_find(obj_enemy_parent, burn_i);
        if (!instance_exists(burn_target) || !variable_instance_exists(burn_target, "external_mod_burn_layers")) continue;
        if (burn_target.hp <= 0) { burn_target.external_mod_burn_layers = []; continue; }
        var layers = burn_target.external_mod_burn_layers;
        if (array_length(layers) == 0) continue;
        if (++burn_target.external_mod_burn_clock < 6) continue;
        burn_target.external_mod_burn_clock = 0;
        burn_target.external_mod_burn_tick++;
        var total_power = 0;
        for (var layer_i = 0; layer_i < array_length(layers); layer_i++) total_power += layers[layer_i].power;
        if (burn_target.external_mod_burn_tick mod 10 == 0) {
            burn_target.damage_amount = total_power;
            burn_target.damage_type = "true";
            with (burn_target) event_user(0);
            if (!instance_exists(burn_target)) continue;
        }
        var retained_layers = [];
        for (var layer_i = 0; layer_i < array_length(layers); layer_i++) {
            layers[layer_i].duration--;
            if (layers[layer_i].duration > 0) array_push(retained_layers, layers[layer_i]);
        }
        burn_target.external_mod_burn_layers = retained_layers;
    }
}
