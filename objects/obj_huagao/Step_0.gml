if (global.is_paused) exit;
event_inherited();
if (hp <= 0) exit;
if (is_frozen || state == CARD_STATE.SLEEP) exit;

// ---------- 固定间隔攻击：不索敌，场上没有鼠军也照常发射 ----------
huagao_timer++;
if (huagao_timer >= cycle) {
    huagao_timer = 0;
    state = CARD_STATE.ATTACK;
    image_index = idle_anim + 1;
    huagao_shot = false;
}

// 攻击动画推进到第 16 帧（1-based）时放出魂虫
if (state == CARD_STATE.ATTACK) {
    if (!huagao_shot && image_index == idle_anim + 4) {
        huagao_shot = true;

        // 中路 2/2/4 次、上下路 1/1/2 次
        var _mid_hits = (shape >= 2) ? 4 : 2;
        var _side_hits = (shape >= 2) ? 2 : 1;
        var _spr = huagao_bullet_sprite(shape);
        // 音盒马 / 浮生茶的同轨增幅已在 obj_mod_battle_manager 并入 atk，这里直接取 atk
        var _dmg = atk;

        // ---------- 横向魂虫：位置与排布直接参考炎凰马 ----------
        // 取卡片所在行的「上缝隙」(grid_row) 与「下缝隙」(grid_row+1)，
        // 每条缝隙左右两端各 1 只，共 4 只；每只覆盖相邻两行，
        // 两条缝隙合计正好覆盖 上 / 中 / 下 3 行，且每行各 2 只（左上、右上、左下、右下）。
        // 二转：每条缝隙的左右各再加 1 只（共 8 只），用 y 偏移错开避免完全重叠。
        var _field_l = combat_left_x();
        // 右端用战斗域右沿（第 10 列右沿）：魂虫从那里向左飞，才能扫到刚进场的老鼠
        var _field_r = combat_right_x();
        var _tag = huagao_next_attack_tag();

        var _gap_up = clamp(grid_row, 1, global.grid_rows - 1);
        var _gap_dn = clamp(grid_row + 1, 1, global.grid_rows - 1);
        var _gap_list  = [_gap_up, _gap_dn];
        var _side_list = [_field_l - 20, _field_r + 20];   // 左端在外侧、右端在外侧（同炎凰马）
        var _dir_list  = [1, -1];                          // 左端向右飞、右端向左飞 = 对向
        var _lane_n    = (shape >= 2) ? 2 : 1;

        for (var _gi = 0; _gi < 2; _gi++) {
            var _gap = _gap_list[_gi];
            var _cov = [];
            if (_gap - 1 >= 0 && _gap - 1 < global.grid_rows) array_push(_cov, _gap - 1);
            if (_gap     >= 0 && _gap     < global.grid_rows) array_push(_cov, _gap);
            var _gy0 = global.grid_offset_y + (_gap - 0.25) * global.grid_cell_size_y;
            for (var _si = 0; _si < 2; _si++) {
                for (var _li = 0; _li < _lane_n; _li++) {
                    var _gy = _gy0;
                    if (_lane_n > 1) _gy += (_li == 0) ? -10 : 10;
                    huagao_spawn_bug(id, _side_list[_si], _gy, _dir_list[_si], false,
                        _cov, [], grid_row, _spr, _dmg, _mid_hits, _side_hits, _tag);
                }
            }
        }
    }
    if (huagao_shot && image_index == idle_anim + 1) {
        state = CARD_STATE.IDLE;
        image_index = 0;
        huagao_shot = false;
    }
}

// ---------- 一转：场上 ≥10 张时，攻击力最高的 1 张每 5 秒召唤竖向魂虫 ----------
if (shape >= 1) {
    huagao_vertical_timer++;
    if (huagao_vertical_timer >= 300) {
        var _count = 0;
        var _strongest = noone;
        for (var _i = 0; _i < instance_number(obj_huagao); _i++) {
            var _p = instance_find(obj_huagao, _i);
            if (!instance_exists(_p) || _p.hp <= 0) continue;
            _count++;
            if (_p.shape >= 1 && (!instance_exists(_strongest)
                || _p.atk > _strongest.atk
                || (_p.atk == _strongest.atk && _p.id < _strongest.id))) _strongest = _p;
        }
        if (_count >= 10 && _strongest == id) {
            // 第 8、9 列（0-based 7、8），从场地右上方竖直落下
            var _cols = [];
            for (var _c = 7; _c <= 8; _c++) {
                if (_c >= 0 && _c < global.grid_cols) array_push(_cols, _c);
            }
            if (array_length(_cols) > 0) {
                var _vx = global.grid_offset_x + _cols[0] * global.grid_cell_size_x
                    + global.grid_cell_size_x * array_length(_cols) * 0.5;
                var _vy = global.grid_offset_y - global.grid_cell_size_y * 0.6;
                huagao_spawn_bug(id, _vx, _vy, 0, true, [], _cols, grid_row,
                    huagao_bullet_sprite(shape), atk, 1, 1, huagao_next_attack_tag());
            }
            huagao_vertical_timer = 0;
        }
        // 未满 10 张时保留计时，凑满后立即由攻击力最高的那张召唤
        if (_count < 10) huagao_vertical_timer = 300;
    }
}
