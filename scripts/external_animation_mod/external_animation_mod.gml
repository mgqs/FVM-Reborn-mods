/// Visual-only overrides. Never assign an instance's sprite_index/image_index/mask.
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

/// Validation reads files, but does not allocate textures or execute scripts.
function external_animation_validate(root, manifest) {
    var paths = external_mod_field(manifest, "overrides", []);
    if (!is_array(paths) || array_length(paths) < 1 || array_length(paths) > 128) throw "overrides 需要 1–128 个配置路径";
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
        if (d.object_asset == -1 || asset_get_type(d.object_asset) != asset_object) throw "找不到卡片对象：" + d.object;
        if (d.object_asset == obj_external_mod_card || !object_is_ancestor(d.object_asset, obj_card_parent)) throw "动画覆盖仅支持原有卡片对象：" + d.object;
        if (d.object_asset == obj_player_character || object_is_ancestor(d.object_asset, obj_player_character)) throw "玩家角色使用独立绘制，暂不支持动画覆盖";
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
        d.clock = external_mod_field(d, "clock", "card_parent");
        if (d.clock != "card_parent" && d.clock != "image_index") throw "clock 只支持 card_parent 或 image_index";
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
            clip.frames = external_mod_field(clip, "frames", []);
            var expected = (clip.last - clip.first + 1) * clip.samples_per_frame;
            if (!is_array(clip.frames) || array_length(clip.frames) != expected || expected > 4096) throw "动作段 PNG 数量必须等于原帧数 × samples_per_frame，最多 4096 张";
            for (var f = clip.first; f <= clip.last; f++) {
                if (covered[f]) throw "动作段的原帧区间不能重叠";
                covered[f] = true;
            }
            clip.bytes = source.width * source.height * 4 * expected;
            package_bytes += clip.bytes;
            if (package_bytes > 268435456) throw "动画包解码后超过 256 MiB，请拆分素材";
            for (var f = 0; f < expected; f++) {
                var p = external_mod_path(d.root, clip.frames[f]);
                if (string_lower(filename_ext(p)) != ".png" || !file_exists(p)) throw "PNG 不存在：" + p;
                external_animation_png_validate(p, source.width, source.height);
            }
            clip.sprite_asset = -1;
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
        }
    }
    global.external_animation_bytes = 0;
}

function external_animation_init() {
    external_animation_release();
    global.external_animation_registry = {};
    global.external_animation_bytes = 0;
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
            global.external_animation_bytes -= clip.bytes;
        }
    }
}

/// Shared, lazy textures. Temporary sprites are deleted immediately after merging.
function external_animation_load(d, clip) {
    if (clip.sprite_asset != -1) return clip.sprite_asset;
    var result = -1;
    var part = -1;
    try {
        if (global.external_animation_bytes + clip.bytes > 268435456) throw "当前场景动画覆盖缓存超过 256 MiB";
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

function external_animation_sample(inst) {
    var original = {sprite: inst.sprite_index, frame: inst.image_index};
    if (!variable_global_exists("external_animation_registry")) return original;
    var d = external_mod_field(global.external_animation_registry, string(inst.sprite_index), undefined);
    if (is_undefined(d) || d.failed || !(inst.object_index == d.object_asset || object_is_ancestor(inst.object_index, d.object_asset))) return original;
    var source_frame = ((floor(inst.image_index) mod d.source.frames) + d.source.frames) mod d.source.frames;
    var fraction = 0;
    if (d.clock == "image_index") fraction = inst.image_index - floor(inst.image_index);
    else if (variable_instance_exists(inst, "external_animation_snapshot")) {
        var snapshot = inst.external_animation_snapshot;
        // Child Step events may switch state/sprite or drive their own frame index.
        if (!is_undefined(snapshot) && snapshot.sprite == inst.sprite_index && snapshot.frame == inst.image_index && snapshot.state == inst.state
            && (inst.state == CARD_STATE.IDLE || inst.state == CARD_STATE.ATTACK)) {
            fraction = clamp(snapshot.timer / snapshot.period, 0, 0.999999);
        }
    }
    for (var i = 0; i < array_length(d.clips); i++) {
        var clip = d.clips[i];
        if (source_frame < clip.first || source_frame > clip.last) continue;
        var replacement = external_animation_load(d, clip);
        if (replacement == -1) return original;
        return {sprite: replacement, frame: (source_frame - clip.first) * clip.samples_per_frame + floor(fraction * clip.samples_per_frame)};
    }
    return original;
}
