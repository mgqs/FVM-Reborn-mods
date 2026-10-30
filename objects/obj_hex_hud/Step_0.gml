if (!hex_active()) {          // 测试关卡 / 非海克斯模式：整个 HUD 不存在
    instance_destroy();
    exit;
}

var _s = global.hex_state;

if (hint_timer > 0) hint_timer -= 1;

// ── 「稳火」类：每 N 秒固定加火苗 ──
if (_s.flame_tick > 0) {
    tick_timer += 1;
    if (tick_timer >= _s.flame_tick_sec * 60) {
        tick_timer = 0;
        if (variable_global_exists("flame")) {
            global.flame = min(global.flame + _s.flame_tick,
                               variable_global_exists("flame_cap") ? global.flame_cap : 99999);
        }
    }
} else {
    tick_timer = 0;
}

// ── 羁绊计数：每 15 帧重算一次，放置/铲除的反馈够快且不浪费 ──
bond_timer -= 1;
if (bond_timer <= 0) {
    hex_bond_recalc();
    bond_timer = 15;

    // 整理成绘制用的行：大类在前，按计数从高到低
    var _names = variable_struct_get_names(global.bond_count);
    bond_rows = [];
    for (var i = 0; i < array_length(_names); i++) {
        var _n = _names[i];
        var _c = global.bond_count[$ _n];
        if (_c <= 0) continue;
        array_push(bond_rows, {
            name: _n,
            count: _c,
            tier: hex_bond_tier(_n),
            next: hex_bond_next_threshold(_n),
            done: (hex_bond_tier(_n) >= 3)
        });
    }
    array_sort(bond_rows, function(_a, _b) {
        if (_a.tier != _b.tier) return _b.tier - _a.tier;
        return _b.count - _a.count;
    });
}

// ── 悬停检测：鼠标落在某一行上，Draw 里给出该羁绊的当前效果 ──
bond_hover = -1;
if (!variable_global_exists("is_paused") || !global.is_paused) {
    for (var h = 0; h < array_length(bond_rows); h++) {
        var _hy = bond_by + h * bond_row_h;
        if (point_in_rectangle(mouse_x, mouse_y,
                               bond_bx, _hy - bond_row_h * 0.5,
                               bond_bx + bond_hit_w, _hy + bond_row_h * 0.5)) {
            bond_hover = h;
            break;
        }
    }
}

// ── 死亡或结算后自清 ──
if (!instance_exists(obj_battle)) instance_destroy();
