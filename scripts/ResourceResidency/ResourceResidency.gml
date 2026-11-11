/// macOS keeps UI/fonts resident; larger groups live on disk until needed.
/// Keep implicit loading as a fallback for custom stages and Mod-created objects.
function resource_memory_enabled() {
    static _enabled = undefined;
    if (is_undefined(_enabled)) {
        // IDE builds on affected runtimes can ignore configuration overrides.
        // Use the original loading/audio buses unless external assets exist.
        _enabled = os_type == os_macosx
            && file_exists(working_directory + "cards_0.yytex")
            && file_exists(working_directory + "mus_town.ogg");
    }
    return _enabled;
}

function resource_dynamic_groups() {
    static _groups = ["cards", "player", "maps", "bullet", "effects", "time_god",
        "enemy_delicious", "enemy_volcanic", "enemy_floating", "enemy_tower",
        "pack_undersea_vortex", "pack_explore_camp"];
    return _groups;
}

function resource_texture_prepare(_group) {
    if (resource_memory_enabled() && array_get_index(resource_dynamic_groups(), _group) >= 0) {
        if (texturegroup_get_status(_group) == texturegroup_status_unloaded) {
            if (texturegroup_load(_group, false) < 0) return false;
        }
    }
    texture_prefetch(_group);
    return true;
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
    var _groups = ["UI", "player", "maps"];
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
    var _battle = ["cards", "bullet", "effects", "time_god"];
    for (var i = 0; i < array_length(_battle); i++) _groups = resource_add_group(_groups, _battle[i]);
    if (variable_global_exists("level_data") && is_struct(global.level_data)
        && variable_struct_exists(global.level_data, "level_sprite")) {
        _groups = resource_add_sprite_group(_groups, global.level_data.level_sprite);
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
    var _required = resource_scene_groups(_room);
    var _dynamic = resource_dynamic_groups();
    for (var i = 0; i < array_length(_dynamic); i++) {
        if (array_get_index(_required, _dynamic[i]) < 0
            && texturegroup_get_status(_dynamic[i]) != texturegroup_status_unloaded) {
            texturegroup_unload(_dynamic[i]);
        }
    }
    for (var j = 0; j < array_length(_required); j++) resource_texture_prepare(_required[j]);
}
