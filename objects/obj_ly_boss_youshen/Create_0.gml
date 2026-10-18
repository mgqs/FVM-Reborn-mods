event_inherited();
image_speed = 0; // 动画完全由 longyuan_clip_* 驱动

// ===== 游神鼠 =====
ly_kind = "youshen";
ly_anims = longyuan_animation_table("youshen");
mouse_id = "ly_youshen";
hp = 100000; maxhp = 100000;

// ===== 占位数值（可调）=====
wait_time = 60;       // 占位：待机时长（步）
ly_enter_speed = 4;   // 占位：出场进场速度（像素/步）
ly_fish_wait = 90;    // 占位：钓坐骑停留时长（步）
ly_scroll_speed = 11; // 占位：夜巡符咒飞行速度（像素/步）
ly_charge_speed = 14; // 占位：冲撞纵向速度（像素/步）
ly_skill_index = 0;

// 出场插值
ly_from_x = 0; ly_from_y = 0; ly_to_x = 0; ly_to_y = 0;

// 技能1：夜巡符咒
ly_scroll_row = 0; ly_scroll_col = 0;

// 技能2：眩晕术 ∞ 轨迹（相对起点的 col,row 增量，1→8 顺序）
ly_inf_path = [
    [0, 0], [1, 0], [2, 1], [3, 1],
    [3, 0], [2, 0], [1, 1], [0, 1],
];
ly_start_col = 0; ly_start_row = 0; ly_si = 0; ly_cast_done = false;

// 技能3：冲撞
ly_charge_col = 0; ly_charge_dir = 1; ly_next_row = 0; ly_charge_passed = false;

