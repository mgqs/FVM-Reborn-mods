/// Visual-only overrides. Never assign an instance's sprite_index/image_index/mask.
#macro EXTERNAL_ANIMATION_MAX_OVERRIDES 4096
#macro EXTERNAL_ANIMATION_MAX_PACKAGE_BYTES 8589934592
#macro EXTERNAL_ANIMATION_CACHE_BYTES 536870912

global.external_animation_active = false;

function external_animation_integer(value, minimum, maximum, label) {
    if (!is_numeric(value) || is_nan(value) || is_infinity(value) || floor(value) != value || value < minimum || value > maximum) {
        throw label + " 必须为 " + string(minimum) + "–" + string(maximum) + " 的整数";
    }
    return value;
}

function external_animation_png_validate(path, expected_width, expected_height) {
    var b = buffer_load(path);
    if (!buffer_exists(b)) throw "无法读取 PNG：" + path;
    var valid = buffer_get_size(b) >= 33;
    var signature = [137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82];
    for (var i = 0; valid && i < array_length(signature); i++) valid = buffer_peek(b, i, buffer_u8) == signature[i];
    var w = 0;
    var h = 0;
    if (valid) {
        for (var i = 0; i < 4; i++) {
            w = w * 256 + buffer_peek(b, 16 + i, buffer_u8);
            h = h * 256 + buffer_peek(b, 20 + i, buffer_u8);
        }
    }
    buffer_delete(b);
    if (!valid || w != expected_width || h != expected_height) throw "覆盖 PNG 必须保持原尺寸：" + path;
}

/// A clock only reads existing animation state; it never advances game time.
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
        if (variable_struct_exists(seen, d.sprite)) throw "重复覆盖精灵：" + d.sprite;
        seen[$ d.sprite] = true;
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
            clip.sprite_asset = -1;
            clip.cache_frame = -1;
            clip.cache_used = 0;
        }
    }
    global.external_animation_bytes = 0;
    global.external_animation_cache = [];
    global.external_animation_cache_frame = 0;
    global.external_animation_cache_serial = 0;
}

function external_animation_init() {
    external_animation_release();
    global.external_animation_active = false;
    global.external_animation_registry = {};
    global.external_animation_bytes = 0;
    global.external_animation_cache = [];
    global.external_animation_cache_frame = 0;
    global.external_animation_cache_serial = 0;
    global.external_animation_cache_budget = EXTERNAL_ANIMATION_CACHE_BYTES;
}

