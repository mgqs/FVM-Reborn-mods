event_inherited();
image_speed = 0; // 动画完全由 longyuan_clip_* 驱动

// ===== 哼哈二将·牛头（与马面共享血量）=====
ly_kind = "hengha_oxhead";
ly_anims = longyuan_animation_table("hengha_oxhead");
mouse_id = "ly_hengha";
hp = 150000; maxhp = 150000;

// 对象无默认精灵：创建当帧先把 sprite_index 设为出生动作，避免 Draw 时精灵为 -1
ly_action = "";
longyuan_play("正常出生");

// ===== 数值 =====
wait_time = 300;       // 待机 5 秒
ly_move_speed = 2;     // 闪现/滑入速度
ly_charge_speed = 5;   // 敲钟冲撞速度
ly_jump_speed = 4;     // 跳跃飞行速度
ly_skill_index = 0;

// 联动批次记录（事件驱动响应马面信号）
ly_skill1_seq_seen = 0;
ly_bell_seq_seen = 0;
ly_spirit_seq_seen = 0;
ly_link_row = 0;
ly_link_col = 0;
ly_absorb_row = 0;

// 自主技能1落点
ly_aim_col = 0;
ly_aim_row = 0;

// 是否已有铃：skill2 敲钟后钟播放 attackidel
ly_has_bell = false;
ly_bell_inst_ref = noone;

