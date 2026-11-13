/// Visual-only overrides. Never assign an instance's sprite_index/image_index/mask.
#macro EXTERNAL_ANIMATION_MAX_OVERRIDES 4096
#macro EXTERNAL_ANIMATION_MAX_PACKAGE_BYTES 8589934592
#macro EXTERNAL_ANIMATION_CACHE_BYTES 536870912
#macro EXTERNAL_ANIMATION_LOAD_FRAMES 8
#macro EXTERNAL_ANIMATION_LOAD_MICROSECONDS 4000

global.external_animation_active = false;
global.external_animation_by_sprite = [];
global.external_animation_debug_enabled = false;
global.external_animation_debug_target = noone;
global.external_animation_debug_next_log = 0;
global.external_animation_debug_last_log = "";

/// Only compiled source sprites enter this table. Dynamic replacement IDs and -1
/// are misses, never array growth or string conversions on the drawing path.
function external_animation_lookup(spr, actor = undefined) {
    if (!is_numeric(spr)) return undefined;
    var key = real(spr);
    if (is_nan(key) || is_infinity(key) || key < 0 || key != floor(key) || key >= array_length(global.external_animation_by_sprite)) return undefined;
    var entries = global.external_animation_by_sprite[key];
    if (!is_array(entries)) return undefined;
    for (var i = 0; i < array_length(entries); i++) {
        var d = entries[i];
        if (is_undefined(actor) || actor == d.object_asset || object_is_ancestor(actor, d.object_asset)) return d;
    }
    return undefined;
}

function external_animation_scopes_overlap(left, right) {
    return left.object_asset == right.object_asset
        || object_is_ancestor(left.object_asset, right.object_asset)
        || object_is_ancestor(right.object_asset, left.object_asset);
}

function external_animation_integer(value, minimum, maximum, label) {
    if (!is_numeric(value) || is_nan(value) || is_infinity(value) || floor(value) != value || value < minimum || value > maximum) {
        throw label + " 必须为 " + string(minimum) + "–" + string(maximum) + " 的整数";
    }
    return value;
}

function external_animation_png_validate(path, expected_width, expected_height) {
    var file = file_bin_open(path, 0);
    if (file == -1) throw "无法读取 PNG：" + path;
    var header = array_create(33, 0);
    var valid = file_bin_size(file) >= 33;
    if (valid) for (var i = 0; i < 33; i++) header[i] = file_bin_read_byte(file);
    file_bin_close(file);
    var signature = [137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82];
    for (var i = 0; valid && i < array_length(signature); i++) valid = header[i] == signature[i];
    var w = 0;
    var h = 0;
    if (valid) {
        for (var i = 0; i < 4; i++) {
            w = w * 256 + header[16 + i];
            h = h * 256 + header[20 + i];
        }
    }
    if (!valid || w != expected_width || h != expected_height) throw "覆盖 PNG 必须保持原尺寸：" + path;
}

function external_animation_clock_validate(payload) {
    if (is_string(payload)) {
        if (array_get_index(["card_parent", "enemy_parent", "image_index"], payload) == -1) throw "不支持的动画时钟：" + payload;
        return payload;
    }
    if (!is_struct(payload)) throw "clock 必须是时钟名称或配置对象";
    var clock_type = external_mod_field(payload, "type", "");
    if (clock_type != "counter" && clock_type != "phase") throw "时钟 type 只支持 counter 或 phase";
    var field = external_mod_field(payload, "field", "");
    if (!is_string(field) || field == "" || string_length(field) > 100) throw "时钟 field 必须为实例变量名";
    var offset = external_mod_field(payload, "offset", 0);
    if (!is_numeric(offset) || is_nan(offset) || is_infinity(offset)) throw "时钟 offset 必须为有限数值";
    var clock_direction = external_mod_field(payload, "direction", 1);
    if (clock_direction != 1 && clock_direction != -1) throw "时钟 direction 只能是 1 或 -1";
    var period_field = external_mod_field(payload, "period_field", "");
    var period = external_mod_field(payload, "ticks_per_frame", 1);
    if (!is_string(period_field) || string_length(period_field) > 100) throw "period_field 必须为实例变量名";
    if (!is_numeric(period) || is_nan(period) || is_infinity(period) || period <= 0) throw "ticks_per_frame 必须为正有限数值";
    return {type: clock_type, field: field, offset: offset, direction: clock_direction,
        period_field: period_field, ticks_per_frame: period};
}