/// One epoch covers every Draw/Draw GUI event and every view in this game step.
function external_animation_cache_step() {
    if (global.external_animation_active) global.external_animation_cache_frame++;
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
    var needed = global.external_animation_bytes + bytes - global.external_animation_cache_budget;
    if (needed <= 0) return true;
    var available = 0;
    for (var i = 0; i < array_length(global.external_animation_cache); i++) {
        var clip = global.external_animation_cache[i].clip;
        if (clip.cache_frame != global.external_animation_cache_frame) available += clip.bytes;
    }
    if (available < needed) return false;
    while (global.external_animation_bytes + bytes > global.external_animation_cache_budget) {
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
    // Check the entire package before publishing any entries.
    for (var i = 0; i < array_length(pack.overrides); i++) {
        var d = pack.overrides[i];
        if (variable_struct_exists(global.external_animation_registry, string(d.sprite_asset))) throw "精灵已被其他 Mod 覆盖：" + d.sprite;
    }
    for (var i = 0; i < array_length(pack.overrides); i++) {
        var d = pack.overrides[i];
        d.folder = folder;
        global.external_animation_registry[$ string(d.sprite_asset)] = d;
    }
    global.external_animation_active = true;
}

function external_animation_fail(folder, message) {
    global.external_mod_errors[$ folder] = message;
    show_debug_message("[Animation Mod " + folder + "] " + message);
    var keys = variable_struct_get_names(global.external_animation_registry);
    for (var i = 0; i < array_length(keys); i++) {
        var d = global.external_animation_registry[$ keys[i]];
        if (d.folder != folder) continue;
        d.failed = true;
        for (var c = 0; c < array_length(d.clips); c++) {
            var clip = d.clips[c];
            if (clip.sprite_asset == -1) continue;
            if (sprite_exists(clip.sprite_asset)) sprite_delete(clip.sprite_asset);
            clip.sprite_asset = -1;
            clip.cache_frame = -1;
            clip.cache_used = 0;
            global.external_animation_bytes -= clip.bytes;
        }
    }
    for (var i = array_length(global.external_animation_cache) - 1; i >= 0; i--) {
        if (global.external_animation_cache[i].folder == folder) array_delete(global.external_animation_cache, i, 1);
    }
}

/// Shared, lazy textures. Temporary sprites are deleted immediately after merging.
function external_animation_load(d, clip) {
    if (clip.sprite_asset != -1) {
        external_animation_cache_touch(clip);
        return clip.sprite_asset;
    }
    // A busy frame falls back only for this draw and retries when space is free.
    if (!external_animation_cache_reserve(clip.bytes)) return -1;
    var result = -1;
    var part = -1;
    try {
        for (var i = 0; i < array_length(clip.frames); i++) {
            part = sprite_add(external_mod_path(d.root, clip.frames[i]), 1, false, false, d.source.origin_x, d.source.origin_y);
            if (part == -1) throw "PNG 解码失败：" + clip.frames[i];
            if (sprite_get_width(part) != d.source.width || sprite_get_height(part) != d.source.height) throw "PNG 尺寸已改变：" + clip.frames[i];
            if (result == -1) result = part;
            else { sprite_merge(result, part); sprite_delete(part); }
            part = -1;
        }
        clip.sprite_asset = result;
        global.external_animation_bytes += clip.bytes;
        external_animation_cache_touch(clip);
        array_push(global.external_animation_cache, {clip: clip, folder: d.folder});
        return result;
    } catch (error_data) {
        if (part != -1 && part != result && sprite_exists(part)) sprite_delete(part);
        if (result != -1 && sprite_exists(result)) sprite_delete(result);
        external_animation_fail(d.folder, external_mod_error_text(error_data));
        return -1;
    }
}

/// Called only where the original parent actually advances its animation clock.
/// Pausing/freezing leaves the previous sample intact; Draw never advances time.
function external_animation_sync(inst, period) {
    // The parent Step can destroy a dying card before reaching the clock hook.
    if (!instance_exists(inst)) return;
    if (!variable_global_exists("external_animation_registry")) return;
    if (!variable_struct_exists(global.external_animation_registry, string(inst.sprite_index))) return;
    inst.external_animation_snapshot = {sprite: inst.sprite_index, frame: inst.image_index, timer: inst.timer,
        state: inst.state, period: max(1, period)};
}

function external_animation_clock_number(inst, field) {
    if (!variable_instance_exists(inst, field)) throw "动画时钟缺少实例变量：" + field;
    var value = variable_instance_get(inst, field);
    if (!is_numeric(value) || is_nan(value) || is_infinity(value)) throw "动画时钟变量必须为有限数值：" + field;
    return value;
}

function external_animation_phase(inst, clock, source_sprite, source_frame) {
    if (is_struct(clock)) {
        var value = external_animation_clock_number(inst, clock.field) + clock.offset;
        if (clock.type == "counter") {
            var period = clock.period_field == "" ? clock.ticks_per_frame : external_animation_clock_number(inst, clock.period_field);
            if (period <= 0) throw "动画时钟换帧周期必须大于零";
            value /= period;
        }
        if (is_nan(value) || is_infinity(value)) throw "动画时钟计算结果必须为有限数值";
        return value - floor(value);
    }
    if (clock == "image_index") return source_frame - floor(source_frame);
    if (clock == "enemy_parent") {
        var period = external_animation_clock_number(inst, "flash_speed");
        if (period <= 0) throw "敌鼠动画换帧周期必须大于零";
        var value = external_animation_clock_number(inst, "timer") / period;
        if (is_nan(value) || is_infinity(value)) throw "敌鼠动画时钟计算结果必须为有限数值";
        return value - floor(value);
    }
    if (variable_instance_exists(inst, "external_animation_snapshot")) {
        var snapshot = inst.external_animation_snapshot;
        if (!is_undefined(snapshot) && snapshot.sprite == source_sprite && snapshot.frame == source_frame && snapshot.state == inst.state
            && (inst.state == CARD_STATE.IDLE || inst.state == CARD_STATE.ATTACK)) {
            return clamp(snapshot.timer / snapshot.period, 0, 0.999999);
        }
    }
    return 0;
}

/// Optional arguments also map auxiliary sprites and clipped Draw calls. A struct
/// method or global draw has no instance scope and must keep the native result.
function external_animation_sample(inst, requested_sprite = undefined, requested_frame = undefined) {
    var valid_instance = !is_struct(inst) && instance_exists(inst);
    if (is_undefined(requested_sprite)) requested_sprite = valid_instance ? inst.sprite_index : -1;
    if (is_undefined(requested_frame)) requested_frame = valid_instance ? inst.image_index : 0;
    var original = {sprite: requested_sprite, frame: requested_frame};
    if (!variable_global_exists("external_animation_registry")) return original;
    var d = external_mod_field(global.external_animation_registry, string(requested_sprite), undefined);
    if (is_undefined(d) || d.failed || !valid_instance) return original;
    if (!(inst.object_index == d.object_asset || object_is_ancestor(inst.object_index, d.object_asset))) return original;
    // Native draw_sprite* accepts -1 as the instance's current subimage.
    var frame_value = requested_frame == -1 ? inst.image_index : requested_frame;
    var source_frame = ((floor(frame_value) mod d.source.frames) + d.source.frames) mod d.source.frames;
    for (var i = 0; i < array_length(d.clips); i++) {
        var clip = d.clips[i];
        if (source_frame < clip.first || source_frame > clip.last) continue;
        var fraction;
        try { fraction = external_animation_phase(inst, clip.clock, requested_sprite, frame_value); }
        catch (error_data) {
            external_animation_fail(d.folder, external_mod_error_text(error_data));
            return original;
        }
        var replacement = external_animation_load(d, clip);
        if (replacement == -1) return original;
        var frame = source_frame;
        if (is_struct(clip.clock) && clip.clock.direction == -1 && fraction > 0) {
            if (frame > clip.first) frame--;
            else if (clip.loop) frame = clip.last;
            else fraction = 0;
            if (fraction > 0) fraction = 1 - fraction;
        }
        return {sprite: replacement, frame: (frame - clip.first) * clip.samples_per_frame + min(clip.samples_per_frame - 1, floor(fraction * clip.samples_per_frame))};
    }
    return original;
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
