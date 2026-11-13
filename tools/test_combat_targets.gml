/// Differential reference: the original native with-loop, including layer order.
function combat_probe_legacy_plant() {
    var zombie_grid = {row: grid_row};
    var _can_use_ladder = can_use_ladder;
        // 检测前方植物
        var plant_in_range = noone;

		var plant_order_list = [noone,noone,noone,noone]


        // 使用碰撞检测查找攻击范围内的植物
        with (obj_card_parent) {
			// 高跷鼠只把三种高大面包视为可攻击目标，其余低矮植物直接忽略
			if (other.mouse_id == "longyuan_gaoqiao"
				&& plant_id != "chocolate_bread"
				&& plant_id != "pineapple_explosive_bread"
				&& plant_id != "mianbao"
				&& plant_id != "lightning_baguette") continue;
			var dx = x - other.x;
			var dy = y - other.y;
			var is_in_front = false
			if other.attack_range > 0{
				is_in_front = (dx < 0 && dx > -other.attack_range);
			}
			else{
				is_in_front = (dx > 0 && dx < -other.attack_range);
			}

            // 检查是否在攻击范围内
            // 若该植物身上挂着梯子，则跳过（改由「上梯」逻辑处理），不啃它
            var _skip_by_ladder = false;
            if (_can_use_ladder && instance_number(obj_ladder) > 0) {
                var _this_plant_id = id;
                with (obj_ladder) {
                    if (host_plant == _this_plant_id) _skip_by_ladder = true;
                }
            }
            if (is_in_front && zombie_grid.row == grid_row && !_skip_by_ladder && (feature_type!="dwarf" || (feature_type=="dwarf" && other.giant_type))) {
                // 按铲除顺序优先选择
                for (var i = 0; i < ds_list_size(global.eat_order); i++) {
                    var tar_type = ds_list_find_value(global.eat_order, i);

                    if (plant_type == tar_type) {
                        plant_order_list[i] = id;
                        break;
                    }
                }


                if (plant_in_range != noone) break;
            }
        }

		for(var i = 0 ; i < 4 ; i++){
			if plant_order_list[i] != noone{
				plant_in_range = plant_order_list[i]
				break
			}
		}

    return plant_in_range;
}

function combat_probe_assert(_ok, _label) {
    if (!_ok) throw "COMBAT_TARGETS_FAIL: " + _label;
}

function combat_probe_legacy_front() {
    var _has = false;
    with (obj_enemy_parent) {
        if (grid_row == other.grid_row && grid_col >= other.grid_col && grid_col <= global.grid_cols + 1
            && can_target_on(other.target_type, target_type)) { _has = true; break; }
    }
    return _has;
}

function combat_probe_legacy_three() {
    var _has = false;
    with (obj_enemy_parent) {
        if (grid_row >= other.grid_row - 1 && grid_row <= other.grid_row + 1
            && grid_col >= other.grid_col && grid_col <= global.grid_cols + 1
            && can_target_on(other.target_type, target_type)) { _has = true; break; }
    }
    return _has;
}

function combat_probe_legacy_nearest() {
    var _target = noone;
    var _distance = 10000;
    with (obj_enemy_parent) {
        if (grid_row == other.grid_row && grid_col >= other.grid_col && grid_col <= global.grid_cols + 1
            && can_target_on(other.target_type, target_type)) {
            var _d = grid_col - other.grid_col;
            if (_d < _distance) { _distance = _d; _target = id; }
        }
    }
    return _target;
}

function combat_probe_new_plant() { return combat_enemy_find_plant(id); }

function combat_probe_compare(_inst, _actual, _reference, _label) {
    var _a, _b;
    // script_execute preserves the calling instance's self/other scope.
    with (_inst) {
        _a = script_execute(_actual);
        _b = script_execute(_reference);
    }
    combat_probe_assert(_a == _b, _label + " actual=" + string(_a) + " expected=" + string(_b));
    global.combat_probe_checks++;
}