/// Validation reads files, but does not allocate textures or execute scripts.
function external_animation_validate(root, manifest) {
    var paths = external_mod_field(manifest, "overrides", []);
    if (!is_array(paths) || array_length(paths) < 1 || array_length(paths) > EXTERNAL_ANIMATION_MAX_OVERRIDES) throw "overrides 需要 1–4096 个配置路径";
    var definitions = [];
    var seen = {};
    var package_bytes = 0;
    for (var i = 0; i < array_length(paths); i++) {
        var config_path = external_mod_path(root, paths[i]);
        var d = json_parse(external_mod_read(config_path));
        if (!is_struct(d)) throw "动画覆盖配置必须为对象";
        d.root = filename_dir(config_path);
        d.sprite = external_mod_field(d, "sprite", "");
        d.object = external_mod_field(d, "object", "");
        if (!is_string(d.sprite) || !is_string(d.object)) throw "sprite 和 object 必须为资源名称";
        d.sprite_asset = asset_get_index(d.sprite);
        d.object_asset = asset_get_index(d.object);
        if (d.sprite_asset == -1 || asset_get_type(d.sprite_asset) != asset_sprite) throw "找不到原版精灵：" + d.sprite;
        if (d.object_asset == -1 || asset_get_type(d.object_asset) != asset_object) throw "找不到原有对象：" + d.object;
        var scopes = external_mod_field(seen, d.sprite, []);
        for (var previous = 0; previous < array_length(scopes); previous++) {
            if (external_animation_scopes_overlap(d, scopes[previous])) throw "同精灵的对象范围重叠：" + d.sprite;
        }
        array_push(scopes, d);
        seen[$ d.sprite] = scopes;
        var source = external_mod_field(d, "source", {});
        var properties = ["frames", "width", "height", "origin_x", "origin_y"];
        var actual = [sprite_get_number(d.sprite_asset), sprite_get_width(d.sprite_asset), sprite_get_height(d.sprite_asset),
            sprite_get_xoffset(d.sprite_asset), sprite_get_yoffset(d.sprite_asset)];
        for (var k = 0; k < array_length(properties); k++) {
            var declared = external_mod_field(source, properties[k], undefined);
            if (!is_numeric(declared) || declared != actual[k]) throw "原素材版本不匹配：" + d.sprite + " / " + properties[k];
        }
        d.source = source;
        var default_clock = "image_index";
        if (d.object_asset == obj_card_parent || object_is_ancestor(d.object_asset, obj_card_parent)) default_clock = "card_parent";
        else if (d.object_asset == obj_enemy_parent || object_is_ancestor(d.object_asset, obj_enemy_parent)) default_clock = "enemy_parent";
        d.clock = external_animation_clock_validate(external_mod_field(d, "clock", default_clock));
        d.clips = external_mod_field(d, "clips", []);
        if (!is_array(d.clips) || array_length(d.clips) < 1 || array_length(d.clips) > 32) throw "clips 需要 1–32 个动作段";
        var covered = array_create(source.frames, false);
        for (var c = 0; c < array_length(d.clips); c++) {
            var clip = d.clips[c];
            if (!is_struct(clip)) throw "动作段必须为对象";
            clip.first = external_animation_integer(external_mod_field(clip, "first", -1), 0, source.frames - 1, "first");
            clip.last = external_animation_integer(external_mod_field(clip, "last", -1), clip.first, source.frames - 1, "last");
            clip.samples_per_frame = external_animation_integer(external_mod_field(clip, "samples_per_frame", 1), 1, 16, "samples_per_frame");
            clip.loop = external_mod_field(clip, "loop", false);
            if (!is_bool(clip.loop)) throw "loop 必须为布尔值";
            clip.clock = external_animation_clock_validate(external_mod_field(clip, "clock", d.clock));
            clip.frames = external_mod_field(clip, "frames", []);
            var expected = (clip.last - clip.first + 1) * clip.samples_per_frame;
            if (!is_array(clip.frames) || array_length(clip.frames) != expected || expected > 4096) throw "动作段 PNG 数量必须等于原帧数 × samples_per_frame，最多 4096 张";
            for (var f = clip.first; f <= clip.last; f++) {
                if (covered[f]) throw "动作段的原帧区间不能重叠";
                covered[f] = true;
            }
            clip.bytes = source.width * source.height * 4 * expected;
            if (clip.bytes > EXTERNAL_ANIMATION_CACHE_BYTES) throw "单个动作解码后超过 512 MiB，请细分动作段";
            package_bytes += clip.bytes;
            if (package_bytes > EXTERNAL_ANIMATION_MAX_PACKAGE_BYTES) throw "动画包解码估算量超过 8 GiB，请拆分素材包";
            for (var f = 0; f < expected; f++) {
                var p = external_mod_path(d.root, clip.frames[f]);
                if (string_lower(filename_ext(p)) != ".png" || !file_exists(p)) throw "PNG 不存在：" + p;
                external_animation_png_validate(p, source.width, source.height);
            }
            clip.sprite_asset = -1;
            clip.loading_sprite = -1;
            clip.loading_index = 0;
            clip.queued = false;
            clip.load_urgent = false;
            clip.failed = false;
            clip.error = "";
            clip.cache_frame = -1;
            clip.cache_used = 0;
            d.clips[c] = clip;
        }
        d.failed = false;
        array_push(definitions, d);
    }
    return {type: "animation_override", root: root, name: external_mod_field(manifest, "name", filename_name(root)), cards: [], overrides: definitions};
}

