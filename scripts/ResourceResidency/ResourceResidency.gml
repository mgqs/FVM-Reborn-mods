/// Desktop packages keep UI/fonts resident; larger groups live on disk until needed.
/// Keep implicit loading as a fallback for custom stages and Mod-created objects.
function resource_memory_enabled() {
    static _enabled = undefined;
    if (is_undefined(_enabled)) {
        // IDE builds on affected runtimes can ignore configuration overrides.
        // Use the original loading/audio buses unless external assets exist.
        _enabled = (os_type == os_macosx || os_type == os_windows)
            && file_exists(working_directory + "cards_0.yytex")
            && file_exists(working_directory + "enemy_longyuan_0.yytex")
            && file_exists(working_directory + "mus_town.ogg");
    }
    return _enabled;
}

function resource_dynamic_groups() {
    static _groups = ["cards", "player", "maps", "bullet", "effects", "time_god",
        "enemy_delicious", "enemy_volcanic", "enemy_floating", "enemy_tower",
        "pack_undersea_vortex", "pack_explore_camp", "enemy_longyuan", "battle_misc", "cards_ui"];
    return _groups;
}

function resource_texture_prepare(_group) {
    if (resource_memory_enabled() && _group == "maps") {
        resource_scene_maps(room);
        return true;
    }
    if (resource_memory_enabled() && array_get_index(resource_dynamic_groups(), _group) >= 0) {
        if (texturegroup_get_status(_group) == texturegroup_status_unloaded) {
            if (texturegroup_load(_group, false) < 0) return false;
        }
    }
    texture_prefetch(_group);
    return true;
}

/// Fetch the pages for this background sprite, not the whole map library.
function resource_scene_maps(_room) {
    if (_room == room_menu) sprite_prefetch(spr_town);
    if (_room == room_map && variable_global_exists("maps_map") && variable_global_exists("map_id")
        && ds_map_exists(global.maps_map, global.map_id)) {
        var _map = global.maps_map[? global.map_id];
        if (variable_struct_exists(_map, "map_sprite")) sprite_prefetch(_map.map_sprite);
    }
    if (_room == room_ready) sprite_prefetch(spr_reday_room);
    if ((_room == room_ready || _room == room_battle || _room == room_tower_cake)
        && variable_global_exists("level_data") && is_struct(global.level_data)
        && variable_struct_exists(global.level_data, "level_sprite")) {
        sprite_prefetch(global.level_data.level_sprite);
    }
}

function resource_add_group(_groups, _group) {
    if (_group != "" && array_get_index(_groups, _group) < 0) array_push(_groups, _group);
    return _groups;
}

function resource_add_sprite_group(_groups, _sprite) {
    if (is_undefined(_sprite) || _sprite == -1 || !sprite_exists(_sprite)) return _groups;
    if (!variable_global_exists("resource_sprite_groups")) {
        global.resource_sprite_groups = {};
        var _names = texturegroup_get_names();
        for (var i = 0; i < array_length(_names); i++) {
            // Metadata lookup does not fetch texture pixels into GPU memory.
            var _sprites = texturegroup_get_sprites(_names[i]);
            for (var j = 0; j < array_length(_sprites); j++) {
                global.resource_sprite_groups[$ string(_sprites[j])] = _names[i];
            }
        }
    }
    var _key = string(_sprite);
    if (variable_struct_exists(global.resource_sprite_groups, _key)) {
        _groups = resource_add_group(_groups, global.resource_sprite_groups[$ _key]);
    }
    return _groups;
}

function resource_add_enemy_groups(_groups, _type) {
    if (!is_string(_type) || _type == "") return _groups;
    if (variable_global_exists("enemy_map") && ds_map_exists(global.enemy_map, _type)) {
        var _enemy = global.enemy_map[? _type];
        if (variable_struct_exists(_enemy, "spr")) _groups = resource_add_sprite_group(_groups, _enemy.spr);
        if (variable_struct_exists(_enemy, "_obj") && object_exists(_enemy._obj)) {
            _groups = resource_add_sprite_group(_groups, object_get_sprite(_enemy._obj));
        }
    }
    if (variable_global_exists("boss_list") && ds_map_exists(global.boss_list, _type)) {
        var _boss = global.boss_list[? _type];
        if (variable_struct_exists(_boss, "icon")) _groups = resource_add_sprite_group(_groups, _boss.icon);
    }
    return _groups;
}