ly_boss_step = function() {
    var _act, _tpos, _from, _to;

    switch (state) {
        // ===== 出场：第4行第10列进入 → 第8行第3列钓出坐骑大鱼 → 飞走 =====
        case BOSS_STATE.APPEAR: {
            if (ly_phase == 0 && timer == 0) {
                _tpos = get_world_position_from_grid(global.grid_cols - 1, 3);
                x = _tpos.x + global.grid_cell_size_x * 1.2;
                y = _tpos.y;
            }
            if (ly_phase == 0) { // 进场
                if (ly_action != "出生") longyuan_clip_set("出生");
                longyuan_clip_frame(timer, ly_anim_rate, false);
                var _enter = get_world_position_from_grid(global.grid_cols - 1, 3);
                if (x > _enter.x) x -= ly_enter_speed;
                if (x <= _enter.x && longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) { // 游到棋盘下方第8行第3列
                if (timer == 0) {
                    ly_from_x = x; ly_from_y = y;
                    var _fish = get_world_position_from_grid(2, global.grid_rows - 1);
                    ly_to_x = _fish.x;
                    ly_to_y = _fish.y + global.grid_cell_size_y; // 第8行（棋盘最后一行再下一格）
                }
                _act = longyuan_variant("正常移动", "破损移动");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                var _k = min(1, timer / 60);
                x = ly_from_x + (ly_to_x - ly_from_x) * _k;
                y = ly_from_y + (ly_to_y - ly_from_y) * _k;
                if (timer >= 60) { x = ly_to_x; y = ly_to_y; ly_phase = 2; timer = 0; }
            }
            else if (ly_phase == 2) { // 钓大鱼停留（自身精灵表现）
                _act = longyuan_variant("正常待机", "破损待机");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                if (timer >= ly_fish_wait) { ly_phase = 3; timer = 0; }
            }
            else { // 飞走
                _act = longyuan_variant("正常游出", "破损游出");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    x = room_width + 200;
                    ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE;
                }
            }
            break;
        }

        case BOSS_STATE.IDLE: {
            _act = longyuan_variant("正常待机", "破损待机");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, true);
            if (timer >= wait_time) {
                timer = 0; ly_phase = 0;
                var _cycle = [BOSS_STATE.SKILL1, BOSS_STATE.SKILL2, BOSS_STATE.SKILL3];
                state = _cycle[ly_skill_index mod array_length(_cycle)];
                ly_skill_index++;
            }
            break;
        }

        // ===== 技能1：夜巡符咒（随机第2-6行，符咒从第10列飞至本行随机第2-7列，10 秒 3×3 毒雾）=====
        case BOSS_STATE.SKILL1: {
            if (timer == 0) {
                ly_scroll_row = irandom_range(1, min(5, global.grid_rows - 2));
                ly_scroll_col = irandom_range(1, min(6, global.grid_cols - 3)); // 第2-7列 index1..6
                _tpos = get_world_position_from_grid(global.grid_cols - 1, ly_scroll_row);
                x = _tpos.x; y = _tpos.y;
            }
            _act = longyuan_variant("正常技能1", "破损技能1");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (timer == 30) {
                var _target = get_world_position_from_grid(ly_scroll_col, ly_scroll_row);
                var _scroll = instance_create_depth(x, y - 45, -200, obj_ly_boss_fx);
                longyuan_boss_fx_start(_scroll, "youshen_scroll", "飞行", true, 5);
                _scroll.fx_kind = "youshen_scroll_live";
                _scroll.fx_target_x = _target.x;
                _scroll.fx_col = ly_scroll_col;
                _scroll.fx_row = ly_scroll_row;
                _scroll.fx_speed = ly_scroll_speed;
            }
            if (longyuan_clip_done(timer, ly_anim_rate)) {
                x = room_width + 200;
                timer = 0; state = BOSS_STATE.IDLE;
            }
            break;
        }

        // ===== 技能2：眩晕术（∞ 轨迹一周，催眠 6×4 范围 15 秒）=====
        case BOSS_STATE.SKILL2: {
            if (timer == 0) {
                ly_start_col = irandom_range(1, min(4, global.grid_cols - 5)); // 2-5列
                ly_start_row = irandom_range(1, min(4, global.grid_rows - 3)); // 2-5行
                ly_si = 0;
                ly_cast_done = false;
            }
            _act = longyuan_variant("正常技能2", "破损技能2");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, true);
            // 每 10 步走到 ∞ 的下一个点
            if (ly_si < array_length(ly_inf_path) && timer mod 10 == 0) {
                var _off = ly_inf_path[ly_si];
                _tpos = get_world_position_from_grid(ly_start_col + _off[0], ly_start_row + _off[1]);
                x = _tpos.x; y = _tpos.y;
                ly_si++;
            }
            else if (ly_si >= array_length(ly_inf_path) && !ly_cast_done && timer >= array_length(ly_inf_path) * 10) {
                ly_cast_done = true;
                var _sleep_cards = longyuan_sleep_area(ly_start_col + 1, ly_start_row, 6, 4, LY_YOUSHEN_SLEEP_DUR);
                var _sleep_fx = instance_create_depth(x, y - 30, -200, obj_ly_boss_fx);
                longyuan_boss_fx_start(_sleep_fx, "youshen_mist", "待机", true, 5);
                _sleep_fx.fx_kind = "youshen_sleep";
                _sleep_fx.fx_life = 0;
                _sleep_fx.fx_duration = LY_YOUSHEN_SLEEP_DUR;
                _sleep_fx.fx_cards = _sleep_cards;
            }
            if (ly_cast_done && timer >= array_length(ly_inf_path) * 10 + 40) {
                x = room_width + 200;
                timer = 0; state = BOSS_STATE.IDLE;
            }
            break;
        }

        // ===== 技能3：冲撞（第4-6列随机一列，从上往下或从下往上摧毁整列卡片）=====
        case BOSS_STATE.SKILL3: {
            if (ly_phase == 0) {
                _act = longyuan_variant("正常技能3", "破损技能3");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) {
                if (timer == 0) {
                    ly_charge_col = irandom_range(3, min(5, global.grid_cols - 2)); // 第4-6列 index3..5
                    ly_charge_dir = choose(-1, 1);
                    ly_next_row = ly_charge_dir > 0 ? 0 : global.grid_rows - 1;
                    ly_charge_passed = false;
                    var _edge = get_world_position_from_grid(ly_charge_col, ly_next_row);
                    x = _edge.x;
                    y = _edge.y - ly_charge_dir * global.grid_cell_size_y; // 从棋盘外一端起步
                }
                _act = longyuan_variant("正常技能3冲刺", "破损技能3冲刺");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                y += ly_charge_dir * ly_charge_speed;
                // 越过某行中心时摧毁该行全部卡片
                while (!ly_charge_passed && ly_next_row >= 0 && ly_next_row < global.grid_rows) {
                    var _row_pos = get_world_position_from_grid(ly_charge_col, ly_next_row);
                    var _reach = ly_charge_dir > 0 ? (y >= _row_pos.y) : (y <= _row_pos.y);
                    if (!_reach) break;
                    longyuan_damage_cell(ly_charge_col, ly_next_row, 0, true);
                    ly_next_row += ly_charge_dir;
                }
                if (ly_next_row < 0 || ly_next_row >= global.grid_rows) {
                    var _last = get_world_position_from_grid(ly_charge_col,
                        ly_charge_dir > 0 ? global.grid_rows - 1 : 0);
                    var _beyond = abs(y - _last.y) > global.grid_cell_size_y * 0.5;
                    if (_beyond) ly_charge_passed = true;
                }
                if (ly_charge_passed) { ly_phase = 2; timer = 0; }
            }
            else {
                _act = longyuan_variant("正常技能3结束", "破损技能3结束");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    x = room_width + 200;
                    ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE;
                }
            }
            break;
        }
    }
};