function external_animation_release() {
    if (!variable_global_exists("external_animation_registry")) return;
    var keys = variable_struct_get_names(global.external_animation_registry);
    for (var i = 0; i < array_length(keys); i++) {
        var d = global.external_animation_registry[$ keys[i]];
        for (var c = 0; c < array_length(d.clips); c++) {
            var clip = d.clips[c];
            if (clip.sprite_asset != -1 && sprite_exists(clip.sprite_asset)) sprite_delete(clip.sprite_asset);
            if (clip.loading_sprite != -1 && sprite_exists(clip.loading_sprite)) sprite_delete(clip.loading_sprite);
            clip.loading_sprite = -1;
            clip.loading_index = 0;
            clip.queued = false;
            clip.load_urgent = false;
            clip.sprite_asset = -1;
            clip.cache_frame = -1;
            clip.cache_used = 0;
        }
    }
    global.external_animation_bytes = 0;
    global.external_animation_loading_bytes = 0;
    global.external_animation_loading_job = undefined;
    global.external_animation_load_queue = [];
    global.external_animation_queued_bytes = 0;
    global.external_animation_cache = [];
    global.external_animation_cache_frame = 0;
    global.external_animation_cache_serial = 0;
}

function external_animation_init() {
    external_animation_release();
    global.external_animation_active = false;
    global.external_animation_registry = {};
    global.external_animation_by_sprite = [];
    global.external_animation_bytes = 0;
    global.external_animation_cache = [];
    global.external_animation_cache_frame = 0;
    global.external_animation_cache_serial = 0;
    global.external_animation_cache_budget = EXTERNAL_ANIMATION_CACHE_BYTES;
    global.external_animation_loading_bytes = 0;
    global.external_animation_loading_job = undefined;
    global.external_animation_load_queue = [];
    global.external_animation_queued_bytes = 0;
}

/// One epoch covers every Draw/Draw GUI event and every view in this game step.
function external_animation_cache_step() {
    if (!global.external_animation_active) return;
    global.external_animation_cache_frame++;
    // Failed clips retire only after all draws that referenced them have ended.
    for (var i = array_length(global.external_animation_cache) - 1; i >= 0; i--) {
        if (global.external_animation_cache[i].clip.failed) external_animation_cache_drop(i);
    }
}

function external_animation_cache_touch(clip) {
    clip.cache_frame = global.external_animation_cache_frame;
    clip.cache_used = ++global.external_animation_cache_serial;
}

function external_animation_cache_drop(cache_index) {
    var clip = global.external_animation_cache[cache_index].clip;
    if (clip.sprite_asset != -1) {
        if (sprite_exists(clip.sprite_asset)) sprite_delete(clip.sprite_asset);
        global.external_animation_bytes -= clip.bytes;
        clip.sprite_asset = -1;
    }
    clip.cache_frame = -1;
    clip.cache_used = 0;
    array_delete(global.external_animation_cache, cache_index, 1);
}

/// Never delete a sprite already sampled this frame: callers can reuse its visual
/// for another overlay and GameMaker can still have pending draw commands for it.
function external_animation_cache_reserve(bytes) {
    var needed = global.external_animation_bytes + global.external_animation_loading_bytes + bytes - global.external_animation_cache_budget;
    if (needed <= 0) return true;
    var available = 0;
    for (var i = 0; i < array_length(global.external_animation_cache); i++) {
        var clip = global.external_animation_cache[i].clip;
        if (clip.cache_frame != global.external_animation_cache_frame) available += clip.bytes;
    }
    if (available < needed) return false;
    while (global.external_animation_bytes + global.external_animation_loading_bytes + bytes > global.external_animation_cache_budget) {
        var oldest_index = -1;
        var oldest_used = global.external_animation_cache_serial + 1;
        for (var i = 0; i < array_length(global.external_animation_cache); i++) {
            var clip = global.external_animation_cache[i].clip;
            if (clip.cache_frame == global.external_animation_cache_frame || clip.cache_used >= oldest_used) continue;
            oldest_index = i;
            oldest_used = clip.cache_used;
        }
        if (oldest_index == -1) return false;
        external_animation_cache_drop(oldest_index);
    }
    return true;
}

