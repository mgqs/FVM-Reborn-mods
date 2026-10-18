event_inherited();
image_speed = 0; // 动画完全由 longyuan_clip_* 驱动

// ===== 哼哈二将·马面 =====
ly_kind = "hengha_horseface";
ly_anims = longyuan_animation_table("hengha_horseface");
mouse_id = "ly_hengha_horseface";
hp = 150000; maxhp = 150000;

// ===== 占位数值（可调）=====
wait_time = 60;      // 占位：两轮技能之间的待机时长（步）
ly_move_speed = 3;   // 占位：战略转移进场滑动速度（像素/步）
ly_rise_speed = 4;   // 占位：召食灵后向最上方消失的速度（像素/步）
ly_skill_index = 0;

// 战略转移路径点（第6列：col index 5；第4→3→2→1行：row index 3→2→1→0）
ly_move_inited = false;
ly_pi = 0;

// 与牛头事件联动的信号（牛头经 ly_shared_boss_peer 读取）
ly_bell_seq = 0;          // 掷铃批次号（每掷一次 +1）
ly_bell_pending = false;  // 已开始进场掷铃：牛头先去第9列等待
ly_bell_thrown = false;   // 铃铛已实际抛出：牛头起跳敲钟
ly_bell_row = -1;
ly_bell_col = -1;
ly_bell_inst = noone;
ly_spirit_seq = 0;        // 食灵批次号
ly_spirits_ready = false; // 8 个食灵已生成：牛头释放吸收

// 召唤食灵：以铃铛为中心，从“左下”起 3×3 外环顺时针 8 格（col,row 增量）
ly_ring_offsets = [
    [-1,  1], [ 0,  1], [ 1,  1],
    [ 1,  0],            [ 1, -1],
    [ 0, -1], [-1, -1], [-1,  0],
];
ly_si = 0;

