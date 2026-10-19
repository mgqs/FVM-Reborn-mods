event_inherited();
image_speed = 0;
ly_kind = "youshen";
ly_anims = longyuan_animation_table("youshen");
mouse_id = "ly_youshen";
hp = 100000; maxhp = 100000;
wait_time = 300; // 每次技能/移动结束后待机 5 秒（60fps）
ly_scroll_speed = 8;
ly_charge_speed = 5;
ly_phase = 0;
ly_scroll_row = 1; ly_scroll_col = 1;
ly_move_row = 1;
ly_start_col = 1; ly_start_row = 1;
ly_charge_col = 3; ly_charge_dir = 1; ly_next_row = 0;

ly_boss_step = function() {
    var _pos;
    switch (state) {
        case BOSS_STATE.APPEAR:
            if (ly_phase == 0) {
                _pos = get_world_position_from_grid(min(8, global.grid_cols - 1), min(3, global.grid_rows - 1));
                x = _pos.x; y = _pos.y; ly_phase = 1; timer = 0;
            }
            var _appear_act = longyuan_variant("正常出生", "破损出生");
            if (ly_action != _appear_act) longyuan_clip_set(_appear_act);
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; ly_phase = 0; state = BOSS_STATE.IDLE; }
            break;
        case BOSS_STATE.IDLE:
            var _idle_act = longyuan_variant("正常待机", "破损待机");
            if (ly_action != _idle_act) longyuan_clip_set(_idle_act);
            longyuan_clip_frame(timer, ly_anim_rate, true);
            if (timer >= wait_time) {
                var _roll = irandom(99); timer = 0; ly_phase = 0;
                if (_roll < 40) state = BOSS_STATE.MOVE;
                else if (_roll < 65) state = BOSS_STATE.SKILL1;
                else if (_roll < 85) state = BOSS_STATE.SKILL2;
                else state = BOSS_STATE.SKILL3;
            }
            break;
        case BOSS_STATE.MOVE: // 消失：游出 → 滑行：移动 → 出现：游入
            if (ly_phase == 0) {
                var _out_act = longyuan_variant("正常游出", "破损游出");
                if (ly_action != _out_act) longyuan_clip_set(_out_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    ly_move_row = irandom_range(1, min(5, global.grid_rows - 2));
                    _pos = get_world_position_from_grid(min(8, global.grid_cols - 1), ly_move_row);
                    x = _pos.x + global.grid_cell_size_x * 2; y = _pos.y; timer = 0; ly_phase = 1;
                }
            } else if (ly_phase == 1) {
                var _move_act = longyuan_variant("正常移动", "破损移动");
                if (ly_action != _move_act) longyuan_clip_set(_move_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                _pos = get_world_position_from_grid(min(8, global.grid_cols - 1), ly_move_row);
                x -= 3;
                if (x <= _pos.x + global.grid_cell_size_x) { x = _pos.x + global.grid_cell_size_x; timer = 0; ly_phase = 2; }
            } else {
                var _enter_act = longyuan_variant("正常游入", "破损游入");
                if (ly_action != _enter_act) longyuan_clip_set(_enter_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                _pos = get_world_position_from_grid(min(8, global.grid_cols - 1), ly_move_row);
                x -= 2;
                if (x <= _pos.x) x = _pos.x;
                if (longyuan_clip_done(timer, ly_anim_rate)) { x = _pos.x; timer = 0; ly_phase = 0; state = BOSS_STATE.IDLE; }
            }
            break;
        case BOSS_STATE.SKILL1: // 消失：游出 → 出现：在目标行第9列游入 → 技能1
            if (ly_phase == 0) {
                var _s1_out = longyuan_variant("正常游出", "破损游出");
                if (ly_action != _s1_out) longyuan_clip_set(_s1_out);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    ly_scroll_row = irandom_range(1, min(5, global.grid_rows - 2));
                    ly_scroll_col = irandom_range(1, min(6, global.grid_cols - 3));
                    _pos = get_world_position_from_grid(min(8, global.grid_cols - 1), ly_scroll_row);
                    x = _pos.x; y = _pos.y;
                    timer = 0; ly_phase = 1;
                }
            } else if (ly_phase == 1) {
                var _s1_enter = longyuan_variant("正常游入", "破损游入");
                if (ly_action != _s1_enter) longyuan_clip_set(_s1_enter);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; ly_phase = 2; }
            } else {
                var _skill1_act = longyuan_variant("正常技能1", "破损技能1");
                if (ly_action != _skill1_act) longyuan_clip_set(_skill1_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (timer == 20) {
                    var _target = get_world_position_from_grid(ly_scroll_col, ly_scroll_row);
                    var _scroll = instance_create_depth(x, y - 45, -200, obj_ly_boss_fx);
                    longyuan_boss_fx_start(_scroll, "youshen_scroll", "飞行", true, 5);
                    _scroll.fx_kind = "youshen_scroll_live";
                    _scroll.fx_target_x = _target.x; _scroll.fx_col = ly_scroll_col; _scroll.fx_row = ly_scroll_row; _scroll.fx_speed = ly_scroll_speed;
                }
                if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; ly_phase = 0; state = BOSS_STATE.IDLE; }
            }
            break;
        case BOSS_STATE.SKILL2: // 消失：游出 → 出现：在原点游入 → 技能2
            if (ly_phase == 0) {
                var _s2_out = longyuan_variant("正常游出", "破损游出");
                if (ly_action != _s2_out) longyuan_clip_set(_s2_out);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    ly_start_col = irandom_range(1, min(4, global.grid_cols - 5));
                    ly_start_row = irandom_range(1, min(4, global.grid_rows - 3));
                    _pos = get_world_position_from_grid(ly_start_col, ly_start_row); x = _pos.x; y = _pos.y;
                    timer = 0; ly_phase = 1;
                }
            } else if (ly_phase == 1) {
                var _s2_enter = longyuan_variant("正常游入", "破损游入");
                if (ly_action != _s2_enter) longyuan_clip_set(_s2_enter);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; ly_phase = 2; }
            } else {
                var _s2_act = longyuan_variant("正常技能2", "破损技能2");
                if (ly_action != _s2_act) longyuan_clip_set(_s2_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (timer == 10) {
                    // 以原点为中心 4×6 区域所有卡片沉睡 15 秒；生成一个隐形计时特效在到期后唤醒
                    var _sleep = longyuan_sleep_area(ly_start_col, ly_start_row, 4, 6, LY_YOUSHEN_SLEEP_DUR);
                    var _sleep_fx = instance_create_depth(x, y, -200, obj_ly_boss_fx);
                    _sleep_fx.visible = false;
                    _sleep_fx.fx_kind = "youshen_sleep";
                    _sleep_fx.fx_ready = true;
                    _sleep_fx.fx_loop = true;
                    _sleep_fx.fx_rate = 5;
                    _sleep_fx.fx_life = 0;
                    _sleep_fx.fx_duration = LY_YOUSHEN_SLEEP_DUR;
                    _sleep_fx.fx_cards = _sleep;
                }
                if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; ly_phase = 0; state = BOSS_STATE.IDLE; }
            }
            break;
        case BOSS_STATE.SKILL3: // 消失：游出 → 出现：场边游入 → 准备：技能3 → 冲刺：技能3冲刺 → 收尾：技能3结束
            if (ly_phase == 0) {
                var _s3_out = longyuan_variant("正常游出", "破损游出");
                if (ly_action != _s3_out) longyuan_clip_set(_s3_out);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    ly_charge_col = irandom_range(3, min(5, global.grid_cols - 2));
                    ly_charge_dir = choose(-1, 1); ly_next_row = ly_charge_dir > 0 ? 0 : global.grid_rows - 1;
                    _pos = get_world_position_from_grid(ly_charge_col, ly_next_row);
                    x = _pos.x; y = _pos.y - ly_charge_dir * global.grid_cell_size_y;
                    timer = 0; ly_phase = 1;
                }
            } else if (ly_phase == 1) {
                var _s3_enter = longyuan_variant("正常游入", "破损游入");
                if (ly_action != _s3_enter) longyuan_clip_set(_s3_enter);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; ly_phase = 2; }
            } else if (ly_phase == 2) {
                var _prep_act = longyuan_variant("正常技能3", "破损技能3");
                if (ly_action != _prep_act) longyuan_clip_set(_prep_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; ly_phase = 3; }
            } else if (ly_phase == 3) {
                var _charge_act = longyuan_variant("正常技能3冲刺", "破损技能3冲刺");
                if (ly_action != _charge_act) longyuan_clip_set(_charge_act);
                longyuan_clip_frame(timer, ly_anim_rate, true); y += ly_charge_dir * ly_charge_speed;
                while (ly_next_row >= 0 && ly_next_row < global.grid_rows) {
                    var _row_pos = get_world_position_from_grid(ly_charge_col, ly_next_row);
                    if ((ly_charge_dir > 0 && y < _row_pos.y) || (ly_charge_dir < 0 && y > _row_pos.y)) break;
                    longyuan_damage_cell(ly_charge_col, ly_next_row, 0, true); ly_next_row += ly_charge_dir;
                }
                if (ly_next_row < 0 || ly_next_row >= global.grid_rows) { timer = 0; ly_phase = 4; }
            } else {
                var _charge_end_act = longyuan_variant("正常技能3结束", "破损技能3结束");
                if (ly_action != _charge_end_act) longyuan_clip_set(_charge_end_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; ly_phase = 0; state = BOSS_STATE.IDLE; }
            }
            break;
    }
};