function external_animation_register(pack, folder) {
    for (var i = 0; i < array_length(pack.overrides); i++) {
        var d = pack.overrides[i];
        var key = real(d.sprite_asset);
        if (key >= array_length(global.external_animation_by_sprite)) continue;
        var entries = global.external_animation_by_sprite[key];
        if (!is_array(entries)) continue;
        for (var j = 0; j < array_length(entries); j++) {
            if (external_animation_scopes_overlap(d, entries[j])) throw "精灵的对象范围已被其他 Mod 覆盖：" + d.sprite;
        }
    }
    for (var i = 0; i < array_length(pack.overrides); i++) {
        var d = pack.overrides[i];
        d.folder = folder;
        global.external_animation_registry[$ string(d.sprite_asset) + ":" + string(d.object_asset)] = d;
        var key = real(d.sprite_asset);
        var entries = key < array_length(global.external_animation_by_sprite) ? global.external_animation_by_sprite[key] : undefined;
        if (!is_array(entries)) entries = [];
        array_push(entries, d);
        global.external_animation_by_sprite[key] = entries;
    }
    global.external_animation_active = true;
}

function external_animation_fail(d, clip, message) {
    clip.failed = true;
    clip.error = message;
    var detail = d.sprite + " / " + d.object + " / " + external_mod_field(clip, "name", string(clip.first));
    global.external_mod_errors[$ d.folder] = "部分动画已回退：" + detail + "\n" + message;
    show_debug_message("[Animation Mod " + d.folder + "] " + detail + ": " + message);
    // Loaded textures may already be referenced by this frame's draw commands.
    // cache_step retires the failed clip on the following step.
}

function external_animation_load(d, clip) {
    if (clip.failed) return -1;
    if (clip.sprite_asset != -1) {
        external_animation_cache_touch(clip);
        return clip.sprite_asset;
    }
    external_animation_enqueue(d, clip, true);
    return -1;
}

/// Draw requests have priority over speculative warming. Nothing decodes in Draw.
function external_animation_enqueue(d, clip, urgent = false) {
    if (clip.failed || clip.sprite_asset != -1) return false;
    if (clip.queued) {
        if (urgent && !clip.load_urgent && clip.loading_index == 0) {
            for (var i = 0; i < array_length(global.external_animation_load_queue); i++) {
                if (global.external_animation_load_queue[i].clip != clip) continue;
                var waiting = global.external_animation_load_queue[i];
                waiting.urgent = true;
                clip.load_urgent = true;
                array_delete(global.external_animation_load_queue, i, 1);
                array_insert(global.external_animation_load_queue, 0, waiting);
                break;
            }
        }
        return false;
    }
    if (!urgent && global.external_animation_bytes + global.external_animation_loading_bytes
        + global.external_animation_queued_bytes + clip.bytes > global.external_animation_cache_budget) return false;
    if (array_length(global.external_animation_load_queue) >= EXTERNAL_ANIMATION_MAX_OVERRIDES) return false;
    clip.queued = true;
    clip.load_urgent = urgent;
    global.external_animation_queued_bytes += clip.bytes;
    var job = {definition: d, clip: clip, urgent: urgent};
    if (urgent) array_insert(global.external_animation_load_queue, 0, job);
    else array_push(global.external_animation_load_queue, job);
    return true;
}

function external_animation_load_step() {
    if (!global.external_animation_active) return;
    var started = get_timer();
    var frames = 0;
    while (frames < EXTERNAL_ANIMATION_LOAD_FRAMES && get_timer() - started < EXTERNAL_ANIMATION_LOAD_MICROSECONDS) {
        var job = global.external_animation_loading_job;
        if (is_undefined(job)) {
            if (array_length(global.external_animation_load_queue) == 0) return;
            job = global.external_animation_load_queue[0];
            array_delete(global.external_animation_load_queue, 0, 1);
            global.external_animation_queued_bytes -= job.clip.bytes;
            if (job.clip.failed) { job.clip.queued = false; continue; }
            if (!job.urgent && global.external_animation_bytes + job.clip.bytes > global.external_animation_cache_budget) {
                job.clip.queued = false;
                continue;
            }
            if (!external_animation_cache_reserve(job.clip.bytes)) {
                array_push(global.external_animation_load_queue, job);
                global.external_animation_queued_bytes += job.clip.bytes;
                return;
            }
            global.external_animation_loading_job = job;
            global.external_animation_loading_bytes = job.clip.bytes;
        }
        var d = job.definition;
        var clip = job.clip;
        var part = -1;
        try {
            if (clip.failed) throw clip.error;
            part = sprite_add(external_mod_path(d.root, clip.frames[clip.loading_index]), 1, false, false, d.source.origin_x, d.source.origin_y);
            if (part == -1) throw "PNG 解码失败：" + clip.frames[clip.loading_index];
            if (sprite_get_width(part) != d.source.width || sprite_get_height(part) != d.source.height) throw "PNG 尺寸已改变：" + clip.frames[clip.loading_index];
            if (clip.loading_sprite == -1) clip.loading_sprite = part;
            else { sprite_merge(clip.loading_sprite, part); sprite_delete(part); }
            part = -1;
            clip.loading_index++;
            frames++;
            if (clip.loading_index == array_length(clip.frames)) {
                clip.sprite_asset = clip.loading_sprite;
                clip.loading_sprite = -1;
                clip.loading_index = 0;
                clip.queued = false;
                global.external_animation_loading_bytes = 0;
                global.external_animation_loading_job = undefined;
                global.external_animation_bytes += clip.bytes;
                external_animation_cache_touch(clip);
                array_push(global.external_animation_cache, {clip: clip, folder: d.folder});
            }
        } catch (error_data) {
            if (part != -1 && part != clip.loading_sprite && sprite_exists(part)) sprite_delete(part);
            if (clip.loading_sprite != -1 && sprite_exists(clip.loading_sprite)) sprite_delete(clip.loading_sprite);
            clip.loading_sprite = -1;
            clip.loading_index = 0;
            clip.queued = false;
            global.external_animation_loading_bytes = 0;
            global.external_animation_loading_job = undefined;
            if (!clip.failed) external_animation_fail(d, clip, external_mod_error_text(error_data));
        }
    }
}

