event_inherited();
image_speed = 0; // 动画完全由 longyuan_clip_* 驱动

// ===== 谛听鼠 =====
ly_kind = "diting";
ly_anims = longyuan_animation_table("diting");
mouse_id = "ly_diting";
hp = 200000; maxhp = 200000;

// ===== 数值 =====
atk = LY_DITING_SKILL1_DMG;        // 技能伤害（400）
wait_time = 60;                    // 待机时长（步，占位可调）
ly_move_speed = 2;                 // 遁地移动速度（像素/步，占位可调）
ly_skill_index = 0;

ly_boss_step = function() {
    var _act, _tcol, _tpos;

    // 遁地期间（常规移动钻入/地下段、技能1钻入/高速横移段）无敌。
    invincible = false;
    if (state == BOSS_STATE.MOVE && ly_phase < 2) invincible = true;
    if (state == BOSS_STATE.SKILL1 && (ly_phase == 0 || ly_phase == 1)) invincible = true;

    switch (state) {
        case BOSS_STATE.APPEAR: {
            if (ly_action != "出生") longyuan_clip_set("出生");
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.IDLE; }
            break;
        }
        case BOSS_STATE.IDLE: {
            _act = longyuan_variant("正常待机", "破损待机");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, true);
            if (timer >= wait_time) {
                timer = 0; ly_phase = 0;
                var _cycle = [1, 2, 1, 3];
                var _pick = _cycle[ly_skill_index mod array_length(_cycle)];
                ly_skill_index++;
                state = _pick == 1 ? BOSS_STATE.SKILL1 : (_pick == 2 ? BOSS_STATE.SKILL2 : BOSS_STATE.SKILL3);
            }
            break;
        }
        case BOSS_STATE.MOVE: {
            // 遁地移动：钻入（无敌）→ 向左移动到本行最左卡片所在列右侧 → 钻出 → 待机
            if (ly_phase == 0) {
                _act = longyuan_variant("正常钻入地下", "破损钻入地下");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) {
                _act = longyuan_variant("正常移动", "破损移动");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                x -= ly_move_speed;
                _tcol = ly_target_col();
                _tpos = get_world_position_from_grid(_tcol, grid_row);
                if (x <= _tpos.x + 40) { ly_phase = 2; timer = 0; }
            }
            else {
                _act = longyuan_variant("正常钻出", "破损钻出");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE; }
            }
            break;
        }
        case BOSS_STATE.SKILL1: { // 技能1：遁地突袭——钻入后高速横移，钻出对 3×3 每卡 400 伤害并引信范围内钟
            if (ly_phase == 0) {
                _act = longyuan_variant("正常技能1钻入", "破损技能1钻入");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) {
                _act = longyuan_variant("正常技能移动", "破损技能移动");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                x -= ly_move_speed * 2; // 地下高速横移
                if (timer >= 24) {
                    var _target = longyuan_diting_dense_cell();
                    var _target_pos = get_world_position_from_grid(_target.col, _target.row);
                    x = _target_pos.x; y = _target_pos.y;
                    ly_ambush_col = _target.col; ly_ambush_row = _target.row;
                    ly_phase = 2; timer = 0;
                }
            }
            else {
                _act = longyuan_variant("正常技能1钻出", "破损技能1钻出");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (!ly_hit && timer >= 10) {
                    longyuan_diting_damage_3x3(ly_ambush_col, ly_ambush_row, LY_DITING_SKILL1_DMG);
                    longyuan_diting_prison_fuse_3x3(ly_ambush_col, ly_ambush_row);
                    ly_hit = true;
                }
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    ly_phase = 0; ly_hit = false; timer = 0; state = BOSS_STATE.MOVE;
                }
            }
            break;
        }
        case BOSS_STATE.SKILL2: { // 技能2：随机用钟罩住场上 7 张卡（钟 1w 血，可被攻击）
            _act = longyuan_variant("正常技能2", "破损技能2");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (timer == 18) {
                var _cards = [];
                with (obj_card_parent) {
                    if (hp > 0 && plant_id != "player" && plant_type != "coffee") array_push(_cards, id);
                }
                for (var _i = array_length(_cards) - 1; _i > 0; --_i) {
                    var _j = irandom(_i), _swap = _cards[_i];
                    _cards[_i] = _cards[_j]; _cards[_j] = _swap;
                }
                var _placed = 0;
                for (var _i = 0; _i < array_length(_cards) && _placed < LY_DITING_PRISON_COUNT; ++_i) {
                    if (!instance_exists(_cards[_i])) continue;
                    var _col = _cards[_i].grid_col, _row = _cards[_i].grid_row;
                    // 同格已有钟则跳过
                    var _dup = false;
                    with (obj_ly_diting_prison) if (grid_col == _col && grid_row == _row && hp > 0) _dup = true;
                    if (_dup) continue;
                    var _prison = instance_create_depth(_cards[_i].x, _cards[_i].y, -600, obj_ly_diting_prison,
                        {prison_col: _col, prison_row: _row});
                    _placed++;
                }
            }
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.MOVE; }
            break;
        }
        case BOSS_STATE.SKILL3: { // 技能3：随机 5 行生成音波，右→左飞，命中首卡 400 并驻留持续伤害，20 秒消失，路径引信钟
            _act = longyuan_variant("正常技能3", "破损技能3");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (timer == 20) {
                var _rows = [];
                for (var _i = 0; _i < global.grid_rows; ++_i) array_push(_rows, _i);
                for (var _i = array_length(_rows) - 1; _i > 0; --_i) {
                    var _j = irandom(_i), _swap = _rows[_i];
                    _rows[_i] = _rows[_j]; _rows[_j] = _swap;
                }
                for (var _i = 0; _i < min(LY_DITING_SOUNDWAVE_ROWS, array_length(_rows)); ++_i) {
                    var _pos = get_world_position_from_grid(global.grid_cols - 1, _rows[_i]);
                    var _wave = instance_create_depth(_pos.x, _pos.y - 20, -1300, obj_ly_boss_fx);
                    longyuan_boss_fx_start(_wave, "diting_soundwave", "待机", true, 5);
                    _wave.fx_kind = "diting_soundwave_live";
                    _wave.fx_row = _rows[_i];
                    _wave.fx_direction = -1;
                    _wave.fx_speed = 6;
                    _wave.fx_life = 0;
                    _wave.fx_stuck = false;
                    _wave.fx_damage_timer = 0;
                    _wave.fx_damage = LY_DITING_SOUNDWAVE_DPS;
                }
            }
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.MOVE; }
            break;
        }
    }
};
