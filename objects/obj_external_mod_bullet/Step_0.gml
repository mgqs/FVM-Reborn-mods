if (global.is_paused) exit;
mod_age++;
prev_x = x;
prev_y = y;
image_index += mod_fps / 60;
if (!mod_loop && image_index >= image_number) image_index = image_number - 1;

// Each segment is processed in contact order. A reflection starts a new
// segment using only the remaining fraction of this frame's movement.
var _remaining = 1;
for (var _segment = 0; _segment < 17 && _remaining > 0.000001; _segment++) {
    var _start_x = x;
    var _start_y = y;
    var _vertical_turn = false;
    var _segment_time = _remaining;
    if (vertical_limited && move_y != 0) {
        if (vertical_remaining <= 0.000001) move_y = 0;
        else if (vertical_remaining <= abs(move_y) * _remaining) {
            _segment_time = vertical_remaining / abs(move_y);
            _vertical_turn = true;
        }
    }
    var _end_x = x + move_x * _segment_time;
    var _end_y = y + move_y * _segment_time;
    var _contacts = [];
    var _enhancement = rules.enhancement;
    var _reflection = rules.reflection;
    for (var _kind = 0; _kind < 2; _kind++) {
        var _sources = (_kind == 0) ? _enhancement.sources : _reflection.sources;
        if (_kind == 0 && amplify_count >= _enhancement.max_count) continue;
        if (_kind == 1 && bounce_count >= _reflection.max_count) continue;
        for (var _source_index = 0; _source_index < array_length(_sources); _source_index++) {
            var _source_object = external_mod_projectile_source_object(_sources[_source_index]);
            for (var _source_i = 0; _source_i < instance_number(_source_object); _source_i++) {
                var _source_inst = instance_find(_source_object, _source_i);
                if (!instance_exists(_source_inst) || _source_inst.hp <= 0 || _source_inst.grid_row != row) continue;
                if (ds_list_find_index((_kind == 0) ? amplify_ids : bounce_ids, _source_inst.id) >= 0) continue;
                var _source_contact = external_mod_sweep_contact(id, _source_inst, _start_x, _start_y, _end_x, _end_y);
                if (_source_contact >= 0) array_push(_contacts, {fraction: _source_contact, kind: _kind, target: _source_inst.id});
            }
        }
    }
    for (var _team_i = 0; _team_i < 2; _team_i++) {
        if (rules.hit.max_hits > 0 && hit_count >= rules.hit.max_hits) continue;
        var _target_object = (_team_i == 0) ? obj_enemy_parent : obj_card_parent;
        for (var _target_i = 0; _target_i < instance_number(_target_object); _target_i++) {
            var _target_inst = instance_find(_target_object, _target_i);
            if (!external_mod_projectile_target_allowed(id, _target_inst, _team_i == 0)) continue;
            var _handle_key = string(_target_inst.id);
            if (rules.hit.repeat_hit) {
                if (ds_map_exists(hit_cooldowns, _handle_key) && hit_cooldowns[? _handle_key] > mod_age) continue;
            } else if (ds_list_find_index(hit_ids, _target_inst.id) >= 0) continue;
            var _target_contact = external_mod_sweep_contact(id, _target_inst, _start_x, _start_y, _end_x, _end_y);
            if (_target_contact >= 0) array_push(_contacts, {fraction: _target_contact, kind: 2 + _team_i, target: _target_inst.id});
        }
    }
    array_sort(_contacts, function(a, b) {
        if (a.fraction < b.fraction) return -1;
        if (a.fraction > b.fraction) return 1;
        return a.kind - b.kind;
    });
    var _reflected = false;
    for (var _contact_i = 0; _contact_i < array_length(_contacts); _contact_i++) {
        var _contact = _contacts[_contact_i];
        var _contact_target = _contact.target;
        if (!instance_exists(_contact_target) || _contact_target.hp <= 0) continue;
        x = lerp(_start_x, _end_x, _contact.fraction);
        y = lerp(_start_y, _end_y, _contact.fraction);
        if (_contact.kind == 0) {
            if (amplify_count >= _enhancement.max_count) continue;
            damage = round(damage * _contact_target.atk);
            if (_enhancement.clear_slow) slow_ticks = 0;
            ds_list_add(amplify_ids, _contact_target);
            amplify_count++;
            audio_play_sound(snd_bullet_burnt, 0, false);
        } else if (_contact.kind == 1) {
            if (bounce_count >= _reflection.max_count) continue;
            move_x = -move_x;
            move_speed = move_x;
            image_angle += 180;
            if (_reflection.add_source_atk) damage += _contact_target.atk;
            if (_reflection.team != "keep") target_team = _reflection.team;
            combat_owner = _contact_target;
            ds_list_add(bounce_ids, _contact_target);
            bounce_count++;
            if (vertical_limited) vertical_remaining = max(0, vertical_remaining - abs(move_y) * _segment_time * _contact.fraction);
            _remaining -= _segment_time * _contact.fraction;
            _reflected = true;
            break;
        } else {
            if (rules.hit.max_hits > 0 && hit_count >= rules.hit.max_hits) continue;
            if (!external_mod_projectile_target_allowed(id, _contact_target, _contact.kind == 2)) continue;
            var _hit_key = string(_contact_target);
            // Record before callbacks: a callback may destroy the target/owner.
            if (rules.hit.repeat_hit) hit_cooldowns[? _hit_key] = mod_age + rules.hit.repeat_interval_ticks;
            else ds_list_add(hit_ids, _contact_target);
            hit_count++;
            if (_contact.kind == 2) {
                _contact_target.damage_amount = damage;
                _contact_target.damage_type = damage_type;
                with (_contact_target) event_user(0);
            } else {
                _contact_target.hp -= damage;
                with (_contact_target) event_user(2);
            }
            if (!instance_exists(id)) exit;
            if (_contact.kind == 2 && !is_undefined(burn) && instance_exists(_contact_target)) external_mod_apply_burn(_contact_target, burn);
            if (instance_exists(_contact_target) && slow_ticks > 0 && variable_instance_exists(_contact_target, "ice_timer")) _contact_target.ice_timer = max(_contact_target.ice_timer, slow_ticks);
            if (instance_exists(owner_card)) external_mod_callback(owner_card, "on_hit", {target: _contact_target, damage: damage});
            if (!instance_exists(id)) exit;
            if (rules.hit.destroy_on_hit && rules.hit.max_hits > 0 && hit_count >= rules.hit.max_hits) {
                instance_destroy();
                exit;
            }
        }
    }
    if (!_reflected) {
        x = _end_x;
        y = _end_y;
        if (vertical_limited) vertical_remaining = max(0, vertical_remaining - abs(move_y) * _segment_time);
        if (_vertical_turn) {
            move_y = 0;
            _remaining -= _segment_time;
            continue;
        }
        break;
    }
}
if (--mod_lifetime <= 0 || x < -200 || x > room_width + 200 || y < -200 || y > room_height + 200) instance_destroy();
