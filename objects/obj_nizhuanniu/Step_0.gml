if global.is_paused { exit; }
event_inherited();

if (is_frozen) { exit; }

state_timer++;

// 起手动画结束后触发一次逆转脉冲，随后卡片退场
if (!has_activated && state_timer >= activate_delay) {
    has_activated = true;
    is_activating = true;
    state = CARD_STATE.RELAX;

    var _radius = effect_radius;
    var _damage = reverse_damage;
    var _self_grid_row = grid_row;
    var _self_grid_col = grid_col;
    var _ids = [];

    // 1) 先快照范围内符合条件的普通老鼠，避免一边移动一边遍历
    with (obj_enemy_parent) {
        if (hp <= 0) continue;
        if (state == ENEMY_STATE.DEAD) continue;
        if (is_boss) continue;
        if (mouse_id == "mole") continue;
        if (target_type != "normal") continue;
        if (abs(grid_row - _self_grid_row) > _radius) continue;
        if (abs(grid_col - _self_grid_col) > _radius) continue;
        array_push(_ids, id);
    }

    // 2) 逐个传送，必要时补伤害
    for (var i = 0; i < array_length(_ids); i++) {
        var _e = _ids[i];
        if (!instance_exists(_e)) continue;
        if (_e.hp <= 0 || _e.state == ENEMY_STATE.DEAD) continue;

        // 目标行是老鼠自己的行，目标x优先用真实出生点，回退到右侧出生列
        var _dest_x = get_world_position_from_grid(global.grid_cols, _e.grid_row).x;
        if (variable_instance_exists(_e, "birth_x")) _dest_x = _e.birth_x;

        // 已在出生线附近的跳过，防止无限逆转
        if (_e.x >= _dest_x - global.grid_cell_size_x * 0.5) continue;

        _e.x = _dest_x;
        _e.grid_col = global.grid_cols;

        instance_create_depth(_e.x, _e.y, _e.depth - 10, obj_nizhuanniu_effect);

        if (_damage > 0) {
            with (_e) {
                damage_amount = _damage;
                damage_type = "physical";
                event_user(0);
            }
        }
    }
}

if (is_activating) {
    image_alpha -= 0.1;
    if (image_alpha <= 0) {
        instance_destroy();
    }
}