/// Source integration API: warm an object's clips without changing game clocks.
function external_animation_prewarm_object(actor) {
    if (!global.external_animation_active) return;
    var keys = variable_struct_get_names(global.external_animation_registry);
    for (var i = 0; i < array_length(keys); i++) {
        var d = global.external_animation_registry[$ keys[i]];
        if (actor != d.object_asset && !object_is_ancestor(actor, d.object_asset)) continue;
        for (var c = 0; c < array_length(d.clips); c++) external_animation_enqueue(d, d.clips[c]);
    }
}

function external_animation_prewarm_deck() {
    if (!global.external_animation_active || !variable_global_exists("selected_deck")) return;
    if (!ds_exists(global.selected_deck, ds_type_list)) return;
    if (!variable_global_exists("_obj_pool_deck_map")) global._obj_pool_deck_map = obj_pool_build_deck_map();
    for (var i = 0; i < ds_list_size(global.selected_deck); i++) {
        var entry = global.selected_deck[| i];
        if (!ds_exists(entry, ds_type_map) || !ds_map_exists(entry, "data")) continue;
        var data = entry[? "data"];
        if (!ds_exists(data, ds_type_map) || !ds_map_exists(data, "obj")) continue;
        var actor = data[? "obj"];
        external_animation_prewarm_object(actor);
        var related = external_mod_field(global._obj_pool_deck_map, object_get_name(actor), []);
        for (var j = 0; j < array_length(related); j++) external_animation_prewarm_object(related[j]);
    }
}

function external_animation_sync(inst, period, counter = undefined, label = "card_parent", explicit_clock = false) {
    var inspecting = global.external_animation_debug_enabled && inst == global.external_animation_debug_target;
    if (!global.external_animation_active && !inspecting) return;
    // The parent Step can destroy a dying card before reaching the clock hook.
    if (!instance_exists(inst)) return;
    if (is_undefined(external_animation_lookup(inst.sprite_index, inst.object_index)) && !inspecting) return;
    if (is_undefined(counter)) counter = inst.timer;
    inst.external_animation_snapshot = {sprite: inst.sprite_index, frame: inst.image_index, timer: counter,
        state: inst.state, period: max(1, period), label: label, explicit_clock: explicit_clock};
}

/// Call at the original controller's frame assignment, before a later timer++ or
/// state transition. A skipped Step leaves this snapshot and its phase untouched.
function external_animation_sync_native(inst, period, counter = undefined, label = "timer") {
    if (!global.external_animation_active && !global.external_animation_debug_enabled) return;
    external_animation_sync(inst, period, counter, label, true);
}

function external_animation_clock_number(inst, field) {
    if (!variable_instance_exists(inst, field)) throw "动画时钟缺少实例变量：" + field;
    var value = variable_instance_get(inst, field);
    if (!is_numeric(value) || is_nan(value) || is_infinity(value)) throw "动画时钟变量必须为有限数值：" + field;
    return value;
}