ly_boss_step = function() {
    var _act, _tpos, _peer;
    _peer = ly_shared_boss_peer;

    switch (state) {
        case BOSS_STATE.APPEAR: {
            // 出场动画：spr_ly_hengha_niutou_apper 9帧
            _act = longyuan_variant("正常出生", "破损出生");
            if (ly_action != _act) longyuan_clip_set(_act);
            longyuan_clip_frame(timer, ly_anim_rate, false);
            if (longyuan_clip_done(timer, ly_anim_rate)) {
                timer = 0; state = BOSS_STATE.IDLE;
            }
            break;
        }

        case BOSS_STATE.IDLE: {
            // 完全事件驱动：检测马面三个 seq 信号依次触发自己的三个技能
            var _s1 = instance_exists(_peer)
                && variable_instance_exists(_peer, "ly_skill1_seq")
                && _peer.ly_skill1_seq > ly_skill1_seq_seen;
            var _bell_link = instance_exists(_peer)
                && variable_instance_exists(_peer, "ly_bell_pending")
                && _peer.ly_bell_pending
                && _peer.ly_bell_seq > ly_bell_seq_seen;
            var _spirit_link = instance_exists(_peer)
                && variable_instance_exists(_peer, "ly_spirits_ready")
                && _peer.ly_spirits_ready
                && _peer.ly_spirit_seq > ly_spirit_seq_seen;

            if (_s1) {
                ly_skill1_seq_seen = _peer.ly_skill1_seq;
                ly_phase = 0; timer = 0; state = BOSS_STATE.SKILL1;
            }
            else if (_bell_link) {
                ly_bell_seq_seen = _peer.ly_bell_seq;
                ly_link_row = _peer.ly_bell_row;
                ly_link_col = _peer.ly_bell_col;
                ly_phase = 0; timer = 0; state = BOSS_STATE.SKILL2;
            }
            else if (_spirit_link) {
                ly_spirit_seq_seen = _peer.ly_spirit_seq;
                ly_phase = 0; timer = 0; state = BOSS_STATE.SKILL3;
            }
            else {
                // 没有马面信号时只播待机，绝不自主释放技能
                _act = longyuan_variant("正常待机", "破损待机");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
            }
            break;
        }

        // ===== 技能1：跳跃砸击 =====
        case BOSS_STATE.SKILL1: {
            if (ly_phase == 0) {
                // 跳跃预备：spr_ly_hengha_niutou_jumpzhunbei 8帧
                _act = longyuan_variant("正常跳跃预备", "破损跳跃预备");
                if (ly_action != _act) {
                    longyuan_clip_set(_act);
                    // 每次进入技能时随机落点（不能放在 timer==0 的块里：进入时 timer 已经是 1）
                    // 随机 3-7列（1基）= grid_col 2-6；2-6行（1基）= grid_row 1-5
                    ly_aim_col = irandom_range(2, min(6, global.grid_cols - 1));
                    ly_aim_row = irandom_range(1, min(5, global.grid_rows - 1));
                }
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 1; timer = 0; }
            }
            else if (ly_phase == 1) {
                // 跳跃：spr_ly_hengha_niutou_jump 10帧，播放期间真实飞过去
                _tpos = get_world_position_from_grid(ly_aim_col, ly_aim_row);
                var _dist = point_distance(x, y, _tpos.x, _tpos.y);
                if (_dist > 2) {
                    var _ang = point_direction(x, y, _tpos.x, _tpos.y);
                    x += lengthdir_x(ly_jump_speed, _ang);
                    y += lengthdir_y(ly_jump_speed, _ang);
                } else {
                    x = _tpos.x; y = _tpos.y;
                }
                _act = longyuan_variant("正常跳跃", "破损跳跃");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true); // 落地前循环播放
                // 以“是否到达落点”作为结束条件（不能按动画播完结束，否则会停在半空）
                if (_dist <= 2 || timer > 600) {
                    x = _tpos.x; y = _tpos.y;
                    ly_phase = 2; timer = 0;
                }
            }
            else if (ly_phase == 2) {
                // 下落：spr_ly_hengha_niutou_xialuo 6帧
                _act = longyuan_variant("正常下落", "破损下落");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 3; timer = 0; }
            }
            else {
                // skill1 动画播放完毕后对十字 9 格各 400 伤害
                _act = longyuan_variant("正常技能1", "破损技能1");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    // 十字 9 格：3×3 去掉四角，即十字
                    // 用户给的例子：
                    // 0 0 1 0 0
                    // 0 0 1 0 0
                    // 1 1 x 1 1  → 以 x 为中心上下左右各 2 格 + 中心行 5 格去掉中心
                    // 0 0 1 0 0
                    // 0 0 1 0 0
                    // 实际就是 longyuan_damage_cross（函数已经实现十字 9 格）
                    longyuan_damage_cross(ly_aim_col, ly_aim_row, LY_HENGHA_SLAM_DMG);
                    if (global.screen_shake) Camera_Shock(8, 25);
                    if (instance_exists(_peer)) _peer.ly_peer_done++; // 完成本轮技能，允许马面进入下一技能
                    ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE;
                }
            }
            break;
        }

        // ===== 技能2：配合敲钟（事件驱动）=====
        case BOSS_STATE.SKILL2: {
            if (ly_phase == 0) {
                // 闪出：spr_ly_hengha_niutou_shanchu
                _act = longyuan_variant("正常闪出", "破损闪出");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    ly_phase = 1; timer = 0;
                }
            }
            else if (ly_phase == 1) {
                // 闪进到第9列等待（grid_col 8）
                _act = longyuan_variant("正常闪进", "破损闪进");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    _tpos = get_world_position_from_grid(8, ly_link_row);
                    x = _tpos.x; y = _tpos.y;
                    ly_phase = 2; timer = 0;
                }
            }
            else if (ly_phase == 2) {
                // 等待马面抛出铃铛（bell_pending 变为 bell_thrown）
                _act = longyuan_variant("正常待机", "破损待机");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                var _thrown = instance_exists(_peer) && variable_instance_exists(_peer, "ly_bell_thrown") && _peer.ly_bell_thrown;
                if (_thrown || timer > 600) { ly_phase = 3; timer = 0; }
            }
            else if (ly_phase == 3) {
                // 再次闪出，准备跳到 bell 右方
                _act = longyuan_variant("正常闪出", "破损闪出");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    // 跳到 bell 右方第 4 格：(col+4, row)
                    var _jump_col = clamp(ly_link_col + 4, 0, global.grid_cols - 1);
                    _tpos = get_world_position_from_grid(_jump_col, ly_link_row);
                    x = _tpos.x; y = _tpos.y;
                    ly_phase = 4; timer = 0;
                }
            }
            else if (ly_phase == 4) {
                // 落在新位置：闪进
                _act = longyuan_variant("正常闪进", "破损闪进");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 5; timer = 0; }
            }
            else if (ly_phase == 5) {
                // 敲钟：skill2 动画，摧毁沿途卡片 + 触发钟 attackidel
                _act = longyuan_variant("正常技能2", "破损技能2");
                if (ly_action != _act) {
                    longyuan_clip_set(_act);
                    // 进入该段时一次性摧毁 bell 与牛头之间沿途卡片（col+3, col+2, col+1）
                    for (var _c = ly_link_col + 1; _c <= ly_link_col + 3; ++_c) {
                        longyuan_damage_cell(_c, ly_link_row, 0, true);
                    }
                }
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    // 触发钟播放 attackidel
                    if (instance_exists(_peer) && variable_instance_exists(_peer, "ly_bell_inst")) {
                        var _bell = _peer.ly_bell_inst;
                        if (instance_exists(_bell)) {
                            longyuan_hengha_bell_ring(_bell);
                        }
                    }
                    if (global.screen_shake) Camera_Shock(5, 15);
                    // 重置马面信号
                    if (instance_exists(_peer)) {
                        _peer.ly_bell_pending = false;
                        _peer.ly_bell_thrown = false;
                        _peer.ly_peer_done++; // 敲钟完成，允许马面进入技能3
                    }
                    ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE;
                }
            }
            break;
        }

        // ===== 技能3：吸收食灵（事件驱动）=====
        case BOSS_STATE.SKILL3: {
            if (ly_phase == 0) {
                // 闪出：跳到第8列某格等待
                _act = longyuan_variant("正常闪出", "破损闪出");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    ly_absorb_row = irandom_range(1, min(5, global.grid_rows - 1));
                    _tpos = get_world_position_from_grid(7, ly_absorb_row); // 第8列=grid_col 7
                    x = _tpos.x; y = _tpos.y;
                    ly_phase = 1; timer = 0;
                }
            }
            else if (ly_phase == 1) {
                // 闪进第8列
                _act = longyuan_variant("正常闪进", "破损闪进");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 2; timer = 0; }
            }
            else if (ly_phase == 2) {
                // 待机，等马面技能3演出完全结束
                _act = longyuan_variant("正常待机", "破损待机");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                var _mdone = !instance_exists(_peer) || _peer.ly_spirits_done;
                if (_mdone || timer > 1200) { ly_phase = 3; timer = 0; }
            }
            else if (ly_phase == 3) {
                // 完整播放吸收动画，播完后食灵才开始向第9列移动
                _act = longyuan_variant("正常技能3", "破损技能3");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    // 一轮技能循环结束（食灵开始移动）：钟播「飞走」并销毁
                    with (obj_ly_boss_fx) {
                        if (fx_kind == "hengha_bell" && variable_instance_exists(id, "fx_bell_stage") && fx_bell_stage != 5) {
                            fx_bell_leave = true;
                        }
                    }
                    with (obj_ly_hengha_spirit) {
                        ly_absorbing = true;
                        ly_absorb_boss = other.id;
                    }
                    ly_phase = 4; timer = 0;
                }
            }
            else if (ly_phase == 4) {
                // 待机，等所有食灵抵达第9列消散
                _act = longyuan_variant("正常待机", "破损待机");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                if (instance_number(obj_ly_hengha_spirit) == 0 || timer > 1800) { ly_phase = 5; timer = 0; }
            }
            else if (ly_phase == 5) {
                // 闪出：跳到第9列
                _act = longyuan_variant("正常闪出", "破损闪出");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) {
                    _tpos = get_world_position_from_grid(8, ly_absorb_row); // 第9列=grid_col 8
                    x = _tpos.x; y = _tpos.y;
                    ly_phase = 6; timer = 0;
                }
            }
            else if (ly_phase == 6) {
                // 闪进第9列
                _act = longyuan_variant("正常闪进", "破损闪进");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 7; timer = 0; }
            }
            else if (ly_phase == 7) {
                // 再次完整播放吸收动画
                _act = longyuan_variant("正常技能3", "破损技能3");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, false);
                if (longyuan_clip_done(timer, ly_anim_rate)) { ly_phase = 8; timer = 0; }
            }
            else {
                // 动画播完后待机片刻，结束本轮技能
                _act = longyuan_variant("正常待机", "破损待机");
                if (ly_action != _act) longyuan_clip_set(_act);
                longyuan_clip_frame(timer, ly_anim_rate, true);
                if (timer > 30) {
                    if (instance_exists(_peer)) {
                        _peer.ly_spirits_ready = false;
                        _peer.ly_peer_done++; // 吸收完成，允许马面进入下一轮
                    }
                    ly_phase = 0; timer = 0; state = BOSS_STATE.IDLE;
                }
            }
            break;
        }
    }
};