function combat_probe_run() {
    global.combat_probe_checks = 0;
    global.grid_cols = 9; global.grid_rows = 7;
    global.grid_offset_x = 695; global.grid_offset_y = 228;
    global.grid_cell_size_x = 107; global.grid_cell_size_y = 116;
    global.eat_order = ds_list_create();
    ds_list_add(global.eat_order, "shield", "shield_outer", "normal", "lilypad");
    random_set_seed(71029);
    var _types = ["normal", "air", "underground", "diver", "dance", "invisible", "obstacle"];
    var _attacks = ["normal", "throw", "track", "air_only", "pierce", "rotate", "all"];
    var _plants = ["shield", "shield_outer", "normal", "lilypad", "coffee"];
    var _calls = combat_probe_calls();
    var _card = instance_create_depth(0, 0, 0, obj_xiao_long_bao);
    _card.target_type = "normal";
    _card.grid_col = 0;
    _card.grid_row = 2;
    _card.plant_type = "normal";
    _card.plant_id = "xiao_long_bao";
    _card.feature_type = "normal";
    var _enemies = [];
    var _cards = [_card];
    for (var _i = 0; _i < 96; _i++) {
        var _e = instance_create_depth(0, 0, 0, (_i mod 2 == 0) ? obj_normal_mouse : obj_iron_pan_mouse);
        _e.grid_row = _i mod 7; _e.grid_col = 5;
        _e.target_type = "normal"; _e.hp = 100;
        _e.can_use_ladder = true; _e.giant_type = false;
        _e.mouse_id = "normal"; _e.attack_range = 90;
        array_push(_enemies, _e);
    }
    for (var _i = 0; _i < 48; _i++) {
        var _p = instance_create_depth(0, 0, 0, (_i mod 2 == 0) ? obj_xiao_long_bao : obj_coffee_cup);
        _p.grid_row = _i mod 7; _p.grid_col = 5;
        _p.plant_type = "normal"; _p.feature_type = "normal";
        _p.plant_id = "mianbao";
        array_push(_cards, _p);
    }
    var _ladder = instance_create_depth(0, 0, 0, obj_ladder);
    _ladder.host_plant = _cards[4];

    for (var _trial = 0; _trial < 120; _trial++) {
        combat_targets_begin_step();
        for (var _i = 0; _i < array_length(_enemies); _i++) {
            var _e = _enemies[_i];
            _e.grid_row = combat_targets_row_value(_e, irandom_range(-1, 7));
            _e.grid_col = irandom_range(-2, 12);
            _e.target_type = _types[irandom(array_length(_types) - 1)];
            _e.hp = irandom_range(-10, 100);
            _e.x = irandom_range(-160, 160);
        }
        for (var _i = 0; _i < array_length(_cards); _i++) {
            var _p = _cards[_i];
            _p.grid_row = combat_targets_row_value(_p, irandom_range(-1, 7));
            _p.plant_type = _plants[irandom(array_length(_plants) - 1)];
            _p.plant_id = (_i mod 2 == 0) ? "mianbao" : "xiao_long_bao";
            _p.feature_type = (_i mod 4 == 0) ? "dwarf" : "normal";
            _p.x = irandom_range(-160, 160);
        }
        _card.grid_col = irandom_range(-1, 10);
        _card.target_type = _attacks[_trial mod array_length(_attacks)];
        for (var _i = 0; _i < array_length(_calls); _i++) {
            var _case = _calls[_i];
            combat_probe_compare(_card, _case.actual, _case.reference, _case.label);
        }
        var _e = _enemies[0];
        _e.can_use_ladder = (_trial mod 2 == 0);
        _e.giant_type = (_trial mod 3 == 0);
        _e.mouse_id = (_trial mod 4 == 0) ? "longyuan_gaoqiao" : "normal";
        _e.attack_range = (_trial mod 2 == 0) ? 90 : -90;
        combat_probe_compare(_e, combat_probe_new_plant, combat_probe_legacy_plant, "enemy layer/ladder/dwarf/direction");
        // Same-frame row changes must be visible even after the bucket was read.
        var _new_row = _card.grid_row;
        var _e = _enemies[1];
        _e.grid_row = combat_targets_row_value(_e, _new_row);
        _e.grid_col = _card.grid_col; _e.target_type = "normal";
        combat_probe_compare(_card, _calls[0].actual, _calls[0].reference, "same-frame enemy row change");
        var _p = _cards[1];
        _p.grid_row = combat_targets_row_value(_p, _enemies[0].grid_row);
        combat_probe_compare(_enemies[0], combat_probe_new_plant, combat_probe_legacy_plant, "same-frame card row change");
    }
    // Recycled instance/type, count-preserving replacement, and row boundary.
    combat_targets_row(obj_enemy_parent, _card.grid_row);
    var _gone = _enemies[1];
    with (_gone) instance_destroy();
    var _new = instance_create_depth(0, 0, 0, obj_normal_mouse);
    _new.grid_row = _card.grid_row; _new.grid_col = _card.grid_col;
    _new.target_type = "normal"; _new.hp = 100;
    for (var _i = 0; _i < array_length(_calls); _i++) {
        var _case = _calls[_i];
        combat_probe_compare(_card, _case.actual, _case.reference, "count-preserving spawn " + _case.label);
    }
    with (_new) instance_change(obj_iron_pan_mouse, true);
    _new.grid_row = combat_targets_row_value(_new, _card.grid_row);
    _new.grid_col = _card.grid_col; _new.target_type = "air";
    combat_probe_compare(_card, _calls[0].actual, _calls[0].reference, "pooled type change");
    _new.y = global.grid_offset_y + global.grid_cell_size_y * 5.5;
    with (_new) {
        var _pos = get_grid_position_from_world(x, y);
        grid_row = _pos.row;
    }
    combat_probe_compare(_card, _calls[0].actual, _calls[0].reference, "world/grid row notification");
    // Coordinate lookup also occurs in struct methods, without an instance id.
    var _lookup = {run: function() { return get_grid_position_from_world(0, 0); }};
    _lookup.run();

    // Use the real teleport/platform row-write statements, with a caller whose
    // own row already equals the destination (invalidating the caller is wrong).
    _card.grid_row = combat_targets_row_value(_card, 0);
    var _moved = _cards[1];
    _moved.grid_row = combat_targets_row_value(_moved, 1);
    combat_targets_row(obj_card_parent, 0);
    with (_card) combat_probe_teleport_row(_moved, 0);
    combat_probe_assert(array_contains(combat_targets_row(obj_card_parent, 0), _moved), "teleport invalidates moved entity");
    combat_targets_row(obj_card_parent, 1);
    combat_probe_platform_row(_moved, 1);
    combat_probe_assert(array_contains(combat_targets_row(obj_card_parent, 1), _moved), "platform updates same-frame candidates");
    for (var _round = 0; _round < 100; _round++) {
        var _manager = instance_create_depth(0, 0, 0, obj_mod_battle_manager);
        var _list = global.buff_sources;
        var _maps = [global.buff_grid, global.buff_stack_grid, global.buff_stack_count];
        combat_probe_assert(ds_map_size(_maps[0]) == 9, "buff data initialized");
        with (_manager) instance_destroy();
        combat_probe_assert(!ds_exists(_list, ds_type_list), "buff source list released");
        for (var _i = 0; _i < 3; _i++) combat_probe_assert(!ds_exists(_maps[_i], ds_type_map), "buff map released");
        var _recycled = ds_map_create();
        mod_battle_resources_clear();
        combat_probe_assert(ds_exists(_recycled, ds_type_map), "repeat cleanup preserves recycled handle");
        mod_buff_source_remove(_card);
        ds_map_destroy(_recycled);
    }
    var _manager = instance_create_depth(0, 0, 0, obj_mod_battle_manager);
    with (_manager) event_perform(ev_step, ev_step_normal);
    combat_probe_assert(!instance_exists(_manager), "manager exits immediately after cleanup without a battle");
    // Repeat queries across complete frame epochs: includes index rebuild cost.
    // Timings are diagnostic, not a machine-dependent pass/fail threshold.
    with (obj_enemy_parent) {
        grid_row = combat_targets_row_value(id, real(id) mod 7);
        grid_col = 6; target_type = "normal"; hp = 100;
    }
    _card.grid_row = combat_targets_row_value(_card, 2);
    _card.grid_col = 0; _card.target_type = "throw";
    var _old_us = combat_probe_time(_card, combat_probe_legacy_front);
    var _new_us = combat_probe_time(_card, combat_probe_new_front);
    show_debug_message("COMBAT_BENCH front old_us=" + string(_old_us) + " indexed_us=" + string(_new_us));
    _card.grid_row = combat_targets_row_value(_card, -2);
    var _old_us = combat_probe_time(_card, combat_probe_legacy_front);
    var _new_us = combat_probe_time(_card, combat_probe_new_front);
    show_debug_message("COMBAT_BENCH empty_row old_us=" + string(_old_us) + " indexed_us=" + string(_new_us));
    _card.grid_row = combat_targets_row_value(_card, 2);
    var _old_us = combat_probe_time(_card, combat_probe_legacy_nearest);
    var _new_us = combat_probe_time(_card, combat_probe_new_nearest);
    show_debug_message("COMBAT_BENCH nearest old_us=" + string(_old_us) + " indexed_us=" + string(_new_us));
    var _old_us = combat_probe_time(_enemies[0], combat_probe_legacy_plant);
    var _new_us = combat_probe_time(_enemies[0], combat_probe_new_plant);
    show_debug_message("COMBAT_BENCH enemy old_us=" + string(_old_us) + " indexed_us=" + string(_new_us));
    show_debug_message("COMBAT_TARGETS_PASS: " + string(global.combat_probe_checks)
        + " differential queries; 100 DS lifecycles; same-frame moves, spawn, pool reuse and target types");
    game_end();
}

function combat_probe_new_nearest() { return combat_enemy_nearest_in_row(id, target_type); }
function combat_probe_time(_inst, _query) {
    var _start = get_timer();
    repeat (40) {
        combat_targets_begin_step();
        with (_inst) repeat (120) script_execute(_query);
    }
    return get_timer() - _start;
}

function combat_probe_new_front() { return combat_enemy_in_rows(id, grid_row, grid_row, grid_col, global.grid_cols + 1, target_type); }
