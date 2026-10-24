event_inherited();
image_speed = 0; // 动画完全由 longyuan_clip_* 驱动

// ===== 哼哈二将·马面 =====
ly_kind = "hengha_horseface";
ly_anims = longyuan_animation_table("hengha_horseface");
mouse_id = "ly_hengha";
hp = 150000; maxhp = 150000;

// ===== 数值 =====
wait_time = 300;      // 待机 5 秒（60fps）
ly_move_speed = 3;    // 技能1 战略转移真实滑行速度（像素/步）
ly_skill_index = 0;

// 事件联动信号（牛头经 ly_shared_boss_peer 读取）
ly_skill1_seq = 0;        // 技能1 战略转移完成信号
ly_bell_seq = 0;          // 掷铃批次号（每掷一次 +1）
ly_bell_pending = false;  // 已进场掷铃：牛头先去第9列等待
ly_bell_thrown = false;   // 铃铛已实际抛出：牛头起跳敲钟
ly_bell_row = -1;
ly_bell_col = -1;
ly_bell_inst = noone;
ly_spirit_seq = 0;        // 食灵批次号
ly_spirits_ready = false; // 所有食灵已生成：牛头前往第8列
ly_spirits_done = false;  // 马面技能3演出完成：牛头才开始播放吸收动画
ly_peer_done = 0;         // 牛头已完成技能数（用于同步节奏：马面必须等牛头做完上一个技能）

// ===== 技能1：战略转移 路径 =====
// 1基 (4,6) → (4,1) 即 row 不变 col 5→0（同一行内向上=列递减，或者用户本意行递减）
// 按用户描述理解为：入场到 (row=3, col=5)，向上滑行 → row=0, col=5（列不变行递减）
ly_strat_row = 3;   // 第4行（1基）= grid_row 3
ly_strat_col = 5;   // 第6列（1基）= grid_col 5
ly_strat_dest_row = 0; // 向上滑行到第1行（1基）= grid_row 0

// ===== 技能3：召唤食灵 7 个位置 =====
// 图示展开：
// 7 0 1
// 6 x 2
// 5 4 3
// 顺序 1→2→3→4→5→6→7（跳过 0 和 x 钟本身）
// 以钟为 (0,0)，相对坐标（col_offset, row_offset）
ly_spirit_offsets = [
    [ 1, -1], [ 1,  0], [ 1,  1],   // 1右上, 2右, 3右下
    [ 0,  1], [-1,  1], [-1,  0],   // 4下, 5左下, 6左
    [-1, -1],                        // 7左上
];
ly_spirit_i = 0;