function resource_scene_groups(_room) {
    var _groups = ["UI", "player", "maps", "cards_ui"];
    if (_room == room_tower_cake) {
        _groups = resource_add_group(_groups, "enemy_tower");
        _groups = resource_add_group(_groups, "enemy_delicious");
        _groups = resource_add_group(_groups, "enemy_volcanic");
    }
    if (_room == room_map && variable_global_exists("map_id")) {
        if (global.map_id == "undersea_vortex") _groups = resource_add_group(_groups, "pack_undersea_vortex");
        if (global.map_id == "explore_camp") _groups = resource_add_group(_groups, "pack_explore_camp");
    }
    if (_room != room_ready && _room != room_battle) return _groups;

    // Warm shared battle assets during preparation, never on the first shot.
    var _battle = ["cards", "bullet", "effects", "time_god", "battle_misc"];
    for (var i = 0; i < array_length(_battle); i++) _groups = resource_add_group(_groups, _battle[i]);
    if (variable_global_exists("map_id") && global.map_id == "longyuan") {
        _groups = resource_add_group(_groups, "enemy_longyuan");
    }
    if (variable_global_exists("level_file") && is_struct(global.level_file)
        && variable_struct_exists(global.level_file, "waves") && is_array(global.level_file.waves)) {
        var _waves = global.level_file.waves;
        for (var w = 0; w < array_length(_waves); w++) {
            var _wave = _waves[w];
            if (variable_struct_exists(_wave, "boss")) _groups = resource_add_enemy_groups(_groups, _wave.boss);
            if (variable_struct_exists(_wave, "boss2")) _groups = resource_add_enemy_groups(_groups, _wave.boss2);
            if (!variable_struct_exists(_wave, "subwaves")) continue;
            for (var s = 0; s < array_length(_wave.subwaves); s++) {
                var _enemies = _wave.subwaves[s].enemy_list;
                for (var e = 0; e < array_length(_enemies); e++) {
                    _groups = resource_add_enemy_groups(_groups, _enemies[e].type);
                }
            }
        }
    }
    return _groups;
}

/// Room Start runs after outgoing objects are destroyed and before the first draw.
/// This also covers transitions with animations disabled and consecutive battles.
function resource_scene_enter(_room) {
    if (!resource_memory_enabled() || _room == room_init) return;
    var _started = get_timer();
    var _required = resource_scene_groups(_room);
    var _dynamic = resource_dynamic_groups();
    for (var i = 0; i < array_length(_dynamic); i++) {
        // Maps share a group but not a lifetime. Drop pages from the previous room
        // even when the next room also has a map. Unload also handles partial loads.
        if (_dynamic[i] == "maps" || array_get_index(_required, _dynamic[i]) < 0) {
            texturegroup_unload(_dynamic[i]);
        }
    }
    for (var j = 0; j < array_length(_required); j++) resource_texture_prepare(_required[j]);
    if (resource_profile_enabled()) resource_profile_write({event: "scene_load",
        scene: room_get_name(_room), groups: _required, request_ms: (get_timer() - _started) / 1000});
}

/// Local opt-in only: create fvm-profile.enabled in the game's save directory.
/// No save contents, player identifiers, or authentication data are recorded.
function resource_profile_enabled() {
    static _enabled = undefined;
    if (is_undefined(_enabled)) _enabled = (os_type == os_macosx || os_type == os_windows) && file_exists("fvm-profile.enabled");
    return _enabled;
}

function resource_profile_write(_data) {
    _data.time_us = get_timer();
    var _file = file_text_open_append("fvm-profile.jsonl");
    if (_file < 0) return;
    file_text_write_string(_file, json_stringify(_data));
    file_text_writeln(_file);
    file_text_close(_file);
}

function resource_profile_flush(_state) {
    var _count = array_length(_state.samples);
    if (_count == 0) return;
    array_sort(_state.samples, true);
    var _sum = 0;
    var _late = 0;
    for (var i = 0; i < _count; i++) {
        _sum += _state.samples[i];
        if (_state.samples[i] > 1500 / _state.target_fps) _late++;
    }
    resource_profile_write({event: "frames", scene: room_get_name(_state.room_id),
        level: _state.level_id, target_fps: _state.target_fps, paused: _state.paused,
        transitioning: _state.transitioning, finished: _state.finished,
        frames: _count, mean_ms: _sum / _count,
        p95_ms: _state.samples[min(_count - 1, ceil(_count * 0.95) - 1)],
        p99_ms: _state.samples[min(_count - 1, ceil(_count * 0.99) - 1)],
        max_ms: _state.samples[_count - 1], late_frames: _late,
        enemies: _state.enemies, cards: _state.cards, bullets: _state.bullets});
    _state.samples = [];
}

function resource_profile_tick() {
    if (!resource_profile_enabled()) return;
    static _state = undefined;
    var _rate = game_get_speed(gamespeed_fps);
    var _paused = variable_global_exists("is_paused") && global.is_paused;
    var _finished = instance_exists(obj_game_over)
        || (variable_global_exists("game_over") && global.game_over);
    var _transition = room_transition_state().mode != 0;
    if (!is_undefined(_state) && (_state.room_id != room || _state.target_fps != _rate
        || _state.paused != _paused || _state.transitioning != _transition || _state.finished != _finished)) {
        resource_profile_flush(_state);
        _state = undefined;
    }
    if (is_undefined(_state)) {
        _state = {room_id: room, level_id: variable_global_exists("level_id") ? global.level_id : "",
            target_fps: _rate, paused: _paused, transitioning: _transition, finished: _finished, samples: [],
            enemies: 0, cards: 0, bullets: 0};
        // The first delta belongs to the previous room/rate, not this sample.
        return;
    }
    array_push(_state.samples, delta_time / 1000);
    _state.enemies = max(_state.enemies, instance_number(obj_enemy_parent));
    _state.cards = max(_state.cards, instance_number(obj_card_parent));
    _state.bullets = max(_state.bullets, instance_number(obj_bullet_parent));
    if (array_length(_state.samples) >= 300) {
        resource_profile_flush(_state);
        _state.enemies = 0;
        _state.cards = 0;
        _state.bullets = 0;
    }
}