function external_animation_phase(inst, clock, source_sprite, source_frame, trace = undefined) {
    if (is_struct(clock)) {
        var value = external_animation_clock_number(inst, clock.field) + clock.offset;
        if (clock.type == "counter") {
            var period = clock.period_field == "" ? clock.ticks_per_frame : external_animation_clock_number(inst, clock.period_field);
            if (period <= 0) throw "动画时钟换帧周期必须大于零";
            value /= period;
        }
        if (is_struct(trace)) {
            trace.clock_source = clock.type + ":" + clock.field;
            trace.period = clock.type == "counter" ? period : 1;
            trace.counter = external_animation_clock_number(inst, clock.field);
        }
        if (is_nan(value) || is_infinity(value)) throw "动画时钟计算结果必须为有限数值";
        return value - floor(value);
    }
    // A fractional native frame is an observable clock, including automatic
    // image_speed animation. It does not need an estimated wall-clock fallback.
    if (clock == "image_index" || (clock == "card_parent"
        && (inst.image_speed != 0 || source_frame != floor(source_frame)))) {
        if (is_struct(trace)) { trace.clock_source = "image_index"; trace.counter = source_frame; }
        return source_frame - floor(source_frame);
    }
    if (clock == "enemy_parent") {
        var period = external_animation_clock_number(inst, "flash_speed");
        if (period <= 0) throw "敌鼠动画换帧周期必须大于零";
        var value = external_animation_clock_number(inst, "timer") / period;
        if (is_struct(trace)) { trace.clock_source = "enemy_parent"; trace.period = period; trace.counter = inst.timer; }
        if (is_nan(value) || is_infinity(value)) throw "敌鼠动画时钟计算结果必须为有限数值";
        return value - floor(value);
    }
    if (variable_instance_exists(inst, "external_animation_snapshot")) {
        var snapshot = inst.external_animation_snapshot;
        if (!is_undefined(snapshot) && snapshot.sprite == source_sprite && snapshot.frame == source_frame && snapshot.state == inst.state
            && (snapshot.explicit_clock || inst.state == CARD_STATE.IDLE || inst.state == CARD_STATE.ATTACK)) {
            if (is_struct(trace)) { trace.clock_source = snapshot.label; trace.period = snapshot.period; trace.counter = snapshot.timer; }
            var value = snapshot.timer / snapshot.period;
            return snapshot.explicit_clock ? value - floor(value) : clamp(value, 0, 0.999999);
        }
        if (is_struct(trace)) trace.clock_source = "snapshot_mismatch";
    } else if (is_struct(trace)) {
        trace.clock_source = "missing_snapshot";
    }
    return 0;
}

/// Optional arguments also map auxiliary sprites and clipped Draw calls. A struct
/// method or global draw has no instance scope and must keep the native result.
function external_animation_sample(inst, requested_sprite = undefined, requested_frame = undefined, inspect_only = false) {
    var valid_instance = !is_struct(inst) && instance_exists(inst);
    if (is_undefined(requested_sprite)) requested_sprite = valid_instance ? inst.sprite_index : -1;
    if (is_undefined(requested_frame)) requested_frame = valid_instance ? inst.image_index : 0;
    var original = {sprite: requested_sprite, frame: requested_frame};
    if (!global.external_animation_active && !inspect_only) return original;
    var trace = undefined;
    if (inspect_only) trace = {object: valid_instance ? object_get_name(inst.object_index) : "none",
        sprite: requested_sprite, raw_frame: requested_frame, source_frame: floor(requested_frame),
        clock: "", clock_source: "", counter: 0, period: 1, fraction: 0, clip: "", first: -1, last: -1,
        samples_per_frame: 0, sample: -1, cached: false, folder: "", reason: "no_override", error: ""};
    var d = external_animation_lookup(requested_sprite, valid_instance ? inst.object_index : undefined);
    if (is_undefined(d) || !valid_instance) {
        if (!inspect_only) return original;
        if (!is_undefined(external_animation_lookup(requested_sprite))) trace.reason = "object_mismatch";
        if (valid_instance) {
            var clock = "image_index";
            if (inst.object_index == obj_card_parent || object_is_ancestor(inst.object_index, obj_card_parent)) clock = "card_parent";
            else if (inst.object_index == obj_enemy_parent || object_is_ancestor(inst.object_index, obj_enemy_parent)) clock = "enemy_parent";
            trace.clock = clock;
            try { trace.fraction = external_animation_phase(inst, clock, requested_sprite, requested_frame, trace); }
            catch (error_data) { trace.reason = "clock_error"; trace.error = external_mod_error_text(error_data); }
        }
        return trace;
    }
    if (inspect_only) trace.folder = d.folder;
    if (d.failed) {
        if (inspect_only) {
            trace.reason = "pack_failed";
            trace.error = external_mod_field(global.external_mod_errors, d.folder, "");
            return trace;
        }
        return original;
    }
    if (!(inst.object_index == d.object_asset || object_is_ancestor(inst.object_index, d.object_asset))) {
        if (inspect_only) { trace.reason = "object_mismatch"; return trace; }
        return original;
    }
    // Native draw_sprite* accepts -1 as the instance's current subimage.
    var frame_value = requested_frame == -1 ? inst.image_index : requested_frame;
    var source_frame = ((floor(frame_value) mod d.source.frames) + d.source.frames) mod d.source.frames;
    if (inspect_only) { trace.source_frame = source_frame; trace.reason = "no_clip"; }
    for (var i = 0; i < array_length(d.clips); i++) {
        var clip = d.clips[i];
        if (source_frame < clip.first || source_frame > clip.last) continue;
        if (inspect_only) {
            trace.clip = external_mod_field(clip, "name", string(i)); trace.first = clip.first; trace.last = clip.last;
            trace.samples_per_frame = clip.samples_per_frame;
            trace.clock = is_struct(clip.clock) ? clip.clock.type : clip.clock;
        }
        if (clip.failed) {
            if (inspect_only) { trace.reason = "clip_failed"; trace.error = clip.error; return trace; }
            return original;
        }
        var fraction;
        try { fraction = external_animation_phase(inst, clip.clock, requested_sprite, frame_value, trace); }
        catch (error_data) {
            if (inspect_only) { trace.reason = "clock_error"; trace.error = external_mod_error_text(error_data); return trace; }
            external_animation_fail(d, clip, external_mod_error_text(error_data));
            return original;
        }
        var frame = source_frame;
        if (is_struct(clip.clock) && clip.clock.direction == -1 && fraction > 0) {
            if (frame > clip.first) frame--;
            else if (clip.loop) frame = clip.last;
            else fraction = 0;
            if (fraction > 0) fraction = 1 - fraction;
        }
        var sample = (frame - clip.first) * clip.samples_per_frame + min(clip.samples_per_frame - 1, floor(fraction * clip.samples_per_frame));
        if (inspect_only) {
            trace.fraction = fraction; trace.sample = sample; trace.cached = clip.sprite_asset != -1;
            trace.reason = trace.cached ? "override" : (clip.queued ? "loading" : "not_loaded");
            if (!trace.cached && !clip.queued && global.external_animation_bytes + global.external_animation_loading_bytes + clip.bytes > global.external_animation_cache_budget) {
                var available = global.external_animation_cache_budget - global.external_animation_bytes - global.external_animation_loading_bytes;
                for (var j = 0; j < array_length(global.external_animation_cache); j++) {
                    var old = global.external_animation_cache[j].clip;
                    if (old.cache_frame != global.external_animation_cache_frame) available += old.bytes;
                }
                if (available < clip.bytes) trace.reason = "cache_pressure";
            }
            return trace;
        }
        var replacement = external_animation_load(d, clip);
        if (replacement == -1) return original;
        return {sprite: replacement, frame: sample};
    }
    return inspect_only ? trace : original;
}

