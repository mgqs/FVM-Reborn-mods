event_inherited();
image_speed = 0; // 动画完全由 longyuan_clip_* 驱动

// ===== 谛听鼠 =====
ly_kind = "diting";
ly_anims = longyuan_animation_table("diting");
mouse_id = "ly_diting";
hp = 200000; maxhp = 200000;

// ===== 数值 =====
atk = LY_DITING_SKILL1_DMG;        // 技能伤害（400）
wait_time = 300;                   // 待机时长（步）：技能结束后 5 秒（60fps）
ly_move_speed = 2;                 // 遁地移动速度（像素/步，占位可调）
ly_ambush_col = -1; ly_ambush_row = -1; // 技能1钻出目标格（-1 表示未选定）

ly_boss_step = function() {
    var _act, _tcol, _tpos;

    // 遁地期间（常规移动钻入/地下段、技能1 含前置重置阶段、高速横移段）无敌。
    invincible = false;
    if (state == BOSS_STATE.MOVE && ly_phase < 2) invincible = true;
    if (state == BOSS_STATE.SKILL1 && ly_phase < 2) invincible = true;

    switch (state) {
        case BOSS_STATE.APPEAR: {
            _act = longyuan_variant("正常出生", "破损出生");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.IDLE; }
            break;
        }
        case BOSS_STATE.IDLE: {
            _act = longyuan_variant("正常待机", "破损待机");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, true);
            if (timer >= wait_time) {
                timer = 0; ly_hit = false; ly_ambush_col = -1;
                var _roll = irandom(99);
                if (_roll < 40) { state = BOSS_STATE.MOVE; ly_phase = 0; }
                else if (_roll < 65) { state = BOSS_STATE.SKILL1; ly_phase = (grid_col <= 0) ? -1 : 0; }
                else if (_roll < 85) { state = BOSS_STATE.SKILL2; ly_phase = 0; }
                else { state = BOSS_STATE.SKILL3; ly_phase = 0; }
            }
            break;
        }
        case BOSS_STATE.MOVE: {
            // 遁地移动：钻入（无敌）→ 向左移动到本行最左卡片所在列右侧 → 钻出 → 待机
            if (ly_phase == 0) {
                _act = longyuan_variant("正常钻入", "破损钻入");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) {
                _act = longyuan_variant("正常遁地移动", "破损遁地移动");
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
        case BOSS_STATE.SKILL1: { // 技能1：遁地突袭——若已在最左列则先重置位置，再钻入→高速横移→钻出造成 3×3 伤害
            if (ly_phase == -1) {
                // 前置阶段1：在最左列，先钻入地下
                _act = longyuan_variant("正常技能1钻入", "破损技能1钻入");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    // 重置位置到最右列同一行
                    var _reset = get_world_position_from_grid(global.grid_cols - 1, grid_row);
                    x = _reset.x; y = _reset.y;
                    timer = 0; ly_phase = -2;
                }
            }
            else if (ly_phase == -2) {
                // 前置阶段2：重置位置后播放出生（apper）动画
                _act = longyuan_variant("正常出生", "破损出生");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; ly_phase = 0; }
            }
            else if (ly_phase == 0) {
                _act = longyuan_variant("正常技能1钻入", "破损技能1钻入");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 1; timer = 0; ly_ambush_col = -1; }
            }
            else if (ly_phase == 1) {
                // 高速横移：目标只在本行内选（保证向左移动能到达），到达目标列后才钻出。
                if (ly_ambush_col < 0) {
                    ly_ambush_row = grid_row;
                    ly_ambush_col = longyuan_diting_dense_col_in_row(grid_row, grid_col);
                }
                _act = longyuan_variant("正常技能1移动", "破损技能1移动");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                x -= ly_move_speed * 2; // 地下高速横移
                var _tp = get_world_position_from_grid(ly_ambush_col, ly_ambush_row);
                if (x <= _tp.x) { x = _tp.x; ly_phase = 2; timer = 0; }
            }
            else {
                _act = longyuan_variant("正常技能1钻出", "破损技能1钻出");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (!ly_hit && ly_frame >= 16) {
                    longyuan_diting_damage_3x3(ly_ambush_col, ly_ambush_row, LY_DITING_SKILL1_DMG);
                    longyuan_diting_prison_fuse_3x3(ly_ambush_col, ly_ambush_row);
                    ly_hit = true;
                }
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    ly_phase = 0; ly_hit = false; timer = 0; state = BOSS_STATE.IDLE;
                }
            }
            break;
        }
        case BOSS_STATE.SKILL2: { // 技能2：在本行发射音波并周期性伤害本行卡片
            _act = longyuan_variant("正常技能2", "破损技能2");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (timer == 20) {
                var _pos = get_world_position_from_grid(global.grid_cols - 1, grid_row);
                var _wave = instance_create_depth(_pos.x, _pos.y - 20, -1300, obj_ly_boss_fx);
                longyuan_boss_fx_start(_wave, "diting_soundwave", "待机", true, 5);
                _wave.fx_kind = "diting_soundwave_live";
                _wave.fx_row = grid_row; _wave.fx_direction = -1; _wave.fx_speed = 6;
                _wave.fx_life = 0; _wave.fx_damage_timer = 0; _wave.fx_stuck = false;
                _wave.fx_damage = LY_DITING_SOUNDWAVE_DPS;
            }
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.IDLE; }
            break;
        }
        case BOSS_STATE.SKILL3: { // 技能3：在随机 7 张卡片位置生成可攻击的钟
            _act = longyuan_variant("正常技能3", "破损技能3");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (timer == 20) {
                var _cards = [];
                with (obj_card_parent) {
                    if (hp > 0 && plant_id != "player" && plant_type != "coffee") array_push(_cards, id);
                }
                for (var _i = array_length(_cards) - 1; _i > 0; --_i) {
                    var _j = irandom(_i), _swap = _cards[_i]; _cards[_i] = _cards[_j]; _cards[_j] = _swap;
                }
                var _placed = 0;
                for (var _i = 0; _i < array_length(_cards) && _placed < LY_DITING_PRISON_COUNT; ++_i) {
                    if (!instance_exists(_cards[_i])) continue;
                    var _col = _cards[_i].grid_col, _row = _cards[_i].grid_row;
                    var _dup = false;
                    with (obj_ly_diting_prison) if (grid_col == _col && grid_row == _row && hp > 0) _dup = true;
                    if (_dup) continue;
                    instance_create_depth(_cards[_i].x, _cards[_i].y, -600, obj_ly_diting_prison,
                        {prison_col: _col, prison_row: _row});
                    _placed++;
                }
            }
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.IDLE; }
            break;
        }
    }
};
