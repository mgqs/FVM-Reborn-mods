event_inherited();
image_speed = 0; // 动画完全由 longyuan_clip_* 驱动

// ===== 哼哈二将·牛头（与马面共享血量）=====
ly_kind = "hengha_oxhead";
ly_anims = longyuan_animation_table("hengha_oxhead");
mouse_id = "ly_hengha_oxhead";
hp = 150000; maxhp = 150000;

// ===== 占位数值（可调）=====
wait_time = 60;      // 占位：待机时长（步）
ly_move_speed = 2;   // 占位：左移速度（像素/步）
ly_charge_speed = 5; // 占位：配合敲钟冲撞速度（像素/步）
ly_skill_index = 0;

// 联动批次记录（技能2敲钟、技能3吸收均为事件驱动，不进入自主循环）
ly_bell_seq_seen = 0;
ly_spirit_seq_seen = 0;
ly_link_row = 0;
ly_link_col = 0;
ly_jumped = false;
ly_absorb_row = 0;

// 自主技能1落点
ly_aim_col = 0;
ly_aim_row = 0;

ly_boss_step = function() {
    var _act, _tpos, _peer;
    _peer = ly_shared_boss_peer;

    switch (state) {
        case BOSS_STATE.APPEAR: {
            if (ly_action != "出生") longyuan_clip_set("出生");
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.IDLE; }
            break;
        }

        case BOSS_STATE.IDLE: {
            // —— 事件驱动：优先响应马面信号 ——
            var _bell_link = instance_exists(_peer)
                && variable_instance_exists(_peer, "ly_bell_pending")
                && _peer.ly_bell_pending
                && _peer.ly_bell_seq > ly_bell_seq_seen;
            var _spirit_link = instance_exists(_peer)
                && variable_instance_exists(_peer, "ly_spirits_ready")
                && _peer.ly_spirits_ready
                && _peer.ly_spirit_seq > ly_spirit_seq_seen;
            if (_bell_link) {
                ly_bell_seq_seen = _peer.ly_bell_seq;
                ly_link_row = _peer.ly_bell_row;
                ly_link_col = _peer.ly_bell_col;
                ly_phase = 0; timer = 0; state = BOSS_STATE.SKILL2;
            }
            else if (_spirit_link) {
                ly_spirit_seq_seen = _peer.ly_spirit_seq;
                ly_jumped = false;
                ly_phase = 0; timer = 0; state = BOSS_STATE.SKILL3;
            }
            else {
                _act = longyuan_variant("正常待机", "破损待机");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                if (timer >= wait_time) {
                    timer = 0; ly_phase = 0;
                    var _cycle = [BOSS_STATE.MOVE, BOSS_STATE.SKILL1]; // 自主循环：移动/闪现、跳跃砸击
                    state = _cycle[ly_skill_index mod array_length(_cycle)];
                    ly_skill_index++;
                }
            }
            break;
        }

        // ===== 移动与闪现：先向左移动，闪出 → 闪现到本行目标列右侧 → 闪进 =====
        case BOSS_STATE.MOVE: {
            if (ly_phase == 0) {
                _act = longyuan_variant("正常移动", "破损移动");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                x -= ly_move_speed;
                if (timer >= 24) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) {
                _act = longyuan_variant("正常闪出", "破损闪出");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    var _tcol = ly_target_col();
                    _tpos = get_world_position_from_grid(_tcol, grid_row);
                    x = _tpos.x + 60;
                    ly_phase = 2; timer = 0;
                }
            }
            else {
                _act = longyuan_variant("正常闪进", "破损闪进");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE; }
            }
            break;
        }

        // ===== 技能1：跳跃砸击（3-7列、2-6行随机格，十字9格各 400）=====
        case BOSS_STATE.SKILL1: {
            if (timer == 0 && ly_phase == 0) {
                ly_aim_col = irandom_range(2, min(6, global.grid_cols - 1));
                ly_aim_row = irandom_range(1, min(5, global.grid_rows - 2));
            }
            if (ly_phase == 0) {
                _act = longyuan_variant("正常跳跃预备", "破损跳跃预备");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) {
                _act = longyuan_variant("正常跳跃", "破损跳跃");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    _tpos = get_world_position_from_grid(ly_aim_col, ly_aim_row);
                    x = _tpos.x; y = _tpos.y;
                    ly_phase = 2; timer = 0;
                }
            }
            else {
                _act = longyuan_variant("正常下落", "破损下落");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    longyuan_damage_cross(ly_aim_col, ly_aim_row, LY_HENGHA_SLAM_DMG);
                    if (global.screen_shake) Camera_Shock(8, 25);
                    ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE;
                }
            }
            break;
        }

        // ===== 技能2：配合敲钟（事件驱动）=====
        case BOSS_STATE.SKILL2: {
            if (ly_phase == 0) { // 闪出
                _act = longyuan_variant("正常闪出", "破损闪出");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    _tpos = get_world_position_from_grid(8, ly_link_row); // 先到第9列等待
                    x = _tpos.x; y = _tpos.y;
                    ly_phase = 1; timer = 0;
                }
            }
            else if (ly_phase == 1) { // 闪进
                _act = longyuan_variant("正常闪进", "破损闪进");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 2; timer = 0; }
            }
            else if (ly_phase == 2) { // 等待马面抛出铃铛
                _act = longyuan_variant("正常待机", "破损待机");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                var _thrown = instance_exists(_peer) && variable_instance_exists(_peer, "ly_bell_thrown") && _peer.ly_bell_thrown;
                if (_thrown || timer > 600) { ly_phase = 3; timer = 0; }
            }
            else if (ly_phase == 3) { // 跳跃预备
                _act = longyuan_variant("正常跳跃预备", "破损跳跃预备");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 4; timer = 0; }
            }
            else if (ly_phase == 4) { // 跳到 (铃行, 铃列+4)
                _act = longyuan_variant("正常跳跃", "破损跳跃");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    _tpos = get_world_position_from_grid(ly_link_col + 4, ly_link_row);
                    x = _tpos.x; y = _tpos.y;
                    ly_phase = 5; timer = 0;
                }
            }
            else if (ly_phase == 5) { // 下落
                _act = longyuan_variant("正常下落", "破损下落");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 6; timer = 0; }
            }
            else if (ly_phase == 6) { // 冲撞：摧毁 (铃列+3)(铃列+2) 两格全部美食
                _act = longyuan_variant("正常技能2", "破损技能2");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                if (timer == 0) {
                    longyuan_damage_cell(ly_link_col + 3, ly_link_row, 0, true);
                    longyuan_damage_cell(ly_link_col + 2, ly_link_row, 0, true);
                }
                var _charge_pos = get_world_position_from_grid(ly_link_col + 2, ly_link_row);
                x = max(_charge_pos.x, x - ly_charge_speed);
                if (x <= _charge_pos.x) { ly_phase = 7; timer = 0; }
            }
            else { // 敲铃铛：对铃铛周围 3×3 各 40 伤害，铃铛特效同步摇晃
                _act = longyuan_variant("正常技能2", "破损技能2");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                if (timer == 0) {
                    for (var _c = ly_link_col - 1; _c <= ly_link_col + 1; ++_c) {
                        for (var _r = ly_link_row - 1; _r <= ly_link_row + 1; ++_r)
                            longyuan_damage_cell(_c, _r, LY_HENGHA_BELL_RING_DMG);
                    }
                    if (instance_exists(_peer) && variable_instance_exists(_peer, "ly_bell_inst"))
                        longyuan_hengha_bell_ring(_peer.ly_bell_inst);
                    if (global.screen_shake) Camera_Shock(5, 15);
                }
                if (timer >= 35) {
                    if (instance_exists(_peer)) {
                        _peer.ly_bell_pending = false;
                        _peer.ly_bell_thrown = false;
                    }
                    ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE;
                }
            }
            break;
        }

        // ===== 技能3：吸收魂体（事件驱动）=====
        case BOSS_STATE.SKILL3: {
            if (ly_phase == 0) { // 闪出，随机跳到第8列一格
                _act = longyuan_variant("正常闪出", "破损闪出");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    ly_absorb_row = irandom_range(1, min(5, global.grid_rows - 2));
                    _tpos = get_world_position_from_grid(7, ly_absorb_row);
                    x = _tpos.x; y = _tpos.y;
                    ly_phase = 1; timer = 0;
                }
            }
            else if (ly_phase == 1) { // 闪进 + 播放吸收动画
                _act = longyuan_variant("正常闪进", "破损闪进");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 2; timer = 0; }
            }
            else if (ly_phase == 2) { // 播吸收动画，随后全体食灵开始向第9列移动
                _act = longyuan_variant("正常技能3", "破损技能3");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                if (timer >= 40) {
                    with (obj_ly_hengha_spirit) {
                        ly_absorbing = true;
                        ly_absorb_boss = other.id;
                    }
                    ly_phase = 3; timer = 0;
                }
            }
            else if (ly_phase == 3) { // 等待有食灵抵达第9列
                _act = longyuan_variant("正常技能3", "破损技能3");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                var _reach = false;
                with (obj_ly_hengha_spirit) if (grid_col >= global.grid_cols - 1) _reach = true;
                if (_reach) { ly_phase = 4; timer = 0; }
                else if (instance_number(obj_ly_hengha_spirit) == 0 || timer > 1200) { ly_phase = 6; timer = 0; }
            }
            else if (ly_phase == 4) { // 跳到第9列：闪出
                _act = longyuan_variant("正常闪出", "破损闪出");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    _tpos = get_world_position_from_grid(8, ly_absorb_row);
                    x = _tpos.x; y = _tpos.y;
                    ly_phase = 5; timer = 0;
                }
            }
            else if (ly_phase == 5) { // 闪进后再次播放吸收动画
                _act = longyuan_variant("正常闪进", "破损闪进");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 6; timer = 0; }
            }
            else { // 等所有食灵消散/被消灭
                _act = longyuan_variant("正常技能3", "破损技能3");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                if (instance_number(obj_ly_hengha_spirit) == 0 || timer > 1200) {
                    if (instance_exists(_peer)) _peer.ly_spirits_ready = false;
                    ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE;
                }
            }
            break;
        }
    }
};