/// Read-only diagnostics: never decode PNGs, reserve cache or disable a package.
function external_animation_inspect(inst, spr = undefined, frame = undefined) {
    return external_animation_sample(inst, spr, frame, true);
}

function external_animation_debug_step() {
    if (!keyboard_check(vk_control) || !keyboard_check(vk_shift)) return;
    if (keyboard_check_pressed(vk_f8)) {
        global.external_animation_debug_enabled = !global.external_animation_debug_enabled;
        global.external_animation_debug_next_log = 0;
        global.external_animation_debug_last_log = "";
    }
    if (!global.external_animation_debug_enabled || !keyboard_check_pressed(vk_f7)) return;
    var selected = noone;
    var front_depth = 2147483647;
    for (var i = 0; i < instance_count; i++) {
        var candidate = instance_find(all, i);
        if (!candidate.visible || candidate.sprite_index == -1 || candidate.image_alpha <= 0) continue;
        if (!point_in_rectangle(mouse_x, mouse_y, candidate.bbox_left, candidate.bbox_top, candidate.bbox_right, candidate.bbox_bottom)) continue;
        if (candidate.depth < front_depth) { selected = candidate; front_depth = candidate.depth; }
    }
    global.external_animation_debug_target = selected;
    global.external_animation_debug_next_log = 0;
    global.external_animation_debug_last_log = "";
}