ly_boss_step = function() {
    var _act, _tpos, _off, _bell_pos;

    switch (state) {
        case BOSS_STATE.APPEAR: {
            // 出场动画：spr_ly_hengha_mamian_apper 45帧
            _act = longyuan_variant("正常出生", "破损出生");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (longyuan_clip_done(timer, ly_anim_rate)) {
                timer = 0; state = BOSS_STATE.IDLE;
            }
            break;
        }

        case BOSS_STATE.IDLE: {
            // 未释放技能时播放有铃铛待机（spr_ly_hengha_mamian_bell_idel 24帧）
            _act = longyuan_variant("正常有铃铛待机", "破损有铃铛待机");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, true);
            if (timer >= wait_time && (ly_peer_done >= ly_skill_index || !instance_exists(ly_shared_boss_peer))) {
                timer = 0; ly_phase = 0; ly_hit = false;
                // 1→2→3→1 循环，马面先触发
                // 注意：状态切换后下一帧 timer 已变成 1，所以初始化必须写在切换的同一帧
                if (ly_skill_index mod 3 == 0) {
                    state = BOSS_STATE.MOVE;     // SKILL1 战略转移
                }
                else if (ly_skill_index mod 3 == 1) {
                    // SKILL2 配合掷铃：马面随机出现在任意一行的第9列，钟落在本行第2~5列
                    with (obj_ly_boss_fx) {
                        if (fx_kind == "hengha_bell" && variable_instance_exists(id, "fx_bell_stage") && fx_bell_stage != 5) {
                            fx_bell_leave = true;
                        }
                    }
                    ly_bell_row = irandom_range(0, global.grid_rows - 1);
                    ly_bell_col = irandom_range(1, 4);   // 1基第2~5列
                    ly_bell_pending = true;
                    ly_bell_thrown = false;
                    ly_bell_inst = noone;
                    ly_bell_seq++;
                    state = BOSS_STATE.SKILL1;
                }
                else {
                    state = BOSS_STATE.SKILL2;   // SKILL3 召唤食灵
                }
                ly_skill_index++;
            }
            break;
        }

        // ===== 技能1：战略转移 =====
        case BOSS_STATE.MOVE: {
            if (ly_phase == 0) {
                // 进场：nobell_chuxian 从第4行第6列播出现动画
                _act = longyuan_variant("正常无铃出现", "破损无铃出现");
                if (ly_action != _act) {
                    longyuan_clip_set(_act);
                    _tpos = get_world_position_from_grid(ly_strat_col, ly_strat_row);
                    x = _tpos.x; y = _tpos.y;
                }
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    ly_phase = 1; timer = 0;
                }
            }
            else if (ly_phase == 1) {
                // 真实向上滑行：skill2_xunhuan 循环 + y 递减
                _act = longyuan_variant("正常技能2循环", "破损技能2循环");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                y -= ly_move_speed;
                _tpos = get_world_position_from_grid(ly_strat_col, ly_strat_dest_row);
                if (y <= _tpos.y) {
                    x = _tpos.x; y = _tpos.y;
                    // 到达目标行：一次性摧毁起点到终点之间所有中间行的卡片
                    var _r1 = max(ly_strat_dest_row, ly_strat_row);
                    var _r2 = min(ly_strat_dest_row, ly_strat_row);
                    for (var _r = _r2; _r <= _r1; ++_r) {
                        longyuan_damage_cell(ly_strat_col, _r, 0, true);
                    }
                    ly_phase = 2; timer = 0;
                }
            }
            else {
                // 到达：nobell_disapper 消失 + 给牛头发 skill1_seq 信号
                _act = longyuan_variant("正常无铃消失", "破损无铃消失");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    x = -200;
                    ly_skill1_seq++;
                    ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE;
                }
            }
            break;
        }

        // ===== 技能2：配合掷铃 =====
        case BOSS_STATE.SKILL1: {
            if (ly_phase == 0) {
                // 进场：nobell_chuxian 从场外进入本行第9列（grid_col 8）
                _act = longyuan_variant("正常无铃出现", "破损无铃出现");
                if (ly_action != _act) {
                    longyuan_clip_set(_act);
                    _tpos = get_world_position_from_grid(8, ly_bell_row); // 第9列
                    x = _tpos.x + global.grid_cell_size_x; y = _tpos.y;
                }
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    ly_phase = 1; timer = 0;
                }
            }
            else if (ly_phase == 1) {
                // 向第9列滑入
                _act = longyuan_variant("正常技能2循环", "破损技能2循环");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                x -= ly_move_speed;
                _tpos = get_world_position_from_grid(8, ly_bell_row);
                if (x <= _tpos.x) { x = _tpos.x; ly_phase = 2; timer = 0; }
            }
            else if (ly_phase == 2) {
                // 抛铃：skill1_paochu1，在最后一帧抛出铃铛
                _act = longyuan_variant("正常技能1抛出1", "破损技能1抛出1");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    // 最后一帧抛出铃铛：飞到 (ly_bell_col, ly_bell_row)
                    _bell_pos = get_world_position_from_grid(ly_bell_col, ly_bell_row);
                    var _bell = instance_create_depth(x, y - 35, -200, obj_ly_boss_fx);
                    longyuan_boss_fx_start(_bell, "hengha_bell", "飞行", false, 5, "", false);
                    _bell.fx_kind = "hengha_bell";
                    // 钟自己管理的生命周期状态，先初始化好，避免首帧读取时序问题
                    _bell.fx_bell_stage = 0;
                    _bell.fx_bell_stage2 = false;
                    _bell.fx_bell_leave = false;
                    _bell.fx_bell_ring = false;
                    _bell.fx_bell_ringing = false;
                    // 目标同时记录网格与像素坐标，飞行阶段优先用像素坐标
                    _bell.fx_target_col = ly_bell_col;
                    _bell.fx_target_row = ly_bell_row;
                    _bell.fx_target_x = _bell_pos.x;
                    _bell.fx_target_y = _bell_pos.y;
                    _bell.image_xscale = 2; // 钟放大 2 倍
                    _bell.image_yscale = 2;
                    ly_bell_inst = _bell;
                    ly_bell_thrown = true;
                    ly_phase = 3; timer = 0;
                }
            }
            else if (ly_phase == 3) {
                // 马面消失：nobell_disapper
                _act = longyuan_variant("正常无铃消失", "破损无铃消失");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    x = -200;
                    ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE;
                }
            }
            break;
        }

        // ===== 技能3：召唤食灵（铃铛已在场上，以 ly_bell_col/row 为中心）=====
        case BOSS_STATE.SKILL2: {
            // 如果没有铃铛位置（skill2 没触发过），用默认第5行第5列
            if (ly_bell_row < 0) { ly_bell_row = 4; ly_bell_col = 4; }

            // 通知场上的钟切「待机2」（钟自己的 Step 会处理切换）
            with (obj_ly_boss_fx) {
                if (fx_kind == "hengha_bell" && variable_instance_exists(id, "fx_bell_stage")
                    && fx_bell_stage >= 1 && fx_bell_stage <= 3 && !fx_bell_leave) {
                    fx_bell_stage2 = true;
                }
            }

            if (ly_phase == 0) {
                // 从钟右一列出现（col+1, row），播放 nobell_chuxian
                ly_spirits_done = false; // 本轮演出开始
                var _start_c = clamp(ly_bell_col + 1, 0, global.grid_cols - 1);
                _tpos = get_world_position_from_grid(_start_c, ly_bell_row);
                x = _tpos.x; y = _tpos.y;
                ly_spirit_i = 0;
                _act = longyuan_variant("正常无铃出现", "破损无铃出现");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) {
                // 依次滑过 7 个位置，每到一格生成 food_apper/food_idel
                _off = ly_spirit_offsets[ly_spirit_i];
                var _tc = ly_bell_col + _off[0];
                var _tr = ly_bell_row + _off[1];
                // 边界保护
                if (_tc < 0 || _tc >= global.grid_cols || _tr < 0 || _tr >= global.grid_rows) {
                    // 越界则跳过，直接下一个
                    ly_spirit_i++; timer = 0;
                    if (ly_spirit_i >= array_length(ly_spirit_offsets)) { ly_phase = 2; timer = 0; ly_spirits_ready = true; ly_spirit_seq++; }
                    break;
                }
                _tpos = get_world_position_from_grid(_tc, _tr);
                // 真实滑行
                _act = longyuan_variant("正常技能2循环", "破损技能2循环");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                // 用帧驱动，大约 20 帧到达（skill2_xunhuan 20帧/10帧正常）
                var _dist = point_distance(x, y, _tpos.x, _tpos.y);
                if (_dist > 2) {
                    var _ang = point_direction(x, y, _tpos.x, _tpos.y);
                    x += lengthdir_x(ly_move_speed, _ang);
                    y += lengthdir_y(ly_move_speed, _ang);
                } else {
                    x = _tpos.x; y = _tpos.y;
                    // 到达该格：生成食灵；卡片在 food_apper 播完后由食灵自行销毁
                    var _fx_pos = get_world_position_from_grid(_tc, _tr);
                    var _spr = instance_create_depth(_fx_pos.x, _fx_pos.y - 30, -200, obj_ly_hengha_spirit);
                    _spr.ly_kill_col = _tc;
                    _spr.ly_kill_row = _tr;
                    ly_spirit_i++; timer = 0;
                    if (ly_spirit_i >= array_length(ly_spirit_offsets)) {
                        ly_phase = 2; timer = 0;
                        ly_spirits_ready = true; ly_spirit_seq++;
                    }
                }
            }
            else if (ly_phase == 2) {
                // 移动到最后位置（7）后：所有 food 同时 food_dead
                // 这里 food_dead 的触发由 spirit 自己在检测到被吸收时处理
                // 马面播放 nobell_disapper 消失
                _act = longyuan_variant("正常无铃消失", "破损无铃消失");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    x = -200;
                    ly_spirits_done = true; // 马面技能3演出完成，牛头可以播放吸收动画
                    ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE;
                }
            }
            break;
        }
    }
};
