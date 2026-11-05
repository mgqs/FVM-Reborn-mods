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

    // 1) 先快照范围内符合条件的老鼠，避免一边移动一边遍历
    //    可逆转 = 普通陆军(normal) + 钻地中的地鼠(underground)。
    //    地鼠（鼹鼠 / 牙医鼠 / 沙丁鱼鼠 / 锯齿鼠 / 龙渊地精鼠）钻地时 target_type 是 "underground"
    //    而不是 "normal"，但它们和普通鼠一样是一路向左掘进，逆转等于把整段掘进距离作废、
    //    送回本行出生线重新挖，与普通鼠完全同效。冒头后它们自己会切回 "normal"，同样命中。
    //    BOSS 仍然免疫（见上一条 is_boss）。
    with (obj_enemy_parent) {
        if (hp <= 0) continue;
        if (state == ENEMY_STATE.DEAD) continue;
        if (is_boss) continue;
        if (target_type != "normal" && target_type != "underground") continue;
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
                damage_source_object = other.object_index;
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