ly_boss_step = function() {
    var _act, _tpos;

    switch (state) {
        case BOSS_STATE.APPEAR: {
            if (ly_action != "出生") longyuan_clip_set("出生");
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.MOVE; }
            break;
        }

        // ===== 技能1：战略转移（一次性）=====
        case BOSS_STATE.MOVE: {
            if (ly_phase == 0) {
                // 从第 4 行右侧进场，走到 (4,6)
                if (!ly_move_inited) {
                    ly_move_inited = true;
                    _tpos = get_world_position_from_grid(5, 3);
                    x = _tpos.x + global.grid_cell_size_x * 2;
                    y = _tpos.y;
                    timer = 0;
                }
                _act = longyuan_variant("正常有铃铛待机", "破损有铃铛待机");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                var _dest = get_world_position_from_grid(5, 3);
                x = max(_dest.x, x - ly_move_speed);
                if (x <= _dest.x) { ly_phase = 1; ly_pi = 1; timer = 0; }
            }
            else if (ly_phase == 1) {
                // 消失后向上跳动一格（3,6）（2,6）（1,6）
                _act = longyuan_variant("正常无铃消失", "破损无铃消失");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    _tpos = get_world_position_from_grid(5, 3 - ly_pi);
                    x = _tpos.x; y = _tpos.y;
                    ly_phase = 2; timer = 0;
                }
            }
            else {
                _act = longyuan_variant("正常无铃出现", "破损无铃出现");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    ly_pi++;
                    timer = 0;
                    if (ly_pi > 3) { ly_phase = 0; state = BOSS_STATE.IDLE; }
                    else ly_phase = 1;
                }
            }
            break;
        }

        case BOSS_STATE.IDLE: {
            _act = longyuan_variant("正常有铃铛待机", "破损有铃铛待机");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, true);
            if (timer >= wait_time) {
                timer = 0; ly_phase = 0;
                var _cycle = [BOSS_STATE.SKILL1, BOSS_STATE.SKILL2]; // 掷铃 → 召食灵
                state = _cycle[ly_skill_index mod array_length(_cycle)];
                ly_skill_index++;
            }
            break;
        }

        // ===== 技能2：配合掷铃（随机第2-6行，停第8列，向本行第2或第5列掷 1 个铃铛）=====
        case BOSS_STATE.SKILL1: {
            if (timer == 0 && ly_phase == 0) {
                ly_bell_row = irandom_range(1, min(5, global.grid_rows - 2));
                ly_bell_col = choose(1, 4); // 第2列(index1) 或 第5列(index4)
                ly_bell_pending = true;
                ly_bell_thrown = false;
                ly_bell_inst = noone;
                ly_bell_seq++;
            }
            if (ly_phase == 0) {
                _act = longyuan_variant("正常无铃消失", "破损无铃消失");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    _tpos = get_world_position_from_grid(7, ly_bell_row); // 停在第8列
                    x = _tpos.x; y = _tpos.y;
                    ly_phase = 1; timer = 0;
                }
            }
            else if (ly_phase == 1) {
                _act = longyuan_variant("正常技能1开始", "破损技能1开始");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 2; timer = 0; }
            }
            else if (ly_phase == 2) {
                _act = longyuan_variant("正常技能1抛出1", "破损技能1抛出1");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (timer == 30) {
                    var _bell_pos = get_world_position_from_grid(ly_bell_col, ly_bell_row);
                    ly_bell_inst = instance_create_depth(_bell_pos.x, _bell_pos.y - 35, -200, obj_ly_boss_fx);
                    longyuan_boss_fx_start(ly_bell_inst, "hengha_bell", "飞行", false, 5, "变大", false);
                    ly_bell_thrown = true;
                }
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 3; timer = 0; }
            }
            else {
                // 掷完后消失
                _act = longyuan_variant("正常无铃消失", "破损无铃消失");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    x = room_width + 200;
                    ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE;
                }
            }
            break;
        }

        // ===== 技能3：召唤食灵（铃铛 3×3 外环顺时针 8 格各生 1 个，随后向该列最上方消失）=====
        case BOSS_STATE.SKILL2: {
            if (ly_bell_row < 0) { timer = 0; ly_phase = 0; state = BOSS_STATE.IDLE; break; }
            if (ly_phase == 0) {
                // 直接落到铃铛左下格（本体在场外，无需消失动画）
                var _c0 = ly_bell_col + ly_ring_offsets[0][0];
                var _r0 = ly_bell_row + ly_ring_offsets[0][1];
                _tpos = get_world_position_from_grid(_c0, _r0);
                x = _tpos.x; y = _tpos.y;
                ly_si = 0;
                _act = longyuan_variant("正常技能2开始", "破损技能2开始");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) {
                var _off = ly_ring_offsets[ly_si];
                if (timer == 0) {
                    _tpos = get_world_position_from_grid(ly_bell_col + _off[0], ly_bell_row + _off[1]);
                    x = _tpos.x; y = _tpos.y;
                }
                _act = longyuan_variant("正常技能2循环", "破损技能2循环");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (timer == 25) {
                    var _sp_pos = get_world_position_from_grid(ly_bell_col + _off[0], ly_bell_row + _off[1]);
                    instance_create_depth(_sp_pos.x, _sp_pos.y - 30, -200, obj_ly_hengha_spirit);
                }
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    ly_si++;
                    timer = 0;
                    if (ly_si >= array_length(ly_ring_offsets)) ly_phase = 2;
                }
            }
            else if (ly_phase == 2) {
                // 通知牛头吸收，随后沿铃铛列向最上方消失
                if (timer == 0) {
                    ly_spirits_ready = true;
                    ly_spirit_seq++;
                }
                _act = longyuan_variant("正常技能2循环", "破损技能2循环");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                y -= ly_rise_speed;
                if (y < -200) { ly_phase = 3; timer = 0; }
            }
            else {
                _act = longyuan_variant("正常技能2结束", "破损技能2结束");
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