function external_animation_debug_draw() {
    if (!global.external_animation_debug_enabled) return;
    var text = "动画诊断  Ctrl+Shift+F8 开关 / Ctrl+Shift+F7 选择光标下对象";
    var selected = global.external_animation_debug_target;
    if (!instance_exists(selected)) {
        text += "\n将鼠标移到对象上，按 Ctrl+Shift+F7 查看真实动画时钟。";
    } else {
        var trace = external_animation_inspect(selected);
        var sprite_name = sprite_exists(trace.sprite) ? sprite_get_name(trace.sprite) : "none";
        text += "\n对象 " + trace.object + "  #" + string(real(selected)) + "  精灵 " + sprite_name;
        text += "\n原帧 " + string(trace.raw_frame) + " → " + string(trace.source_frame);
        text += "  状态 " + string(external_animation_instance_field(selected, "state", "-"));
        text += "  暂停 " + string(global.is_paused) + "  冻结 " + string(external_animation_instance_field(selected, "is_frozen", false));
        text += "\n时钟 " + trace.clock + " → " + trace.clock_source;
        text += "  计时 " + string(trace.counter) + " / " + string(trace.period) + "  进度 " + string_format(trace.fraction, 1, 3);
        text += "\n动作 " + trace.clip + " [" + string(trace.first) + ", " + string(trace.last) + "]";
        text += "  每帧样本 " + string(trace.samples_per_frame) + "  样本索引 " + string(trace.sample);
        text += "\n结果 " + trace.reason + "  包 " + trace.folder + "  已缓存 " + string(trace.cached);
        if (trace.error != "") text += "\n" + trace.error;
        text += "\n缓存 " + string_format(global.external_animation_bytes / 1048576, 1, 1)
            + " / " + string(global.external_animation_cache_budget / 1048576) + " MiB"
            + "  加载预留 " + string_format(global.external_animation_loading_bytes / 1048576, 1, 1) + " MiB";
        // At most four lines per second, only for the selected instance and only
        // when its state changes. Never print from every draw wrapper.
        if (current_time >= global.external_animation_debug_next_log) {
            global.external_animation_debug_next_log = current_time + 250;
            var record = trace.object + " sprite=" + sprite_name + " frame=" + string(trace.raw_frame)
                + " clock=" + trace.clock_source + " counter=" + string(trace.counter) + "/" + string(trace.period)
                + " fraction=" + string_format(trace.fraction, 1, 3) + " clip=" + trace.clip
                + " sample=" + string(trace.sample) + " result=" + trace.reason;
            if (record != global.external_animation_debug_last_log) {
                show_debug_message("[Animation] " + record);
                global.external_animation_debug_last_log = record;
            }
        }
    }
    var old_font = draw_get_font();
    var old_colour = draw_get_color();
    var old_alpha = draw_get_alpha();
    var old_halign = draw_get_halign();
    var old_valign = draw_get_valign();
    draw_set_font(font_yuan);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    var panel_width = max(100, min(1050, display_get_gui_width() - 48));
    var panel_height = string_height_ext(text, -1, panel_width - 24) + 24;
    draw_set_alpha(0.88);
    draw_set_color(c_black);
    draw_rectangle(16, 16, 16 + panel_width, 16 + panel_height, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text_ext(28, 28, text, -1, panel_width - 24);
    draw_set_font(old_font);
    draw_set_color(old_colour);
    draw_set_alpha(old_alpha);
    draw_set_halign(old_halign);
    draw_set_valign(old_valign);
}

function external_animation_instance_field(inst, field, fallback) {
    return variable_instance_exists(inst, field) ? variable_instance_get(inst, field) : fallback;
}

/// The draw hooks use the same nonrecursive native aliases as the object-pool
/// hooks. They preserve all transform, colour, alpha, crop and shader state.
function external_animation_draw_self() {
    if (!global.external_animation_active) { draw_self_origfunc(); return; }
    if (is_struct(self) || !instance_exists(self)) { draw_self_origfunc(); return; }
    var visual = external_animation_sample(self);
    if (visual.sprite == sprite_index && visual.frame == image_index) { draw_self_origfunc(); return; }
    draw_sprite_ext_origfunc(visual.sprite, visual.frame, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
}

function external_animation_draw_sprite(spr, subimg, px, py) {
    if (!global.external_animation_active) { draw_sprite_origfunc(spr, subimg, px, py); return; }
    var visual = external_animation_sample(self, spr, subimg);
    draw_sprite_origfunc(visual.sprite, visual.frame, px, py);
}

function external_animation_draw_sprite_ext(spr, subimg, px, py, sx, sy, rotation, colour, alpha) {
    if (!global.external_animation_active) { draw_sprite_ext_origfunc(spr, subimg, px, py, sx, sy, rotation, colour, alpha); return; }
    var visual = external_animation_sample(self, spr, subimg);
    draw_sprite_ext_origfunc(visual.sprite, visual.frame, px, py, sx, sy, rotation, colour, alpha);
}

function external_animation_draw_sprite_part(spr, subimg, left, top, width, height, px, py) {
    if (!global.external_animation_active) { draw_sprite_part_origfunc(spr, subimg, left, top, width, height, px, py); return; }
    var visual = external_animation_sample(self, spr, subimg);
    draw_sprite_part_origfunc(visual.sprite, visual.frame, left, top, width, height, px, py);
}

function external_animation_draw_sprite_part_ext(spr, subimg, left, top, width, height, px, py, sx, sy, colour, alpha) {
    if (!global.external_animation_active) { draw_sprite_part_ext_origfunc(spr, subimg, left, top, width, height, px, py, sx, sy, colour, alpha); return; }
    var visual = external_animation_sample(self, spr, subimg);
    draw_sprite_part_ext_origfunc(visual.sprite, visual.frame, left, top, width, height, px, py, sx, sy, colour, alpha);
}
